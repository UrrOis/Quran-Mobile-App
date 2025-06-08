import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/prayer_time_page.dart';
import 'pages/location_page.dart';
import 'pages/currency_converter_page.dart';
import 'pages/settings_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoMoslem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/prayer_time': (context) => PrayerTimePage(),
        '/location': (context) => LocationPage(),
        '/currency_converter': (context) => CurrencyConverterPage(),
        '/settings': (context) => SettingsPage(),
        // Tambahkan route lain sesuai kebutuhan
      },
    );
  }
}
