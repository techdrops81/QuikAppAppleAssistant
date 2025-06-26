import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/app_info.dart';
import '../models/certificate.dart';
import '../models/profile.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quikapp_assistant.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Apps table
    await db.execute('''
      CREATE TABLE apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        bundleId TEXT NOT NULL UNIQUE,
        teamId TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Certificates table
    await db.execute('''
      CREATE TABLE certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        csrPath TEXT,
        keyPath TEXT,
        certificatePath TEXT,
        p12Path TEXT,
        p12Password TEXT,
        serialNumber TEXT,
        expiryDate TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        appId TEXT NOT NULL,
        certificateId TEXT,
        deviceIds TEXT,
        profilePath TEXT,
        uuid TEXT,
        expiryDate TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // App Info operations
  Future<int> insertApp(AppInfo app) async {
    final db = await database;
    return await db.insert('apps', app.toMap());
  }

  Future<List<AppInfo>> getAllApps() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('apps');
    return List.generate(maps.length, (i) => AppInfo.fromMap(maps[i]));
  }

  Future<AppInfo?> getAppById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apps',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AppInfo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateApp(AppInfo app) async {
    final db = await database;
    return await db.update(
      'apps',
      app.toMap(),
      where: 'id = ?',
      whereArgs: [app.id],
    );
  }

  Future<int> deleteApp(int id) async {
    final db = await database;
    return await db.delete('apps', where: 'id = ?', whereArgs: [id]);
  }

  // Certificate operations
  Future<int> insertCertificate(Certificate certificate) async {
    final db = await database;
    return await db.insert('certificates', certificate.toMap());
  }

  Future<List<Certificate>> getAllCertificates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('certificates');
    return List.generate(maps.length, (i) => Certificate.fromMap(maps[i]));
  }

  Future<Certificate?> getCertificateById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'certificates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Certificate.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCertificate(Certificate certificate) async {
    final db = await database;
    return await db.update(
      'certificates',
      certificate.toMap(),
      where: 'id = ?',
      whereArgs: [certificate.id],
    );
  }

  Future<int> deleteCertificate(int id) async {
    final db = await database;
    return await db.delete('certificates', where: 'id = ?', whereArgs: [id]);
  }

  // Profile operations
  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    return await db.insert('profiles', profile.toMap());
  }

  Future<List<Profile>> getAllProfiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profiles');
    return List.generate(maps.length, (i) => Profile.fromMap(maps[i]));
  }

  Future<Profile?> getProfileById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    return await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
