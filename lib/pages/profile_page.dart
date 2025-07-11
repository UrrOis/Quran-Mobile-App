// Halaman untuk memperbarui data diri pengguna dan menghapus akun
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';
import 'home_page.dart';
import 'prayer_time_page.dart';
import 'location_page.dart';
import 'currency_converter_page.dart';
import 'settings_page.dart';
import 'quran_page.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  int _selectedIndex = 1; // Profile tab
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userMap = await AuthApi().getUserData();
    setState(() {
      _user = userMap != null ? User.fromMap(userMap) : null;
      if (_user != null && _user!.photo != null && _user!.photo!.isNotEmpty) {
        final file = File(_user!.photo!);
        if (file.existsSync()) {
          _profileImage = file;
        } else {
          _profileImage = null;
        }
      } else {
        _profileImage = null;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // Simpan path foto ke database
      if (_user != null && pickedFile.path.isNotEmpty) {
        await AuthApi().updateUser(userId: _user!.id!, photo: pickedFile.path);
        await _loadUser();
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) return;
    Widget page;
    switch (index) {
      case 0:
        page = HomePage();
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
        page = ProfilePage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showUpdateDialog() async {
    String newName = '';
    String newEmail = '';
    String newPassword = '';
    String confirmPassword = '';
    String? errorMsg;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                    ),
                    obscureText: true,
                    onChanged: (v) => confirmPassword = v,
                  ),
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMsg!,
                        style: TextStyle(color: Colors.red),
                      ),
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
                    if (newPassword.isNotEmpty &&
                        newPassword != confirmPassword) {
                      setState(
                        () => errorMsg = 'Password dan konfirmasi tidak sama',
                      );
                      return;
                    }
                    if (newName.isNotEmpty ||
                        newEmail.isNotEmpty ||
                        newPassword.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id');
                      if (userId != null) {
                        final updated = await AuthApi().updateUser(
                          userId: userId,
                          name: newName.isNotEmpty ? newName : null,
                          email: newEmail.isNotEmpty ? newEmail : null,
                          password: newPassword.isNotEmpty ? newPassword : null,
                        );
                        if (updated) {
                          setState(() => errorMsg = null);
                          await _loadUser();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Data berhasil diupdate!')),
                          );
                        } else {
                          setState(() => errorMsg = 'Gagal update data!');
                        }
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPesanKesanDialog() async {
    String pesan = _user?.pesan ?? '';
    String kesan = _user?.kesan ?? '';
    String? errorMsg;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pesan & Kesan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Pesan'),
                    controller: TextEditingController(text: pesan),
                    onChanged: (v) => pesan = v,
                    maxLines: 2,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Kesan'),
                    controller: TextEditingController(text: kesan),
                    onChanged: (v) => kesan = v,
                    maxLines: 2,
                  ),
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMsg!,
                        style: TextStyle(color: Colors.red),
                      ),
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
                    if (_user == null) return;
                    final updated = await AuthApi().updateUser(
                      userId: _user!.id!,
                      name: null,
                      email: null,
                      password: null,
                      pesan: pesan,
                      kesan: kesan,
                    );
                    if (updated) {
                      setState(() => errorMsg = null);
                      await _loadUser();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pesan & Kesan berhasil disimpan!'),
                        ),
                      );
                    } else {
                      setState(() => errorMsg = 'Gagal menyimpan!');
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Saya')),
      body:
          _user == null
              ? Center(child: CircularProgressIndicator())
              : ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.deepPurple[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepPurple[100],
                            backgroundImage:
                                _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : (_user?.photo != null &&
                                        _user!.photo!.isNotEmpty)
                                    ? FileImage(File(_user!.photo!))
                                    : null,
                            child:
                                (_profileImage == null &&
                                        (_user?.photo == null ||
                                            _user!.photo!.isEmpty))
                                    ? Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Colors.deepPurple[400],
                                    )
                                    : null,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.camera_alt),
                                label: Text('Kamera'),
                                onPressed: () => _pickImage(ImageSource.camera),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: Icon(Icons.photo),
                                label: Text('Galeri'),
                                onPressed:
                                    () => _pickImage(ImageSource.gallery),
                              ),
                              if (_user?.photo != null &&
                                  _user!.photo!.isNotEmpty)
                                SizedBox(width: 8),
                              if (_user?.photo != null &&
                                  _user!.photo!.isNotEmpty)
                                ElevatedButton.icon(
                                  icon: Icon(Icons.delete),
                                  label: Text('Hapus'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[300],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (_user != null) {
                                      await AuthApi().updateUser(
                                        userId: _user!.id!,
                                        photo: '',
                                      );
                                      setState(() {
                                        _profileImage = null;
                                      });
                                      await _loadUser();
                                    }
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _user!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.deepPurple[900],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _user!.email,
                            style: TextStyle(color: Colors.deepPurple[700]),
                          ),
                          if (_user!.pesan != null &&
                              _user!.pesan!.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Text(
                              'Pesan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            Text(
                              _user!.pesan!,
                              style: TextStyle(color: Colors.deepPurple[600]),
                            ),
                          ],
                          if (_user!.kesan != null &&
                              _user!.kesan!.isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              'Kesan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            Text(
                              _user!.kesan!,
                              style: TextStyle(color: Colors.deepPurple[600]),
                            ),
                          ],
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: Icon(Icons.edit),
                            label: Text('Edit Profil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _showUpdateDialog,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.delete),
                            label: Text('Hapus Akun'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: Text('Konfirmasi Hapus Akun'),
                                      content: Text(
                                        'Apakah Anda yakin ingin menghapus akun ini? Semua data akan hilang dan tidak bisa dikembalikan.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: Text('Hapus'),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true && _user != null) {
                                final result = await AuthApi().deleteUser(
                                  _user!.id!,
                                );
                                if (result) {
                                  await AuthApi().logout();
                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Akun berhasil dihapus.'),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal menghapus akun.'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_user != null) ...[
                    Card(
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _user?.pesan?.isNotEmpty == true
                                  ? _user!.pesan!
                                  : 'Belum ada pesan.',
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Kesan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _user?.kesan?.isNotEmpty == true
                                  ? _user!.kesan!
                                  : 'Belum ada kesan.',
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Edit Pesan & Kesan'),
                                onPressed: _showPesanKesanDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
