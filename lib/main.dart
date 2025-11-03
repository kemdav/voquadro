import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/managers/app_flow_manager.dart';
import 'package:voquadro/services/supabase_service.dart'; 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // These providers are now available to the ENTIRE application.
        ChangeNotifierProvider(create: (_) => AppFlowController()),
        ChangeNotifierProvider(create: (_) => AudioController()),
        // Add any other global services here.
      ],
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
