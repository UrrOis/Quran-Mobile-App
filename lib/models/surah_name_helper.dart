import '../models/quran_surah.dart';

/// Static helper for getting surah name by number
class SurahNameHelper {
  static List<QuranSurah>? _surahList;

  static Future<void> init(List<QuranSurah> surahList) async {
    _surahList = surahList;
  }

  static String? getSurahNameByNumber(int? number) {
    if (number == null || _surahList == null) return null;
    final surah = _surahList!.firstWhere(
      (s) => int.tryParse(s.number) == number,
      orElse:
          () => QuranSurah(
            nameId: '',
            nameEn: '',
            number: '',
            translationId: '',
            audioUrl: '',
            nameLong: '',
            revelationId: '',
            numberOfVerses: '',
            tafsir: '',
          ),
    );
    return surah.nameId.isNotEmpty ? surah.nameId : null;
  }
}
