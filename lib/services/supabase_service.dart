import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'
    show kIsWeb; // Needed to check for web platform
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase client by loading credentials and auto-adjusting the URL for the platform.
  static Future<void> initialize() async {
    try {
      // Load base environment variables from the .env file.
      await dotenv.load(fileName: ".env.local");

      // Get the variables. The '!' will cause a crash if they are not found.
      String supabaseUrl = dotenv.env['SUPABASE_URL']!;
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

      // --- AUTOMATIC PLATFORM ADJUSTMENT ---
      // The Android Emulator cannot use 'localhost'. It needs a special IP '10.0.2.2'
      // to connect to the host machine. We check if the app is running on Android
      // and replace 'localhost' in the URL string if it is.
      //
      // We use !kIsWeb to ensure this mobile-specific code doesn't run on the web.
      if (!kIsWeb && Platform.isAndroid) {
        supabaseUrl = supabaseUrl.replaceFirst('localhost', '10.0.2.2');
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      _client = Supabase.instance.client;
    } catch (e) {
      throw Exception(
        'ERROR: Could not initialize Supabase. Did you forget to create a .env file from .env.example? Or is SUPABASE_URL missing? \n\nOriginal error: ${e.toString()}',
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
