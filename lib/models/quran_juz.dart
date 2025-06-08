import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quran_ayah.dart';

class QuranJuz {
  final int number;
  final List<QuranAyah> ayat;
  final String? name;
  final String? range;

  QuranJuz({required this.number, required this.ayat, this.name, this.range});

  factory QuranJuz.fromJson(Map<String, dynamic> json) {
    // API juz: { status, info: { juz, nama, range }, data: [ ...ayat... ] }
    final info = json['info'] ?? {};
    return QuranJuz(
      number:
          info['juz'] is int
              ? info['juz']
              : int.tryParse(info['juz']?.toString() ?? '') ?? 0,
      name: info['nama'],
      range: info['range'],
      ayat: (json['data'] as List).map((e) => QuranAyah.fromJson(e)).toList(),
    );
  }
}

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
