import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static late SharedPreferences _prefs;

  static final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('english');
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final ValueNotifier<bool> notificationsEnabled = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> hasPromptedForNotifications = ValueNotifier<bool>(false);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Load persisted settings
    selectedLanguage.value = _prefs.getString('selectedLanguage') ?? 'english';

    final themeStr = _prefs.getString('themeMode') ?? 'light';
    if (themeStr == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (themeStr == 'system') {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.light;
    }

    notificationsEnabled.value = _prefs.getBool('notificationsEnabled') ?? true;
    hasPromptedForNotifications.value = _prefs.getBool('hasPromptedForNotifications') ?? false;

    // Listen to changes and persist them
    selectedLanguage.addListener(() {
      _prefs.setString('selectedLanguage', selectedLanguage.value);
    });

    themeMode.addListener(() {
      String themeStr = 'light';
      if (themeMode.value == ThemeMode.dark) {
        themeStr = 'dark';
      } else if (themeMode.value == ThemeMode.system) {
        themeStr = 'system';
      }
      _prefs.setString('themeMode', themeStr);
    });

    notificationsEnabled.addListener(() {
      _prefs.setBool('notificationsEnabled', notificationsEnabled.value);
    });

    hasPromptedForNotifications.addListener(() {
      _prefs.setBool('hasPromptedForNotifications', hasPromptedForNotifications.value);
    });
  }

  static const List<String> availableLanguages = [
    'english',
    'spanish',
    'chinese',
    'japanese',
    'urdu',
    'turkish',
  ];

  static const Map<String, String> languageNames = {
    'english': 'English',
    'spanish': 'Spanish',
    'chinese': 'Chinese',
    'japanese': 'Japanese',
    'urdu': 'Urdu',
    'turkish': 'Turkish',
  };

  static String getTranslation(Map<String, dynamic> json, String language) {
    switch (language) {
      case 'english':
        return json['english'] as String? ?? '';
      case 'spanish':
        return json['spanish'] as String? ?? '';
      case 'chinese':
        return (json['chinses'] ?? json['chinese'] ?? '') as String;
      case 'japanese':
        return (json['japanses'] ?? json['japanese'] ?? '') as String;
      case 'urdu':
        return json['urdu'] as String? ?? '';
      case 'turkish':
        return json['turkish'] as String? ?? '';
      default:
        return json['english'] as String? ?? '';
    }
  }
}
