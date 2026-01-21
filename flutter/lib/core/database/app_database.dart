import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'money_manager.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db,version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            is_synced INTEGER NOT NULL
            )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE transactions');

          await db.execute('''
            CREATE TABLE transactions(
              id TEXT PRIMARY KEY,
              amount REAL NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              is_synced INTEGER NOT NULL
              )
          ''');

        }
      }
    );

    return _db!;
  }
}