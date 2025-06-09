import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/database_helper.dart';
import '../utils/bcrypt_helper.dart';
import '../utils/encryption_helper.dart';

// Untuk menangani API login, registrasi, dan autentikasi pengguna.
class AuthApi {
  // Login: cek ke database user dan simpan session terenkripsi
  Future<bool> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      final hashedPassword = result.first['password'] as String;
      if (BcryptHelper.checkPassword(password, hashedPassword)) {
        await EncryptionHelper.saveSession(email);
        // Simpan id user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', result.first['id'] as int);
        return true;
      }
    }
    return false;
  }

  // Register: simpan user baru ke database dengan password terenkripsi
  Future<bool> register(String name, String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existing.isNotEmpty) return false;
    final hashedPassword = BcryptHelper.hashPassword(password);
    await db.insert('users', {
      'name': name,
      'email': email,
      'password': hashedPassword,
      'pesan': '',
      'kesan': '',
    });
    return true;
  }

  // Logout: hapus session
  Future<void> logout() async {
    await EncryptionHelper.clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  // Cek session login
  Future<String?> getSession() async {
    return await EncryptionHelper.getSession();
  }

  // Ambil user dari SQLite berdasarkan id yang tersimpan di SharedPreferences
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) return null;
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Update user data (name, email, password, pesan, kesan, photo)
  Future<bool> updateUser({
    required int userId,
    String? name,
    String? email,
    String? password,
    String? pesan,
    String? kesan,
    String? photo,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final Map<String, dynamic> updateData = {};
    if (name != null && name.isNotEmpty) updateData['name'] = name;
    if (email != null && email.isNotEmpty) updateData['email'] = email;
    if (password != null && password.isNotEmpty) {
      updateData['password'] = BcryptHelper.hashPassword(password);
    }
    if (pesan != null) updateData['pesan'] = pesan;
    if (kesan != null) updateData['kesan'] = kesan;
    if (photo != null && photo.isNotEmpty) updateData['photo'] = photo;
    if (updateData.isEmpty) return false;
    final count = await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  }

  // Hapus user dari database berdasarkan id
  Future<bool> deleteUser(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final deleted = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return deleted > 0;
  }

  // Fingerprint: simpan preferensi fingerprint user
  Future<void> setFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', enabled);
  }

  Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprint_enabled') ?? false;
  }

  // Fungsi update fingerprint (dummy, karena update fingerprint biasanya diatur di device, bukan app)
  Future<bool> updateFingerprint() async {
    // Di aplikasi nyata, ini akan memicu proses autentikasi ulang fingerprint
    await setFingerprintEnabled(true);
    return true;
  }

  Future<bool> disableFingerprint() async {
    await setFingerprintEnabled(false);
    return true;
  }

  // Deteksi apakah device support fingerprint
  Future<bool> isDeviceSupportFingerprint() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }
}
