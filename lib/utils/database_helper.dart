import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Mengatur semua interaksi dengan SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gomoslem.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        pesan TEXT,
        kesan TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE prayer_times (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        name TEXT,
        time TEXT
      )
    ''');
    // TODO: Tambah tabel lain jika perlu
  }

  // Tambah fungsi insert dan get user
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Ambil user berdasarkan id (untuk kebutuhan AuthApi)
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // Fungsi untuk insert/update jadwal sholat
  Future<void> upsertPrayerTime(int userId, String name, String time) async {
    final db = await instance.database;
    await db.insert('prayer_times', {
      'user_id': userId,
      'name': name,
      'time': time,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fungsi untuk ambil semua jadwal sholat utama user
  Future<Map<String, String>> getAllPrayerTimes(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'prayer_times',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return {
      for (var row in result) row['name'] as String: row['time'] as String,
    };
  }

  // Ambil semua jadwal custom (bukan jadwal sholat utama) untuk user
  Future<List<Map<String, dynamic>>> getCustomSchedules(int userId) async {
    final db = await instance.database;
    return await db.query(
      'prayer_times',
      where: "user_id = ? AND name NOT IN (?, ?, ?, ?, ?)",
      whereArgs: [userId, 'subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'],
    );
  }

  // Update jadwal custom
  Future<void> updateCustomSchedule(
    int id,
    int userId,
    String name,
    String time,
  ) async {
    final db = await instance.database;
    await db.update(
      'prayer_times',
      {'user_id': userId, 'name': name, 'time': time},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus jadwal custom
  Future<void> deleteCustomSchedule(int id) async {
    final db = await instance.database;
    await db.delete('prayer_times', where: 'id = ?', whereArgs: [id]);
  }
}
