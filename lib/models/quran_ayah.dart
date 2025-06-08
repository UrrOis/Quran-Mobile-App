class QuranAyah {
  final int number; // Nomor ayat global
  final String arabic;
  final String latin;
  final String translation;
  final String? surahName;
  final int? numberInSurah;
  final int? surahNumber;

  QuranAyah({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.surahName,
    this.numberInSurah,
    this.surahNumber,
  });

  // Factory untuk parsing dari API Juz
  factory QuranAyah.fromApiJuz(
    Map<String, dynamic> json, {
    String? surahName,
    int? surahNumber,
  }) {
    return QuranAyah(
      number: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      arabic: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['text'] ?? '',
      surahName: surahName,
      numberInSurah:
          json['ayah'] != null ? int.tryParse(json['ayah'].toString()) : null,
      surahNumber: surahNumber,
    );
  }

  // Factory untuk parsing dari API ayat global (by index)
  factory QuranAyah.fromApiByIndex(
    Map<String, dynamic> json, {
    required String surahName,
    required int surahNumber,
  }) {
    return QuranAyah(
      number: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      arabic: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['text'] ?? '',
      surahName: surahName,
      numberInSurah:
          json['ayah'] != null ? int.tryParse(json['ayah'].toString()) : null,
      surahNumber: surahNumber,
    );
  }

  // Factory untuk parsing dari JSON (untuk parsing list ayat di Juz/global)
  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    // Coba ambil surahName dan surahNumber dari beberapa kemungkinan field
    String? surahName =
        json['surahName'] ?? json['surah_name'] ?? json['surah'] ?? null;
    int? surahNumber;
    if (json['surahNumber'] != null) {
      surahNumber = int.tryParse(json['surahNumber'].toString());
    } else if (json['surah_number'] != null) {
      surahNumber = int.tryParse(json['surah_number'].toString());
    } else if (json['surah'] != null &&
        int.tryParse(json['surah'].toString()) != null) {
      surahNumber = int.tryParse(json['surah'].toString());
    }
    return QuranAyah(
      number: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      arabic: json['arab'] ?? '',
      latin: json['latin'] ?? '',
      translation: json['text'] ?? '',
      surahName: surahName,
      numberInSurah:
          json['ayah'] != null ? int.tryParse(json['ayah'].toString()) : null,
      surahNumber: surahNumber,
    );
  }
}

// API dipisah ke file api/quran_ayah_api.dart
// Pastikan import sudah benar di file yang membutuhkan QuranAyahApi
