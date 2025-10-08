import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/managers/app_flow_manager.dart';
// REMOVE these imports, they are no longer needed in main.dart
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// ADD this import to use the service you created
import 'package:voquadro/services/supabase_service.dart'; // <-- MAKE SURE THIS PATH IS CORRECT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REMOVE all the old initialization logic
  // await dotenv.load(fileName: ".env");
  // await dotenv.load(fileName: ".env.local");
  //
  // await Supabase.initialize(
  //  url: dotenv.env['SUPABASE_URL']!,
  //   anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  // );

  // REPLACE it with this single line.
  // This call will handle everything for you: loading env files and adjusting the URL.
  await SupabaseService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppFlowController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: subtreeSelector,
      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          home: AppFlowManager(),
        );
      },
    );
  }
}
