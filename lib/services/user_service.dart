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

  final int practiceEXP;
  final int masteryEXP;
  final int paceControlEXP;
  final int fillerControlEXP;
  final int publicSpeakingEXP;

  final int practiceLevel;
  final int masteryLevel;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profileAvatarUrl,
    this.profileBannerUrl,
    required this.practiceEXP,
    required this.masteryEXP,
    required this.paceControlEXP,
    required this.fillerControlEXP,
    required this.publicSpeakingEXP,
    required this.practiceLevel,
    required this.masteryLevel,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    final totalPxp = map['practice_xp'] as int? ?? 0;
    final totalMxp = map['master_xp'] as int? ?? 0;

    final int practiceEXP = map['practice_xp'] as int? ?? 0;
    final int masteryEXP = map['master_xp'] as int? ?? 0;
    final int paceControlEXP = map['pace_control'] as int? ?? 0;
    final int fillerControlEXP = map['filler_control'] as int? ?? 0;
    final int publicSpeakingEXP = map['public_speaking_xp'] as int? ?? 0;

    // Level rules, this should be changed in the future i hope we wont forget
    const int pxpPerLevel = 500;
    const int mxpPerLevel = 100;

    final calculatedPracticeLevel = (totalPxp / pxpPerLevel).floor() + 1;
    final calculatedMasteryLevel = (totalMxp / mxpPerLevel).floor() + 1;

    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      bio: map['bio'],
      profileAvatarUrl: map['profile_avatar_url'],
      profileBannerUrl: map['profile_banner_url'],
      practiceEXP: practiceEXP,
      masteryEXP: masteryEXP,
      paceControlEXP: paceControlEXP,
      fillerControlEXP: fillerControlEXP,
      publicSpeakingEXP: publicSpeakingEXP,
      practiceLevel: calculatedPracticeLevel,
      masteryLevel: calculatedMasteryLevel,
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

  static Future<void> addExp(
    String userId, {
    int practiceExp = 0,
    int paceControlExp = 0,
    int fillerControlExp = 0,
    Map<String, int>? modeExpGains,
  }) async {
    // Do nothing if no XP is being added.
    if (practiceExp <= 0 &&
        paceControlExp <= 0 &&
        fillerControlExp <= 0 &&
        (modeExpGains == null || modeExpGains.isEmpty)) {
      return;
    }

    try {
      final currentXP = await _getUserXP(userId);

      final Map<String, dynamic> updatePayload = {};

      // --- Handle General and Mastery XP ---

      // NOTE: the braces indicated the column name < 3 :)
      if (practiceExp > 0) {
        updatePayload['practice_xp'] = currentXP['practice_xp']! + practiceExp;
      }
      if (paceControlExp > 0) {
        updatePayload['pace_control'] =
            currentXP['pace_control']! + paceControlExp;
      }
      if (fillerControlExp > 0) {
        updatePayload['filler_control'] =
            currentXP['filler_control']! + fillerControlExp;
      }

      if (modeExpGains != null) {
        for (var entry in modeExpGains.entries) {
          final modeName = entry.key; // e.g., 'public_speaking_xp'
          final expToAdd = entry.value;

          if (expToAdd > 0) {
            final currentModeExp = currentXP[modeName] ?? 0;
            updatePayload[modeName] = currentModeExp + expToAdd;
          }
        }
      }

      if (updatePayload.isNotEmpty) {
        await _supabase.from('users').update(updatePayload).eq('id', userId);
      }
    } catch (e) {
      throw Exception('Failed to add user EXP: $e');
    }
  }

  static Future<Map<String, int>> _getUserXP(String userId) async {
    // Modify this to match the Db pweaseeee
    try {
      final response = await _supabase
          .from('users')
          // Add any new mode XP columns to this select statement.
          // THIS IS THE LINE TO CHANGE THE COLUMNS <3
          .select(
            'practice_xp, master_xp, pace_control, filler_control, public_speaking_xp',
          )
          .eq('id', userId)
          .single();

      // Return all values, providing a default of 0 if they are null in the DB.
      return {
        'practice_xp': response['practice_xp'] as int? ?? 0,
        'master_xp': response['master_xp'] as int? ?? 0,
        'pace_control': response['pace_control'] as int? ?? 0,
        'filler_control': response['filler_control'] as int? ?? 0,
        'public_speaking_xp': response['public_speaking_xp'] as int? ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to get user XP data: $e');
    }
  }

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
      final userResponse = await _supabase
          .from('users')
          .select(
            'username, bio, profile_avatar_url, profile_banner_url, highest_streak, practice_xp, master_xp',
          )
          .eq('id', userId)
          .single();

      // Get the raw XP values, defaulting to 0 if null.
      final totalPxp = userResponse['practice_xp'] as int? ?? 0;
      final totalMxp = userResponse['master_xp'] as int? ?? 0;

      // Define level-up rules here.
      const int pxpPerLevel = 500;
      const int mxpPerLevel = 100;

      // Calculate the levels on-the-fly.
      final calculatedLevel = (totalPxp / pxpPerLevel).floor() + 1;
      final calculatedMasteryLevel = (totalMxp / mxpPerLevel).floor() + 1;

      // Assemble the final ProfileData object using the calculated values.
      return ProfileData(
        username: userResponse['username'],
        bio: userResponse['bio'],
        avatarUrl: userResponse['profile_avatar_url'],
        bannerUrl: userResponse['profile_banner_url'],
        level: calculatedLevel, // Use the calculated level
        masteryLevel: calculatedMasteryLevel, // Use the calculated level
        publicSpeakingLevel:
            calculatedMasteryLevel, // For now, this is the same
        highestStreak: userResponse['highest_streak'],
      );
    } catch (e) {
      throw Exception('Failed to fetch user profile data: $e');
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
        _deleteOldImage(oldImageUrl);
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
    if (!oldImageUrl.contains('supabase.co')) return;

    try {
      final bucketName = 'profile-assets';
      final oldImagePath = oldImageUrl.split('$bucketName/').last;

      if (oldImagePath.isNotEmpty && oldImagePath != bucketName) {
        await _supabase.storage.from(bucketName).remove([oldImagePath]);
      }
    } catch (e) {
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
