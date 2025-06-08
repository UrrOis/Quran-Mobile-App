// Halaman untuk konversi mata uang
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'prayer_time_page.dart';
import 'location_page.dart';
import 'settings_page.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/currency_converter_widget.dart';

class CurrencyConverterPage extends StatefulWidget {
  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  int _selectedIndex = 5; // Currency tab

  void _onItemTapped(int index) {
    if (index == 5) return;
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
      case 6:
        page = SettingsPage();
        break;
      default:
        page = CurrencyConverterPage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Mata Uang'),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              color: Colors.deepPurple[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 48,
                      color: Colors.deepPurple[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Currency Converter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Konversi IDR, USD, JPY, dan TRY secara instan',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.deepPurple[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const CurrencyConverterWidget(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
