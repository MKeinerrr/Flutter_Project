import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget — configures the app theme and sets HomeScreen as the entry point.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.accent,
          onPrimary: AppColors.bg0,
          secondary: AppColors.accentDim,
          onSecondary: AppColors.bg0,
          error: AppColors.danger,
          onError: AppColors.text1,
          surface: AppColors.bg2,
          onSurface: AppColors.text1,
        ),
        scaffoldBackgroundColor: AppColors.bg0,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg1,
          foregroundColor: AppColors.text1,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bg1,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.text3,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
