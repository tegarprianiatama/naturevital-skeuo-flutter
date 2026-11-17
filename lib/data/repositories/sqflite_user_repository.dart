import 'package:sqflite/sqflite.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../local/app_database.dart';

/// Raw-SQL implementation of [IUserRepository] backed by SQLite.
class SqfliteUserRepository implements IUserRepository {
  SqfliteUserRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    final db = await _database.database;
    final rows = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(rows.first));
  }

  @override
  Future<void> createDefaultProfile(UserProfile profile) async {
    final db = await _database.database;
    await db.insert(
      'users',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateGoal(
    String userId,
    GoalField field,
    double value,
  ) async {
    final db = await _database.database;
    await db.update(
      'users',
      {field.columnName: value},
      where: 'uid = ?',
      whereArgs: [userId],
    );
  }
}
