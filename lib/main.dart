import 'package:flutter/material.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/managers/app_flow_manager.dart';
import 'package:voquadro/services/supabase_service.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/widgets/internet_check_wrapper.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppFlowController()),
        ChangeNotifierProvider(create: (_) => AudioController()),
        ChangeNotifierProvider(create: (_) => SoundService()),
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
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ),
          home: const InternetCheckWrapper(child: AppFlowManager()),
        );
      },
    );
  }
}
