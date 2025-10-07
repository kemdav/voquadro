import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:bcrypt/bcrypt.dart';

// Import custom exception class
import 'package:voquadro/utils/exceptions.dart';

class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], username: map['username'], email: map['email']);
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
}
