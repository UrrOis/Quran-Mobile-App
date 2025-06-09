// Halaman pengaturan aplikasi
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'prayer_time_page.dart';
import 'location_page.dart';
import 'currency_converter_page.dart';
import '../api/auth_api.dart';
import 'package:local_auth/local_auth.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 6; // Settings tab

  final LocalAuthentication auth = LocalAuthentication();
  bool _fingerprintEnabled = false;
  bool _loadingFingerprint = true;

  @override
  void initState() {
    super.initState();
    _loadFingerprintStatus();
  }

  Future<void> _loadFingerprintStatus() async {
    final enabled = await AuthApi().isFingerprintEnabled();
    setState(() {
      _fingerprintEnabled = enabled;
      _loadingFingerprint = false;
    });
  }

  Future<void> _enableFingerprint() async {
    bool canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint tidak tersedia di perangkat ini.')),
      );
      return;
    }
    bool authenticated = await auth.authenticate(
      localizedReason: 'Aktifkan fingerprint untuk aplikasi',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (authenticated) {
      await AuthApi().updateFingerprint();
      setState(() {
        _fingerprintEnabled = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fingerprint diaktifkan!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint gagal atau dibatalkan.')),
      );
    }
  }

  Future<void> _disableFingerprint() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Nonaktifkan Fingerprint?'),
            content: Text('Apakah Anda yakin ingin menonaktifkan fingerprint?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Ya'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await AuthApi().disableFingerprint();
      setState(() {
        _fingerprintEnabled = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fingerprint dinonaktifkan!')));
    }
  }

  Future<void> _showUpdateDialog() async {
    String newName = '';
    String newEmail = '';
    String newPassword = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Data Diri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nama Baru'),
                onChanged: (v) => newName = v,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email Baru'),
                onChanged: (v) => newEmail = v,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password Baru'),
                obscureText: true,
                onChanged: (v) => newPassword = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // TODO: Update ke database (validasi jika perlu)
                if (newName.isNotEmpty ||
                    newEmail.isNotEmpty ||
                    newPassword.isNotEmpty) {
                  // Panggil AuthApi().updateUser(newName, newEmail, newPassword)
                  // Tampilkan notifikasi sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Data berhasil diupdate!')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 6) return;
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
        page = SettingsPage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan')),
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
              leading: Icon(Icons.edit, color: Colors.deepPurple[400]),
              title: Text(
                'Ganti Nama, Email, Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              onTap: _showUpdateDialog,
            ),
          ),
          SizedBox(height: 10),
          Card(
            color: Colors.deepPurple[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: SwitchListTile(
              secondary: Icon(Icons.fingerprint, color: Colors.deepPurple[400]),
              title: Text(
                'Gunakan Fingerprint',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              value: _fingerprintEnabled,
              onChanged:
                  _loadingFingerprint
                      ? null
                      : (val) async {
                        if (val) {
                          await _enableFingerprint();
                        } else {
                          await _disableFingerprint();
                        }
                      },
            ),
          ),
          if (_fingerprintEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Card(
                color: Colors.deepPurple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.refresh, color: Colors.deepPurple[400]),
                  title: Text(
                    'Update Fingerprint',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),
                  onTap: _enableFingerprint,
                ),
              ),
            ),
          SizedBox(height: 10),
          Card(
            color: Colors.deepPurple[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.deepPurple[400]),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              onTap: () async {
                await AuthApi().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
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
