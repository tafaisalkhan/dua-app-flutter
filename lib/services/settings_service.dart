import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  static final ValueNotifier<String> selectedLanguage = ValueNotifier<String>('english');
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

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
