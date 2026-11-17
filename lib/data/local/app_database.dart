import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the single SQLite connection used by the app.
///
/// The schema is a real SQL script stored under `assets/sql/` so it can be
/// read, copied and executed by hand (e.g. in DB Browser for SQLite) without
/// any code generation step.
class AppDatabase {
  AppDatabase._();

  /// Used by tests to share a pre-opened (e.g. in-memory) database.
  AppDatabase.forTesting(Database database) {
    _db = database;
  }

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'naturevital.db';
  static const _version = 1;
  static const _schemaAsset = 'assets/sql/schema_v1.sql';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final path = p.join(await getDatabasesPath(), _fileName);
    final db = await openDatabase(
      path,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await _runScript(db, await rootBundle.loadString(_schemaAsset));
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future migrations live here as plain SQL, e.g.:
        // if (oldVersion < 2) {
        //   await _runScript(db, await rootBundle.loadString(
        //     'assets/sql/migrate_v2.sql',
        //   ));
        // }
      },
    );

    _db = db;
    return db;
  }

  /// Runs a multi-statement SQL script. Full-line `--` comments are stripped
  /// before splitting on semicolons so comment text can never break a script.
  static Future<void> applyScript(Database db, String script) =>
      _runScript(db, script);

  static Future<void> _runScript(Database db, String script) async {
    final withoutComments = script
        .split('\n')
        .where((line) => !line.trim().startsWith('--'))
        .join('\n');

    final statements = withoutComments
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (final statement in statements) {
      await db.execute(statement);
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
