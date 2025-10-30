import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/managers/app_flow_manager.dart';
import 'package:voquadro/services/supabase_service.dart'; 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
