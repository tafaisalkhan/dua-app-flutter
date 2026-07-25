import 'dart:convert';
import 'package:flutter/services.dart';
import '../components/dua.dart';

class DuaService {
  /// Fetches the list of Prophets (Anbiya) from the local JSON asset file.
  /// Handles both the old format (List) and the new format (Map) dynamically.
  static Future<List<Prophet>> fetchProphets() async {
    // Simulate some network delay (e.g., 500ms) to make it feel like a real service call
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    try {
      final String response = await rootBundle.loadString('assets/duas.json');
      final dynamic decoded = json.decode(response);
      
      if (decoded is List) {
        // Parse the old List format and wrap it inside the Prophet model structure
        final List<Aya> ayas = [];
        for (int i = 0; i < decoded.length; i++) {
          final item = decoded[i] as Map<String, dynamic>;
          ayas.add(Aya(
            index: i + 1,
            ayaNo: '${i + 1}',
            arabic: item['transliteration'] as String? ?? '',
            english: item['translation'] as String? ?? '',
            spanish: '',
            chinese: '',
            japanese: '',
            urdu: item['translation'] as String? ?? '',
            turkish: '',
            jsonAya: i + 1,
            bismial: '',
            mp3FilePath: '',
            chapterName: item['category'] as String? ?? 'Daily',
            chapterNo: 1,
            prophetName: item['title'] as String? ?? 'Dua',
            prophetArabicName: '',
            favorite: 0,
          ));
        }

        // Group the duas by category to represent them as "Prophets" or category headers
        final Map<String, List<Aya>> grouped = {};
        for (final a in ayas) {
          grouped.putIfAbsent(a.chapterName, () => []).add(a);
        }

        return grouped.entries.map((entry) {
          return Prophet(
            name: '${entry.key} Duas',
            arabicName: 'ادعية',
            duas: [
              ProphetDua(
                chapterName: entry.key,
                chapterNo: 1,
                ayas: entry.value,
              )
            ],
          );
        }).toList();
      } else if (decoded is Map<String, dynamic>) {
        // Parse the new map format
        final Map<String, dynamic> duaMap = decoded['Dua'] as Map<String, dynamic>;
        final List<dynamic> anbiyaList = duaMap['anbiya'] as List<dynamic>;
        return anbiyaList.map((json) => Prophet.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Unknown JSON format');
      }
    } catch (e) {
      throw Exception('Failed to load prophets: $e');
    }
  }
}
