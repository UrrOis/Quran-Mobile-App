/// Model class for currency rates fetched from the Free Currency API.
/// Supports IDR, USD, JPY, and TRY.
class CurrencyRates {
  /// The base currency for the rates (e.g., 'USD').
  final String base;

  /// The date of the rates (ISO 8601 format).
  final String date;

  /// Map of currency codes to their rates relative to the base.
  final Map<String, double> rates;

  CurrencyRates({required this.base, required this.date, required this.rates});

  /// Factory constructor to create a [CurrencyRates] instance from JSON.
  /// Expects a JSON structure similar to:
  /// {
  ///   "base": "USD",
  ///   "date": "2023-06-07",
  ///   "rates": {"IDR": 16000.0, "USD": 1.0, "JPY": 150.0, "TRY": 32.0}
  /// }
  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final rates = <String, double>{};
    (json['rates'] as Map<String, dynamic>).forEach((key, value) {
      rates[key] = (value as num).toDouble();
    });
    return CurrencyRates(
      base: json['base'] as String,
      date: json['date'] as String,
      rates: rates,
    );
  }
}
