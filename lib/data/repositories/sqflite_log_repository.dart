import 'package:sqflite/sqflite.dart';

import '../../domain/entities/log_entry.dart';
import '../../domain/repositories/log_repository.dart';
import '../local/app_database.dart';
import '../local/local_photo_store.dart';

/// Raw-SQL implementation of [ILogRepository] backed by SQLite.
///
/// Every query is scoped by `userId` — the local equivalent of the old
/// `where('userId', isEqualTo: ...)` Firestore query.
class SqfliteLogRepository implements ILogRepository {
  SqfliteLogRepository({
    AppDatabase? database,
    LocalPhotoStore? photoStore,
  }) : _database = database ?? AppDatabase.instance,
       _photoStore = photoStore ?? LocalPhotoStore();

  final AppDatabase _database;
  final LocalPhotoStore _photoStore;

  @override
  Future<List<LogEntry>> fetchLogs(String userId) async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      'SELECT * FROM logs WHERE userId = ? ORDER BY timestamp DESC',
      [userId],
    );

    return rows
        .map((row) => LogEntry.fromMap(_entityMap(row), id: row['id'] as String?))
        .toList(growable: false);
  }

  @override
  Future<void> addLog(LogEntry log) async {
    final db = await _database.database;
    await db.insert(
      'logs',
      _rowFromLog(log),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteLog(String logId) async {
    final db = await _database.database;
    final rows = await db.query(
      'logs',
      columns: ['imageUrl'],
      where: 'id = ?',
      whereArgs: [logId],
      limit: 1,
    );

    if (rows.isEmpty) return;

    final imageUrl = rows.first['imageUrl'] as String?;
    if (imageUrl != null && _isLocalFileName(imageUrl)) {
      await _photoStore.delete(imageUrl);
    }

    await db.delete('logs', where: 'id = ?', whereArgs: [logId]);
  }

  /// SQLite columns are flat; [LogEntry.fromMap] expects nutrients nested in a
  /// `nutrients` map, so rebuild that shape before delegating to the entity.
  Map<String, dynamic> _entityMap(Map<String, Object?> row) {
    final map = Map<String, dynamic>.from(row);

    final protein = row['protein'] as num?;
    final carbs = row['carbs'] as num?;
    final fat = row['fat'] as num?;
    if (protein != null || carbs != null || fat != null) {
      map['nutrients'] = {
        'protein': protein ?? 0,
        'carbs': carbs ?? 0,
        'fat': fat ?? 0,
      };
    }
    map.remove('protein');
    map.remove('carbs');
    map.remove('fat');

    return map;
  }

  /// Flattens a [LogEntry] into one SQLite row (nutrients → three columns).
  Map<String, Object?> _rowFromLog(LogEntry log) {
    final row = <String, Object?>{
      'id': log.id,
      'userId': log.userId,
      'timestamp': log.timestamp,
      'type': log.type == LogType.water ? 'water' : 'food',
      'calories': null,
      'description': null,
      'imageUrl': null,
      'protein': null,
      'carbs': null,
      'fat': null,
      'amount': null,
    };

    switch (log) {
      case FoodLog():
        row['calories'] = log.calories;
        row['description'] = log.description;
        row['imageUrl'] = log.imageUrl;
        row['protein'] = log.nutrients?.protein;
        row['carbs'] = log.nutrients?.carbs;
        row['fat'] = log.nutrients?.fat;
      case WaterLog():
        row['amount'] = log.amount;
    }

    return row;
  }

  /// Local photos are stored by file name; legacy Firestore values were data
  /// URIs or http URLs and must not be treated as files.
  bool _isLocalFileName(String imageUrl) {
    return !imageUrl.startsWith('http') && !imageUrl.startsWith('data:');
  }
}
