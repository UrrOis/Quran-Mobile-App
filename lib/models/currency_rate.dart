// Model untuk data kurs mata uang utama (IDR, USD, JPY, TRY)
// Digunakan untuk menyimpan kurs yang diambil dari API
class CurrencyRate {
  final Map<String, double> rates;

  CurrencyRate({required this.rates});

  // Membuat instance dari JSON API, hanya mengambil 4 mata uang utama
  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final filtered = <String, double>{};
    for (var code in ['IDR', 'USD', 'JPY', 'TRY']) {
      if (data.containsKey(code)) {
        filtered[code] = (data[code] as num).toDouble();
      }
    }
    return CurrencyRate(rates: filtered);
  }
}
