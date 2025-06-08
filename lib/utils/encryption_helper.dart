import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mengatur enkripsi dan session untuk login dan penyimpanan password
class EncryptionHelper {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveSession(String email) async {
    await _storage.write(key: 'session_email', value: email);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: 'session_email');
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: 'session_email');
  }
}
