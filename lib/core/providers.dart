import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../data/auth_service.dart';
import '../data/backup_service.dart';
import '../data/local/app_database.dart';
import '../data/local/local_photo_store.dart';
import '../data/repositories/gemini_food_analysis_repository.dart';
import '../data/repositories/sqflite_log_repository.dart';
import '../data/repositories/sqflite_user_repository.dart';
import '../domain/repositories/food_analysis_repository.dart';
import '../domain/repositories/log_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/add_food_log_use_case.dart';
import '../domain/usecases/add_water_log_use_case.dart';
import '../domain/usecases/analyze_food_use_case.dart';
import '../domain/usecases/create_default_profile_use_case.dart';
import '../domain/usecases/delete_log_use_case.dart';
import '../domain/usecases/get_logs_use_case.dart';
import '../domain/usecases/get_profile_use_case.dart';
import '../domain/usecases/update_goal_use_case.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

final localPhotoStoreProvider = Provider<LocalPhotoStore>(
  (ref) => LocalPhotoStore(),
);

final userRepositoryProvider = Provider<IUserRepository>(
  (ref) => SqfliteUserRepository(database: ref.watch(appDatabaseProvider)),
);

final logRepositoryProvider = Provider<ILogRepository>(
  (ref) => SqfliteLogRepository(
    database: ref.watch(appDatabaseProvider),
    photoStore: ref.watch(localPhotoStoreProvider),
  ),
);

final foodAnalysisRepositoryProvider = Provider<IFoodAnalysisRepository>(
  (ref) => GeminiFoodAnalysisRepository(
    apiKey: AppConfig.geminiApiKey,
    model: AppConfig.geminiModel,
  ),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    database: ref.watch(appDatabaseProvider),
    photoStore: ref.watch(localPhotoStoreProvider),
  ),
);

// Use cases (domain core).
final getLogsUseCaseProvider = Provider<GetLogsUseCase>(
  (ref) => GetLogsUseCase(ref.watch(logRepositoryProvider)),
);

final addFoodLogUseCaseProvider = Provider<AddFoodLogUseCase>(
  (ref) => AddFoodLogUseCase(ref.watch(logRepositoryProvider)),
);

final addWaterLogUseCaseProvider = Provider<AddWaterLogUseCase>(
  (ref) => AddWaterLogUseCase(ref.watch(logRepositoryProvider)),
);

final deleteLogUseCaseProvider = Provider<DeleteLogUseCase>(
  (ref) => DeleteLogUseCase(ref.watch(logRepositoryProvider)),
);

final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.watch(userRepositoryProvider)),
);

final updateGoalUseCaseProvider = Provider<UpdateGoalUseCase>(
  (ref) => UpdateGoalUseCase(ref.watch(userRepositoryProvider)),
);

final createDefaultProfileUseCaseProvider =
    Provider<CreateDefaultProfileUseCase>(
      (ref) => CreateDefaultProfileUseCase(ref.watch(userRepositoryProvider)),
    );

final analyzeFoodUseCaseProvider = Provider<AnalyzeFoodUseCase>(
  (ref) => AnalyzeFoodUseCase(ref.watch(foodAnalysisRepositoryProvider)),
);
