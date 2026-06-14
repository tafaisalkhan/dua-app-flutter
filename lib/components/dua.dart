import 'package:flutter/foundation.dart';

class Aya {
  final int index;
  final String ayaNo;
  final String arabic;
  final String english;
  final String spanish;
  final String chinese;
  final String japanese;
  final String urdu;
  final String turkish;
  final int jsonAya;
  final String bismial;
  final String mp3FilePath;
  final String chapterName;
  final int chapterNo;
  final String prophetName;
  final String prophetArabicName;
  final int favorite;

  const Aya({
    required this.index,
    required this.ayaNo,
    required this.arabic,
    required this.english,
    required this.spanish,
    required this.chinese,
    required this.japanese,
    required this.urdu,
    required this.turkish,
    required this.jsonAya,
    required this.bismial,
    required this.mp3FilePath,
    required this.chapterName,
    required this.chapterNo,
    required this.prophetName,
    required this.prophetArabicName,
    required this.favorite,
  });

  factory Aya.fromJson(Map<String, dynamic> json) {
    return Aya(
      index: (json['index'] as int?) ?? 0,
      ayaNo: json['aya_no'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
      spanish: json['spanish'] as String? ?? '',
      chinese: (json['chinses'] ?? json['chinese'] ?? '') as String,
      japanese: (json['japanses'] ?? json['japanese'] ?? '') as String,
      urdu: json['urdu'] as String? ?? '',
      turkish: json['turkish'] as String? ?? '',
      jsonAya: (json['json_aya'] as int?) ?? 0,
      bismial: json['bismial'] as String? ?? '',
      mp3FilePath: json['mp3_file_path'] as String? ?? '',
      chapterName: json['chapter_name'] as String? ?? '',
      chapterNo: (json['chapter_no'] as int?) ?? 0,
      prophetName: json['name'] as String? ?? '',
      prophetArabicName: json['arabic_name'] as String? ?? '',
      favorite: (json['favorite'] as int?) ?? 0,
    );
  }
}

class ProphetDua {
  final String chapterName;
  final int chapterNo;
  final List<Aya> ayas;

  const ProphetDua({
    required this.chapterName,
    required this.chapterNo,
    required this.ayas,
  });

  factory ProphetDua.fromJson(Map<String, dynamic> json) {
    return ProphetDua(
      chapterName: json['chapter_name'] as String? ?? '',
      chapterNo: (json['chapter_no'] as int?) ?? 0,
      ayas: (json['aya'] as List<dynamic>?)
              ?.map((a) => Aya.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Prophet {
  final String name;
  final String arabicName;
  final List<ProphetDua> duas;

  const Prophet({
    required this.name,
    required this.arabicName,
    required this.duas,
  });

  factory Prophet.fromJson(Map<String, dynamic> json) {
    return Prophet(
      name: json['name'] as String,
      arabicName: json['arabic_name'] as String,
      duas: (json['dua'] as List<dynamic>)
          .map((d) => ProphetDua.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  // Helper to get all Ayas of this Prophet directly as a flat list
  List<Aya> get allAyas {
    final List<Aya> list = [];
    for (final d in duas) {
      list.addAll(d.ayas);
    }
    return list;
  }
}

List<Prophet> prophets = [];

final ValueNotifier<Set<int>> favoriteDuaIndexes = ValueNotifier(<int>{});
