import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a new user in the database
  static Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Hash the password
      final hashedPassword = _hashPassword(password);
      
      // Insert user into the database
      final response = await _supabase
          .from('users')
          .insert({
            'username': username,
            'email': email,
            'password_hash': hashedPassword,
            'total_pxp': 0,
            'level_title': 'Novice',
          })
          .select()
          .single();

      // Create initial user_skills entries for the two default skills
      await _createInitialUserSkills(response['id']);

      return response;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  /// Creates initial user skills entries for new users
  static Future<void> _createInitialUserSkills(String userId) async {
    try {
      // Get all skills from the database
      final skills = await _supabase
          .from('skills')
          .select('id');

      // Create user_skills entries for each skill
      for (final skill in skills) {
        await _supabase
            .from('user_skills')
            .insert({
              'user_id': userId,
              'skill_id': skill['id'],
              'total_mxp': 0,
              'skill_level': 1,
            });
      }
    } catch (e) {
      throw Exception('Failed to create initial user skills: ${e.toString()}');
    }
  }

  /// Authenticates a user by username and password
  static Future<Map<String, dynamic>?> authenticateUser({
    required String username,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', username)
          .eq('password_hash', hashedPassword)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to authenticate user: ${e.toString()}');
    }
  }

  /// Checks if username is already taken
  static Future<bool> isUsernameTaken(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check username availability: ${e.toString()}');
    }
  }

  /// Checks if email is already taken
  static Future<bool> isEmailTaken(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check email availability: ${e.toString()}');
    }
  }

  /// Simple password hashing (in production, use bcrypt or similar)
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Gets user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }
}
