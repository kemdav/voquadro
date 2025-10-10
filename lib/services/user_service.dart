import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:bcrypt/bcrypt.dart';
import 'dart:io';

// Import custom exception class
import 'package:voquadro/utils/exceptions.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? bio;
  final String? profileAvatarUrl;
  final String? profileBannerUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profileAvatarUrl,
    this.profileBannerUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      bio: map['bio'],
      profileAvatarUrl: map['profile_avatar_url'],
      profileBannerUrl: map['profile_banner_url'],
    );
  }
}

class ProfileData {
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final int level;
  final int masteryLevel;
  final int publicSpeakingLevel; // Can be distinguished later if needed
  final int highestStreak;

  ProfileData({
    required this.username,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    required this.level,
    required this.masteryLevel,
    required this.publicSpeakingLevel,
    required this.highestStreak,
  });
}

class UserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static const String _kPostgrestErrorNoExactRow = 'PGRST116';
  static const String _kPostgresErrorUniqueViolation = '23505';

  /// Creates a new user in database using secure password hashing
  static Future<User> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'email': email,
            'password_hash': hashedPassword,
          })
          .select()
          .single();

      await _createInitialUserSkills(response['id']);

      return User.fromMap(response);
    } on PostgrestException catch (e) {
      //USE CONSTANT INSTEAD OF MAGIC STRING
      if (e.code == _kPostgresErrorUniqueViolation) {
        if (e.message.contains('users_username_key')) {
          throw AuthException('Username is already taken.');
        }
        if (e.message.contains('users_email_key')) {
          throw AuthException('Email is already taken.');
        }
      }
      throw AuthException('Could not create account. Please try again.');
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  /// Authenticates a user by username and password.
  static Future<User> signInWithUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .single();

      final userMap = response;
      final String storedHash = userMap['password_hash'];

      final bool isPasswordCorrect = BCrypt.checkpw(password, storedHash);

      if (!isPasswordCorrect) {
        throw AuthException('Invalid username or password.');
      }

      return User.fromMap(userMap);
    } on PostgrestException catch (e) {
      if (e.code == _kPostgrestErrorNoExactRow) {
        throw AuthException('Invalid username or password.');
      }
      throw AuthException('A database error occurred. Please try again.');
    } catch (e) {
      throw AuthException(
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  static Future<ProfileData> getProfileData(String userId) async {
    try {
      // 1. Fetch core user data (including new level and streak columns).
      final userResponse = await _supabase
          .from('users')
          .select(
            'username, bio, profile_avatar_url, profile_banner_url, level, highest_streak',
          )
          .eq('id', userId)
          .single();

      // 2. Fetch all skill data for that user.
      final skillsResponse = await _supabase
          .from('user_skills')
          .select('total_mxp')
          .eq('user_id', userId);

      // 3. Calculate total Mastery XP and convert to a level.
      int totalMxp = skillsResponse.fold(
        0,
        (sum, skill) => sum + (skill['total_mxp'] as int? ?? 0),
      );
      final masteryLevel =
          (totalMxp / 100).floor() + 1; // Example: 100 MXP per level

      // 4. Assemble and return the complete ProfileData object.
      return ProfileData(
        username: userResponse['username'],
        bio: userResponse['bio'],
        avatarUrl: userResponse['profile_avatar_url'],
        bannerUrl: userResponse['profile_banner_url'],
        level: userResponse['level'],
        masteryLevel: masteryLevel,
        publicSpeakingLevel:
            masteryLevel, // For now, this is the same as mastery level
        highestStreak: userResponse['highest_streak'],
      );
    } catch (e) {
      throw Exception('Failed to fetch profile data: $e');
    }
  }

  /// Fetches the full profile for a given user ID.
  static Future<User> getFullUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select() // Select all columns
          .eq('id', userId)
          .single();
      return User.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Updates the user's bio text in the database.
  static Future<ProfileData> updateBio(String userId, String newBio) async {
    try {
      await _supabase.from('users').update({'bio': newBio}).eq('id', userId);
      // After updating, return the fresh data.
      return getProfileData(userId);
    } catch (e) {
      throw Exception('Failed to update bio: $e');
    }
  }

  static Future<ProfileData> replaceProfileImage({
    required String userId,
    required File newImageFile,
    required String imageType,
    required String? oldImageUrl,
  }) async {
    try {
      final newImageUrl = await uploadProfileImage(
        userId,
        newImageFile,
        imageType,
      );
      await updateProfileImageUrl(userId, newImageUrl, imageType);
      if (oldImageUrl != null) {
        _deleteOldImage(oldImageUrl); // No need to await
      }
      // After all operations, return the fresh data.
      return getProfileData(userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads an image file to the 'profile-assets' storage bucket.
  /// Returns the public URL of the uploaded file.
  static Future<String> uploadProfileImage(
    String userId,
    File file,
    String imageType,
  ) async {
    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      // The path format 'user_id/image_type.ext' is crucial for security policies.
      final path = '$userId/$imageType.$fileExtension';

      await _supabase.storage
          .from('profile-assets')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('profile-assets').getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Updates the user's profile_avatar_url or profile_banner_url in the database.
  static Future<void> updateProfileImageUrl(
    String userId,
    String url,
    String imageType,
  ) async {
    try {
      final column = imageType == 'avatar'
          ? 'profile_avatar_url'
          : 'profile_banner_url';
      await _supabase.from('users').update({column: url}).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update image URL: $e');
    }
  }

  static Future<void> _deleteOldImage(String oldImageUrl) async {
    // We only want to delete if it's a Supabase storage URL, not a default asset.
    if (!oldImageUrl.contains('supabase.co')) return;

    try {
      // The path is the part of the URL after the bucket name
      final bucketName = 'profile_assets';
      final oldImagePath = oldImageUrl.split('$bucketName/').last;

      // Don't try to delete if the path is invalid or is the same as the bucket name
      if (oldImagePath.isNotEmpty && oldImagePath != bucketName) {
        await _supabase.storage.from(bucketName).remove([oldImagePath]);
      }
    } catch (e) {
      // It's okay if this fails. The main goal was uploading the new image.
      // We don't want to show an error to the user for this.
      debugPrint("Failed to delete old image, but that's okay. Error: $e");
    }
  }

  static Future<void> _createInitialUserSkills(String userId) async {
    try {
      final skills = await _supabase.from('skills').select('id');
      final userSkills = skills
          .map((skill) => {'user_id': userId, 'skill_id': skill['id']})
          .toList();

      if (userSkills.isNotEmpty) {
        await _supabase.from('user_skills').insert(userSkills);
      }
    } catch (e) {
      debugPrint('Failed to create initial user skills');
    }
  }

  static Future<bool> isUsernameTaken(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check username availability');
    }
  }

  static Future<bool> isEmailTaken(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check email availability');
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to get user');
    }
  }
}
