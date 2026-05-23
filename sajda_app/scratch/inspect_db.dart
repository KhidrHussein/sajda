import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  // Find the database path
  // Usually on Windows it's in AppData\Local\sajda_app\databases
  // But since we are running in the workspace, it might be different.
  // Actually, sqflite uses a default path.
  
  final dbPath = 'C:\\Users\\Hp\\AppData\\Roaming\\com.sajda.sajda_app\\databases\\sajda.db';
  if (!File(dbPath).existsSync()) {
    print('Database not found at $dbPath');
    return;
  }

  var db = await databaseFactory.openDatabase(dbPath);
  
  print('--- APP SETTINGS ---');
  var settings = await db.query('app_settings');
  print(settings);
  
  print('\n--- PRAYERS ---');
  var prayers = await db.query('prayers');
  print(prayers);
  
  print('\n--- PRAYER LOGS ---');
  var logs = await db.query('prayer_logs');
  print(logs);
  
  await db.close();
}
