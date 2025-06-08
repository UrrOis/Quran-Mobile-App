import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_surah.dart';

class QuranApi {
  Future<List<QuranSurah>> fetchAllSurah() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/quran/surat/semua'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List surahList = data['data'] ?? [];
      return surahList.map((e) => QuranSurah.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load surah');
    }
  }
}
