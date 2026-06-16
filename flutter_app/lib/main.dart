// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/settings_provider.dart';
import 'services/api_service.dart';
import 'services/prefs_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved username + server URL (phone remembers them).
  await PrefsService.init();
  ApiService.customBaseUrl = PrefsService.serverUrl;

  // Portrait only for a classic Flappy feel (ignored on web).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FlappyApp());
}

class FlappyApp extends StatelessWidget {
  const FlappyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: MaterialApp(
        title: 'Flappy World Cup',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4EC0CA),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
