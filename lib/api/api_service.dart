import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hadith.dart';

// Mengatur semua panggilan API untuk waktu sholat, konversi uang, dan lainnya.
class ApiService {
  // Contoh: Fetch waktu sholat
  Future<Map<String, dynamic>> fetchPrayerTimes(String cityId) async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/sholat/jadwal/$cityId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  // Contoh: Fetch currency
  Future<Map<String, dynamic>> fetchCurrency(String from, String to) async {
    final response = await http.get(
      Uri.parse(
        'https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_fDjfUKJiRGRuxjWjqhu0HNdXb4u7GtxQSdNlOsRL&base_currency=$from&currencies=$to',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load currency');
    }
  }

  // Contoh: Fetch waktu dunia
  Future<Map<String, dynamic>> fetchTime(String timeZone) async {
    final response = await http.get(
      Uri.parse('https://timeapi.io/api/time/current/zone?timeZone=$timeZone'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load time');
    }
  }

  // Fetch doa harian acak
  Future<Map<String, dynamic>> fetchRandomDoa() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/doa/acak'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load doa harian');
    }
  }

  // Fetch hadits Arbain acak
  Future<HadithArbain> fetchHadithArbain() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/hadits/arbain/acak'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return HadithArbain.fromJson(data);
    } else {
      throw Exception('Failed to load hadith arbain');
    }
  }

  // Fetch hadits Bulughul Maram acak
  Future<HadithBulughulMaram> fetchHadithBulughulMaram() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/hadits/bm/acak'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return HadithBulughulMaram.fromJson(data);
    } else {
      throw Exception('Failed to load hadith bulughul maram');
    }
  }

  // Fetch hadits 9 Perawi acak
  Future<HadithPerawi> fetchHadithPerawi() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/hadits/perawi/acak'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      final perawi =
          jsonDecode(response.body)['info']?['perawi']?['name'] ?? '';
      return HadithPerawi.fromJson({...data, 'perawi': perawi});
    } else {
      throw Exception('Failed to load hadith perawi');
    }
  }

  // Fetch kalender hijriah
  Future<HijriCalendar> fetchHijriCalendar() async {
    final response = await http.get(
      Uri.parse('https://api.myquran.com/v2/cal/hijr/?adj=-1'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return HijriCalendar.fromJson(data);
    } else {
      throw Exception('Failed to load hijri calendar');
    }
  }
}
