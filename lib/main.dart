import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/workout_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/exercise_library_screen.dart';
import 'screens/workout_session_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/ai_trainer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutProvider(prefs),
      child: MaterialApp(
        title: 'Fitness Quest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7F77DD),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7F77DD),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/library': (context) => const ExerciseLibraryScreen(),
          '/workout': (context) => const WorkoutSessionScreen(),
          '/progress': (context) => const ProgressScreen(),
          '/ai': (context) => const AiTrainerScreen(),
        },
      ),
    );
  }
}