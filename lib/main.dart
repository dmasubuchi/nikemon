import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/result_screen.dart';
import 'screens/history_screen.dart';

void main() => runApp(const NikeApp());

class NikeApp extends StatelessWidget {
  const NikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nike+ Clone',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/result': (context) => const ResultScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
