import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_ayah.dart';

class QuranAyahApi {
  // Fetch satu ayat berdasarkan nomor global (index)
  Future<QuranAyah> fetchAyahByIndex(int index) async {
    final url = 'https://api.myquran.com/v2/quran/ayat/$index';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final ayahData = data['data'] ?? {};
      // Fallback: surahName dan surahNumber bisa null jika tidak ada di response
      return QuranAyah.fromJson(ayahData);
    } else {
      throw Exception('Gagal memuat ayat');
    }
  }

  // (Opsional) Fetch semua ayat dalam satu surat (untuk quran_read_page.dart legacy)
  Future<List<QuranAyah>> fetchAyatList(int surahNumber) async {
    final url = 'https://api.myquran.com/v2/quran/ayat/surat/$surahNumber';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List ayatList = data['data'] ?? [];
      return ayatList.map((e) => QuranAyah.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat ayat surat');
    }
  }
}
