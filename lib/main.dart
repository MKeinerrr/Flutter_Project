import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget — configures the app theme and sets HomeScreen as the entry point.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon Reservation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Custom color scheme based on the salon branding palette
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A0A4C),
          primary: const Color(0xFF1A0A4C),
          secondary: const Color(0xFF3D3B8E),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A0A4C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
