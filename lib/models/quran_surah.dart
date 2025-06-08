// Model untuk data surat Al-Quran
class QuranSurah {
  final String nameId;
  final String nameEn;
  final String number;
  final String translationId;
  final String audioUrl;
  final String nameLong;
  final String revelationId;
  final String numberOfVerses;
  final String tafsir;

  QuranSurah({
    required this.nameId,
    required this.nameEn,
    required this.number,
    required this.translationId,
    required this.audioUrl,
    required this.nameLong,
    required this.revelationId,
    required this.numberOfVerses,
    required this.tafsir,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      nameId: json['name_id'] ?? '',
      nameEn: json['name_en'] ?? '',
      number: json['number'] ?? '',
      translationId: json['translation_id'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      nameLong: json['name_long'] ?? '',
      revelationId: json['revelation_id'] ?? '',
      numberOfVerses: json['number_of_verses'] ?? '',
      tafsir: json['tafsir'] ?? '',
    );
  }
}
