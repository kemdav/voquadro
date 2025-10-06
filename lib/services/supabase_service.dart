import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase client by loading credentials from the .env file.
  static Future<void> initialize() async {
    try {
      // Load environment variables from the .env file.
      // You can keep .env.local for personal overrides if you like.
      await dotenv.load(fileName: ".env");
      await dotenv.load(fileName: ".env.local");

      // Get the variables. The '!' will cause a crash if they are not found.
      // This is GOOD because it tells the developer immediately that their setup is wrong.
      final supabaseUrl = dotenv.env['SUPABASE_URL']!;
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _client = Supabase.instance.client;
    } catch (e) {
      // This provides a very clear error message to your teammates if they forget to create the .env file.
      throw Exception(
        'ERROR: Could not initialize Supabase. Did you forget to create a .env file from .env.example? \n\nOriginal error: ${e.toString()}',
      );
    }
  }

  /// Get the Supabase client
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }
}
