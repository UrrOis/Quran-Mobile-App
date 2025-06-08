import 'dart:convert';
import 'package:http/http.dart' as http;

// Untuk mengambil data lokasi menggunakan Google Maps API dan menentukan zona waktu pengguna.
class LocationApi {
  // TODO: Implementasi fetch lokasi, zona waktu, dan integrasi Google Maps

  // Contoh: Fetch lokasi dari Google Maps API
  Future<Map<String, dynamic>> fetchLocation(String keyword) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$keyword&key=AIzaSyD7utY0gRcb9NorPbcVfVxpF2Kk911RheU',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load location');
    }
  }

  // Contoh: Fetch zona waktu
  Future<Map<String, dynamic>> fetchTimeZone(double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/timezone/json?location=$lat,$lng&timestamp=${DateTime.now().millisecondsSinceEpoch ~/ 1000}&key=AIzaSyD7utY0gRcb9NorPbcVfVxpF2Kk911RheU',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load timezone');
    }
  }
}
