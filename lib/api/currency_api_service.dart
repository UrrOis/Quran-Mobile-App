import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/currency_rates.dart';

/// Service class to fetch currency rates from the Free Currency API.
/// Only supports IDR, USD, JPY, and TRY.
class CurrencyApiService {
  /// The endpoint for the Free Currency API.
  static const String _endpoint =
      'https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_fDjfUKJiRGRuxjWjqhu0HNdXb4u7GtxQSdNlOsRL&currencies=IDR,USD,JPY,TRY';

  /// Fetches the latest currency rates.
  /// Throws an [Exception] if the request fails or the response is invalid.
  static Future<CurrencyRates> fetchRates() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The API may return rates under a 'data' key
      final ratesJson = data['data'] ?? data;
      return CurrencyRates.fromJson({
        'base': data['query']?['base_currency'] ?? 'USD',
        'date': data['meta']?['last_updated_at'] ?? '',
        'rates': ratesJson,
      });
    } else {
      throw Exception('Failed to fetch currency rates');
    }
  }
}
