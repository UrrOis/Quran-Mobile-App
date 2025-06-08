// Widget untuk menampilkan hasil konversi uang
import 'package:flutter/material.dart';
import '../api/currency_api_service.dart';
import '../api/models/currency_rates.dart';

/// Widget for converting between IDR, USD, JPY, and TRY using locally fetched rates.
class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({Key? key}) : super(key: key);

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final List<String> _currencies = ['IDR', 'USD', 'JPY', 'TRY'];
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double _inputAmount = 1.0;
  double? _convertedAmount;
  CurrencyRates? _rates;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  /// Fetches the latest currency rates from the API.
  Future<void> _fetchRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rates = await CurrencyApiService.fetchRates();
      setState(() {
        _rates = rates;
        _loading = false;
      });
      _convert();
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch rates.';
        _loading = false;
      });
    }
  }

  /// Converts the input amount from [_fromCurrency] to [_toCurrency] using local rates.
  void _convert() {
    if (_rates == null) return;
    final fromRate = _rates!.rates[_fromCurrency];
    final toRate = _rates!.rates[_toCurrency];
    if (fromRate == null || toRate == null) {
      setState(() => _convertedAmount = null);
      return;
    }
    setState(() {
      _convertedAmount = _inputAmount / fromRate * toRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    items:
                        _currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _fromCurrency = val!);
                      _convert();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    items:
                        _currencies
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _toCurrency = val!);
                      _convert();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                final parsed = double.tryParse(val);
                setState(() => _inputAmount = parsed ?? 0.0);
                _convert();
              },
            ),
            const SizedBox(height: 16),
            if (_convertedAmount != null)
              Text(
                '$_inputAmount $_fromCurrency = ${_convertedAmount!.toStringAsFixed(2)} $_toCurrency',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchRates,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Rates'),
            ),
          ],
        ),
      ),
    );
  }
}
