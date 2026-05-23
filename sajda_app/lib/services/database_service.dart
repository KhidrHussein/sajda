import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prayer.dart';
import '../models/prayer_log.dart';
import '../models/streak.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sajda.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE ios_blocked_apps (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              token TEXT NOT NULL UNIQUE
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE app_settings ADD COLUMN play_adhan INTEGER NOT NULL DEFAULT 0'
          );
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE app_settings ADD COLUMN calculation_method TEXT NOT NULL DEFAULT "muslim_world_league"');
          await db.execute('ALTER TABLE app_settings ADD COLUMN madhab TEXT NOT NULL DEFAULT "shafi"');
          await db.execute('ALTER TABLE app_settings ADD COLUMN fajr_offset INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE app_settings ADD COLUMN dhuhr_offset INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE app_settings ADD COLUMN asr_offset INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE app_settings ADD COLUMN maghrib_offset INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE app_settings ADD COLUMN isha_offset INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Prayer settings table
    await db.execute('''
      CREATE TABLE prayer_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    // Prayer logs table
    await db.execute('''
      CREATE TABLE prayer_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Streak table
    await db.execute('''
      CREATE TABLE streak (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_updated TEXT NOT NULL
      )
    ''');

    // App settings table
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        lock_duration_minutes INTEGER NOT NULL DEFAULT 10,
        grace_period_minutes INTEGER NOT NULL DEFAULT 5,
        play_adhan INTEGER NOT NULL DEFAULT 0,
        calculation_method TEXT NOT NULL DEFAULT 'muslim_world_league',
        madhab TEXT NOT NULL DEFAULT 'shafi',
        fajr_offset INTEGER NOT NULL DEFAULT 0,
        dhuhr_offset INTEGER NOT NULL DEFAULT 0,
        asr_offset INTEGER NOT NULL DEFAULT 0,
        maghrib_offset INTEGER NOT NULL DEFAULT 0,
        isha_offset INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // iOS blocked apps table
    await db.execute('''
      CREATE TABLE ios_blocked_apps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT NOT NULL UNIQUE
      )
    ''');
  }

  // Prayer Settings CRUD
  Future<int> createPrayer(Prayer prayer) async {
    final db = await database;
    return await db.insert('prayer_settings', prayer.toMap());
  }

  Future<List<Prayer>> getAllPrayers() async {
    final db = await database;
    final result = await db.query('prayer_settings');
    return result.map((map) => Prayer.fromMap(map)).toList();
  }

  Future<Prayer?> getPrayerByName(PrayerName name) async {
    final db = await database;
    final result = await db.query(
      'prayer_settings',
      where: 'name = ?',
      whereArgs: [name.name],
    );
    if (result.isEmpty) return null;
    return Prayer.fromMap(result.first);
  }

  Future<int> updatePrayer(Prayer prayer) async {
    final db = await database;
    return await db.update(
      'prayer_settings',
      prayer.toMap(),
      where: 'id = ?',
      whereArgs: [prayer.id],
    );
  }

  Future<int> deletePrayer(int id) async {
    final db = await database;
    return await db.delete(
      'prayer_settings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Prayer Logs CRUD
  Future<int> createPrayerLog(PrayerLog log) async {
    final db = await database;
    return await db.insert('prayer_logs', log.toMap());
  }

  Future<List<PrayerLog>> getPrayerLogsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'prayer_logs',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
    );
    return result.map((map) => PrayerLog.fromMap(map)).toList();
  }

  Future<List<PrayerLog>> getPrayerLogsByPrayer(PrayerName prayerName) async {
    final db = await database;
    final result = await db.query(
      'prayer_logs',
      where: 'prayer_name = ?',
      whereArgs: [prayerName.name],
    );
    return result.map((map) => PrayerLog.fromMap(map)).toList();
  }

  Future<bool> isNewUser() async {
    final db = await database;
    final result = await db.query('prayer_logs', limit: 1);
    return result.isEmpty;
  }

  // Streak CRUD
  Future<int> createStreak(Streak streak) async {
    final db = await database;
    return await db.insert('streak', streak.toMap());
  }

  Future<Streak?> getStreak() async {
    final db = await database;
    final result = await db.query('streak', limit: 1);
    if (result.isEmpty) return null;
    return Streak.fromMap(result.first);
  }

  Future<int> updateStreak(Streak streak) async {
    final db = await database;
    return await db.update(
      'streak',
      streak.toMap(),
      where: 'id = ?',
      whereArgs: [streak.id],
    );
  }

  // App Settings CRUD
  Future<int> createAppSettings(AppSettings settings) async {
    final db = await database;
    return await db.insert('app_settings', settings.toMap());
  }

  Future<AppSettings?> getAppSettings() async {
    final db = await database;
    final result = await db.query('app_settings', limit: 1);
    if (result.isEmpty) return null;
    return AppSettings.fromMap(result.first);
  }

  Future<int> updateAppSettings(AppSettings settings) async {
    final db = await database;
    return await db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // iOS Blocked Apps CRUD
  Future<int> addBlockedApp(String token) async {
    final db = await database;
    return await db.insert(
      'ios_blocked_apps',
      {'token': token},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getBlockedApps() async {
    final db = await database;
    final result = await db.query('ios_blocked_apps');
    return result.map((row) => row['token'] as String).toList();
  }

  Future<int> removeBlockedApp(String token) async {
    final db = await database;
    return await db.delete(
      'ios_blocked_apps',
      where: 'token = ?',
      whereArgs: [token],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
