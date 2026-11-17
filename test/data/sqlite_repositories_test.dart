import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturevital_skeuo/data/local/app_database.dart';
import 'package:naturevital_skeuo/data/local/local_photo_store.dart';
import 'package:naturevital_skeuo/data/repositories/sqflite_log_repository.dart';
import 'package:naturevital_skeuo/data/repositories/sqflite_user_repository.dart';
import 'package:naturevital_skeuo/domain/entities/log_entry.dart';
import 'package:naturevital_skeuo/domain/entities/user_profile.dart';
import 'package:naturevital_skeuo/domain/repositories/user_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late AppDatabase appDatabase;
  Directory? photoDir;
  late LocalPhotoStore photoStore;
  late SqfliteLogRepository logRepository;
  late SqfliteUserRepository userRepository;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    final schema = await File('assets/sql/schema_v1.sql').readAsString();
    await AppDatabase.applyScript(db, schema);

    appDatabase = AppDatabase.forTesting(db);
    photoDir = await Directory.systemTemp.createTemp('naturevital_test_');
    photoStore = LocalPhotoStore(root: photoDir);
    logRepository = SqfliteLogRepository(
      database: appDatabase,
      photoStore: photoStore,
    );
    userRepository = SqfliteUserRepository(database: appDatabase);
  });

  tearDown(() async {
    await db.close();
    final dir = photoDir;
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  test('food log round-trips with flattened nutrients', () async {
    await logRepository.addLog(
      const FoodLog(
        id: 'food-1',
        userId: 'user-1',
        timestamp: 1000,
        calories: 250,
        description: 'Rice bowl',
        imageUrl: 'photo.jpg',
        nutrients: Nutrients(protein: 5, carbs: 30, fat: 2),
      ),
    );

    final logs = await logRepository.fetchLogs('user-1');

    expect(logs, hasLength(1));
    final food = logs.single as FoodLog;
    expect(food.id, 'food-1');
    expect(food.calories, 250);
    expect(food.description, 'Rice bowl');
    expect(food.imageUrl, 'photo.jpg');
    expect(food.nutrients!.protein, 5);
    expect(food.nutrients!.carbs, 30);
    expect(food.nutrients!.fat, 2);
  });

  test('water log round-trips and logs are newest first', () async {
    await logRepository.addLog(
      const WaterLog(
        id: 'water-1',
        userId: 'user-1',
        timestamp: 1000,
        amount: 250,
      ),
    );
    await logRepository.addLog(
      const FoodLog(
        id: 'food-2',
        userId: 'user-1',
        timestamp: 2000,
        calories: 100,
        description: 'Apple',
      ),
    );

    final logs = await logRepository.fetchLogs('user-1');

    expect(logs.map((log) => log.id), ['food-2', 'water-1']);
    expect((logs.last as WaterLog).amount, 250);
  });

  test('logs are scoped per user', () async {
    await logRepository.addLog(
      const WaterLog(
        id: 'a',
        userId: 'user-1',
        timestamp: 1,
        amount: 100,
      ),
    );
    await logRepository.addLog(
      const WaterLog(id: 'b', userId: 'user-2', timestamp: 2, amount: 200),
    );

    final logs = await logRepository.fetchLogs('user-1');

    expect(logs.map((log) => log.id), ['a']);
  });

  test('deleting a log removes its local photo file', () async {
    final fileName = await photoStore.save(
      Uint8List.fromList([1, 2, 3, 4]),
    );
    await logRepository.addLog(
      FoodLog(
        id: 'food-3',
        userId: 'user-1',
        timestamp: 1,
        calories: 10,
        description: 'Toast',
        imageUrl: fileName,
      ),
    );

    final photoFile = await photoStore.fileFor(fileName);
    expect(await photoFile.exists(), isTrue);

    await logRepository.deleteLog('food-3');

    expect(await logRepository.fetchLogs('user-1'), isEmpty);
    expect(await photoFile.exists(), isFalse);
  });

  test('profile is created, fetched and its goal updated', () async {
    expect(await userRepository.fetchProfile('user-1'), isNull);

    await userRepository.createDefaultProfile(
      const UserProfile(
        uid: 'user-1',
        displayName: 'Tegar',
        calorieGoal: 2200,
        waterGoal: 2500,
      ),
    );

    final created = await userRepository.fetchProfile('user-1');
    expect(created!.displayName, 'Tegar');
    expect(created.calorieGoal, 2200);

    await userRepository.updateGoal('user-1', GoalField.waterGoal, 3000);
    final updated = await userRepository.fetchProfile('user-1');

    expect(updated!.waterGoal, 3000);
    expect(updated.calorieGoal, 2200);
  });
}
