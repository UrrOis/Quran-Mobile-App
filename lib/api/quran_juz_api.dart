import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_juz.dart';

class QuranJuzApi {
  Future<QuranJuz> fetchJuz(int juzNumber) async {
    final url = 'https://api.myquran.com/v2/quran/ayat/juz/$juzNumber';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return QuranJuz.fromJson(data);
    } else {
      throw Exception('Gagal memuat juz');
    }
  }
}
