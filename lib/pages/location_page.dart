// Halaman untuk menampilkan lokasi pengguna dan melacaknya dengan Google Maps API
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'home_page.dart';
import 'profile_page.dart';
import 'prayer_time_page.dart';
import 'currency_converter_page.dart';
import 'settings_page.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class LocationPage extends StatefulWidget {
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String? _error;

  // Simulasi posisi user (misal: Jakarta)
  final LatLng _defaultPosition = LatLng(-6.200000, 106.816666);
  int _selectedIndex = 4; // Location tab

  void _onItemTapped(int index) {
    if (index == 4) return;
    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = ProfilePage();
        break;
      case 2:
        page = PrayerTimePage();
        break;
      case 3:
        page = QuranPage();
        break;
      case 4:
        page = LocationPage();
        break;
      case 5:
        page = CurrencyConverterPage();
        break;
      case 6:
        page = SettingsPage();
        break;
      default:
        page = LocationPage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void initState() {
    super.initState();
    // Simulasi: langsung set posisi default
    Future.delayed(Duration.zero, () {
      setState(() {
        _currentPosition = _defaultPosition;
      });
    });
  }

  void _showCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lokasi Saya')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepPurple[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.deepPurple[400]),
              title: Text(
                'Lihat Lokasi Saya',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              onTap: () => _showCurrentLocation(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
