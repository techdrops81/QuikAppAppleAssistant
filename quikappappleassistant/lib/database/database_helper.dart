import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/app_info.dart';
import '../models/certificate.dart';
import '../models/profile.dart';
import '../models/apple_account.dart';
import '../models/downloaded_file.dart';

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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Apps table
    await db.execute('''
      CREATE TABLE apps (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        bundleId TEXT NOT NULL,
        platform TEXT NOT NULL,
        teamId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Certificates table
    await db.execute('''
      CREATE TABLE certificates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        expirationDate INTEGER,
        teamId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        expirationDate INTEGER,
        teamId TEXT NOT NULL,
        appId TEXT,
        certificateIds TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Apple Accounts table
    await db.execute('''
      CREATE TABLE apple_accounts (
        id TEXT PRIMARY KEY,
        appleId TEXT NOT NULL,
        appSpecificPassword TEXT NOT NULL,
        displayName TEXT,
        createdAt INTEGER NOT NULL,
        lastUsedAt INTEGER NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Downloaded Files table
    await db.execute('''
      CREATE TABLE downloaded_files (
        id TEXT PRIMARY KEY,
        fileName TEXT NOT NULL,
        originalName TEXT NOT NULL,
        fileType TEXT NOT NULL,
        appleAccountId TEXT NOT NULL,
        certificateId TEXT,
        profileId TEXT,
        downloadedAt INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        isValid INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (appleAccountId) REFERENCES apple_accounts (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for Apple accounts and downloaded files
      await db.execute('''
        CREATE TABLE apple_accounts (
          id TEXT PRIMARY KEY,
          appleId TEXT NOT NULL,
          appSpecificPassword TEXT NOT NULL,
          displayName TEXT,
          createdAt INTEGER NOT NULL,
          lastUsedAt INTEGER NOT NULL,
          isActive INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE downloaded_files (
          id TEXT PRIMARY KEY,
          fileName TEXT NOT NULL,
          originalName TEXT NOT NULL,
          fileType TEXT NOT NULL,
          appleAccountId TEXT NOT NULL,
          certificateId TEXT,
          profileId TEXT,
          downloadedAt INTEGER NOT NULL,
          filePath TEXT NOT NULL,
          fileSize INTEGER NOT NULL,
          isValid INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (appleAccountId) REFERENCES apple_accounts (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Apple Account operations
  Future<int> insertAppleAccount(AppleAccount account) async {
    final db = await database;
    return await db.insert('apple_accounts', account.toMap());
  }

  Future<List<AppleAccount>> getAppleAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apple_accounts',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'lastUsedAt DESC',
    );
    return List.generate(maps.length, (i) => AppleAccount.fromMap(maps[i]));
  }

  Future<AppleAccount?> getAppleAccount(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apple_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AppleAccount.fromMap(maps.first);
    }
    return null;
  }

  Future<AppleAccount?> getActiveAppleAccount() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apple_accounts',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'lastUsedAt DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AppleAccount.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAppleAccount(AppleAccount account) async {
    final db = await database;
    return await db.update(
      'apple_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deactivateAppleAccount(String id) async {
    final db = await database;
    return await db.update(
      'apple_accounts',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAppleAccount(String id) async {
    final db = await database;
    return await db.delete('apple_accounts', where: 'id = ?', whereArgs: [id]);
  }

  // Downloaded Files operations
  Future<int> insertDownloadedFile(DownloadedFile file) async {
    final db = await database;
    return await db.insert('downloaded_files', file.toMap());
  }

  Future<List<DownloadedFile>> getDownloadedFiles({
    String? appleAccountId,
  }) async {
    final db = await database;
    String whereClause = 'isValid = ?';
    List<dynamic> whereArgs = [1];

    if (appleAccountId != null) {
      whereClause += ' AND appleAccountId = ?';
      whereArgs.add(appleAccountId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'downloaded_files',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'downloadedAt DESC',
    );
    return List.generate(maps.length, (i) => DownloadedFile.fromMap(maps[i]));
  }

  Future<DownloadedFile?> getDownloadedFile(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'downloaded_files',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DownloadedFile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateDownloadedFile(DownloadedFile file) async {
    final db = await database;
    return await db.update(
      'downloaded_files',
      file.toMap(),
      where: 'id = ?',
      whereArgs: [file.id],
    );
  }

  Future<int> deleteDownloadedFile(String id) async {
    final db = await database;
    return await db.delete(
      'downloaded_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> invalidateDownloadedFiles(String appleAccountId) async {
    final db = await database;
    return await db.update(
      'downloaded_files',
      {'isValid': 0},
      where: 'appleAccountId = ?',
      whereArgs: [appleAccountId],
    );
  }

  // Existing operations for apps, certificates, and profiles
  Future<int> insertApp(AppInfo app) async {
    final db = await database;
    return await db.insert('apps', app.toMap());
  }

  Future<List<AppInfo>> getApps() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('apps');
    return List.generate(maps.length, (i) => AppInfo.fromMap(maps[i]));
  }

  Future<int> insertCertificate(Certificate certificate) async {
    final db = await database;
    return await db.insert('certificates', certificate.toMap());
  }

  Future<List<Certificate>> getCertificates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('certificates');
    return List.generate(maps.length, (i) => Certificate.fromMap(maps[i]));
  }

  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    return await db.insert('profiles', profile.toMap());
  }

  Future<List<Profile>> getProfiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profiles');
    return List.generate(maps.length, (i) => Profile.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
