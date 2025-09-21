import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Hash password using SHA-256 (for demo purposes - in production use bcrypt)
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final emailCheck = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (emailCheck != null) {
        return {
          'success': false,
          'message': 'Email already exists',
        };
      }

      // Check if username already exists
      final usernameCheck = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (usernameCheck != null) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Hash the password
      final hashedPassword = _hashPassword(password);

      // Insert new user
      final response = await _supabase.from('users').insert({
        'email': email,
        'username': username,
        'password_hash': hashedPassword,
        'total_pxp': 0,
        'level_title': 'Novice',
      }).select();

      if (response.isNotEmpty) {
        return {
          'success': true,
          'message': 'Registration successful',
          'user': response.first,
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Authenticate user login
  static Future<Map<String, dynamic>> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      // Hash the password
      final hashedPassword = _hashPassword(password);

      // Query user by email and password
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .eq('password_hash', hashedPassword)
          .maybeSingle();

      if (response != null) {
        return {
          'success': true,
          'message': 'Login successful',
          'user': response,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Get user by username
  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('username', username)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }
}
