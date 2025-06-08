import 'package:flutter/material.dart';
import '../api/models/city.dart';
import '../api/prayer_api_service.dart';

typedef OnCitySelected = void Function(City city);

class CitySearchWidget extends StatefulWidget {
  final OnCitySelected onCitySelected;
  const CitySearchWidget({Key? key, required this.onCitySelected})
    : super(key: key);

  @override
  State<CitySearchWidget> createState() => _CitySearchWidgetState();
}

class _CitySearchWidgetState extends State<CitySearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<City> _results = [];
  bool _loading = false;
  String? _error;

  void _searchCity(String keyword) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await PrayerApiService.searchCity(keyword);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mencari kota';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cari Kota',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple[800],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Masukkan nama kota...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.location_city, color: Colors.deepPurple),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.deepPurple),
                  onPressed: () => _searchCity(_controller.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onSubmitted: _searchCity,
            ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_error!, style: TextStyle(color: Colors.red)),
              ),
            if (_results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  children:
                      _results
                          .map(
                            (city) => Card(
                              color: Colors.deepPurple[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.place,
                                  color: Colors.deepPurple[700],
                                ),
                                title: Text(
                                  city.lokasi,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                onTap: () => widget.onCitySelected(city),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.deepPurple[400],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
