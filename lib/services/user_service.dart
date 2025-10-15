import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:bcrypt/bcrypt.dart';

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
          .select('id, username, email, password_hash')
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

  /// Changes a user's password by verifying the current password and then
  /// updating the stored bcrypt hash in the `users` table.
  static Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Fetch existing password hash
      final userRow = await _supabase
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();

      final String storedHash = userRow['password_hash'] as String;

      final bool matches = BCrypt.checkpw(currentPassword, storedHash);
      if (!matches) {
        throw AuthException('Current password is incorrect.');
      }

      // Hash the new password and update
      final String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await _supabase
          .from('users')
          .update({'password_hash': newHash})
          .eq('id', userId);
    } on PostgrestException catch (_) {
      throw AuthException('Could not change password. Please try again.');
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }
}
