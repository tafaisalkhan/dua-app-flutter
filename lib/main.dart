import 'package:flutter/material.dart';
import 'components/splash_screen.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const DuaApp());
}

class DuaApp extends StatelessWidget {
  const DuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Dua App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F7A5A),
              primary: const Color(0xFF1F7A5A),
              secondary: const Color(0xFFC68B2C),
              surface: const Color(0xFFFFFCF6),
            ),
            scaffoldBackgroundColor: const Color(0xFFFFFCF6),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F7A5A),
              primary: const Color(0xFF1F7A5A),
              secondary: const Color(0xFFC68B2C),
              surface: const Color(0xFF1E1E1E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
          ),
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
