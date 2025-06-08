// Model untuk data konversi mata uang
class Currency {
  final String from;
  final String to;
  final double rate;

  Currency({required this.from, required this.to, required this.rate});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
    );
  }
}
