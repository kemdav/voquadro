import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, Session;
import 'package:voquadro/src/models/session_model.dart';
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

  final int paceControlEXP;
  final int fillerControlEXP;
  final int publicSpeakingEXP;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.profileAvatarUrl,
    this.profileBannerUrl,
    required this.paceControlEXP,
    required this.fillerControlEXP,
    required this.publicSpeakingEXP,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    final int paceControlEXP = map['pace_control'] as int? ?? 0;
    final int fillerControlEXP = map['filler_control'] as int? ?? 0;
    final int publicSpeakingEXP = map['public_speaking_xp'] as int? ?? 0;

    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      bio: map['bio'],
      profileAvatarUrl: map['profile_avatar_url'],
      profileBannerUrl: map['profile_banner_url'],
      paceControlEXP: paceControlEXP,
      fillerControlEXP: fillerControlEXP,
      publicSpeakingEXP: publicSpeakingEXP,
    );
  }
}

class ProfileData {
  final String username;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;

  final int highestStreak;

  ProfileData({
    required this.username,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,

    required this.highestStreak,
  });
}

class UserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> addExp(
    String userId, {
    // int practiceExp = 0,
    int paceControlExp = 0,
    int fillerControlExp = 0,
    Map<String, int>? modeExpGains,
  }) async {
    // Do nothing if no XP is being added.
    if (paceControlExp <= 0 &&
        fillerControlExp <= 0 &&
        (modeExpGains == null || modeExpGains.isEmpty)) {
      return;
    }

    try {
      final currentXP = await _getUserXP(userId);

      final Map<String, dynamic> updatePayload = {};

      // --- Handle General and Mastery XP ---

      // NOTE: the braces indicated the column name < 3 :)
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

      return;
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
          .select('pace_control, filler_control, public_speaking_xp')
          .eq('id', userId)
          .single();

      // Return all values, providing a default of 0 if they are null in the DB.
      return {
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
      // 1. Create the user in the Supabase Auth schema
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        // We can store the username in the metadata
        data: {'username': username},
      );

      if (authResponse.user == null) {
        throw AuthException('Could not create account. User is null.');
      }

      // 2. The trigger has already created the profile. Now, we just fetch it.
      //    This also confirms that the trigger worked correctly.
      final userProfile = await getFullUserProfile(authResponse.user!.id);

      // Your other logic remains the same
      await _createInitialUserSkills(userProfile.id);
      return userProfile;
    } on AuthException catch (e) {
      if (e.message.contains('User already registered')) {
        throw AuthException('Email is already taken.');
      }
      // You can add more specific error handling here
      throw AuthException(e.message);
    } catch (e, stackTrace) {
      debugPrint('--- REAL CREATE USER ERROR ---');
      debugPrint('$e');
      debugPrint('$stackTrace');
      throw AuthException(
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  /// Authenticates a user by username and password.
  static Future<User> signInWithUsernameAndPassword({
    required String username, // <-- Correctly takes username
    required String password,
  }) async {
    try {
      // Step 1: Look up the user's email from their username.
      final userEmailResponse = await _supabase
          .from('users')
          .select('email')
          .eq('username', username)
          .maybeSingle();

      if (userEmailResponse == null) {
        throw AuthException('Invalid username or password.');
      }
      final String email = userEmailResponse['email'];

      // Step 2: Use the found email to sign in with Supabase Auth.
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw AuthException('Invalid username or password.');
      }

      // Step 3: Fetch the full user profile.
      final userProfile = await getFullUserProfile(authResponse.user!.id);
      return userProfile;
    } on AuthException {
      throw AuthException('Invalid username or password.');
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
            'username, bio, profile_avatar_url, profile_banner_url, highest_streak',
          )
          .eq('id', userId)
          .single();

      // Assemble the final ProfileData object using the calculated values.
      return ProfileData(
        username: userResponse['username'],
        bio: userResponse['bio'],
        avatarUrl: userResponse['profile_avatar_url'],
        bannerUrl: userResponse['profile_banner_url'],
        // For now, this is the same
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

      debugPrint("Uploading to Supabase Storage with path: $path");

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

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
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
      debugPrint('Error checking username availability: $e');
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
      debugPrint('Error checking email availability: $e');
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

  static Future<void> deleteCurrentUserAccount() async {
    try {
      await _supabase.rpc('delete_user_account');

      //signout locally
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  static Future<void> addSession(Session session, String userId) async {
    try {
      await _supabase.from('practice_sessions').insert(session.toMap(userId));
    } catch (e) {
      // THIS WILL SHOW YOU THE REAL ERROR
      debugPrint('--- DATABASE INSERT FAILED ---');
      debugPrint(e.toString());
      // ------------------------------------
      throw Exception('Failed to save session: $e');
    }
  }

  /// Fetches a list of all past practice sessions for the given user.
  static Future<List<Session>> getSessionsForUser(String userId) async {
    try {
      final response = await _supabase
          .from('practice_sessions')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false); // Show most recent first

      // Convert the list of maps into a list of Session objects
      return response.map((map) => Session.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }
}
