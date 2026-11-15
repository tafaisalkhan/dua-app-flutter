import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'components/splash_screen.dart';
import 'services/settings_service.dart';
import 'services/ad_service.dart';
import 'services/service.dart';
import 'services/notification_service.dart';
import 'components/dua.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.init();
  await NotificationService.init();
  if (SettingsService.notificationsEnabled.value) {
    await NotificationService.scheduleDailyDuaNotification();
  }
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    AdService.loadInterstitialAd();
  }
  try {
    prophets = await DuaService.fetchProphets();
  } catch (e) {
    debugPrint('Error preloading prophets: $e');
  }
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
