import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/city.dart';
import 'models/prayer_schedule.dart';

class PrayerApiService {
  static const String baseUrl = 'https://api.myquran.com/v2/sholat';

  static Future<List<City>> searchCity(String keyword) async {
    final response = await http.get(Uri.parse('$baseUrl/kota/cari/$keyword'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        return (data['data'] as List)
            .map((item) => City.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  static Future<PrayerSchedule?> getPrayerSchedule(
    String cityId,
    String date,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/jadwal/$cityId/$date'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        return PrayerSchedule.fromJson(data['data']['jadwal']);
      }
    }
    return null;
  }
}
