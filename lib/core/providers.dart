import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../data/auth_service.dart';
import '../data/repositories/firebase_log_repository.dart';
import '../data/repositories/firebase_user_repository.dart';
import '../data/repositories/gemini_food_analysis_repository.dart';
import '../domain/repositories/food_analysis_repository.dart';
import '../domain/repositories/log_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/usecases/add_food_log_use_case.dart';
import '../domain/usecases/add_water_log_use_case.dart';
import '../domain/usecases/analyze_food_use_case.dart';
import '../domain/usecases/create_default_profile_use_case.dart';
import '../domain/usecases/delete_log_use_case.dart';
import '../domain/usecases/subscribe_logs_use_case.dart';
import '../domain/usecases/subscribe_profile_use_case.dart';
import '../domain/usecases/update_goal_use_case.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final userRepositoryProvider = Provider<IUserRepository>(
  (ref) => FirebaseUserRepository(),
);

final logRepositoryProvider = Provider<ILogRepository>(
  (ref) => FirebaseLogRepository(),
);

final foodAnalysisRepositoryProvider = Provider<IFoodAnalysisRepository>(
  (ref) => GeminiFoodAnalysisRepository(
    apiKey: AppConfig.geminiApiKey,
    model: AppConfig.geminiModel,
  ),
);

// Use cases (domain core).
final subscribeLogsUseCaseProvider = Provider<SubscribeLogsUseCase>(
  (ref) => SubscribeLogsUseCase(ref.watch(logRepositoryProvider)),
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

final subscribeProfileUseCaseProvider = Provider<SubscribeProfileUseCase>(
  (ref) => SubscribeProfileUseCase(ref.watch(userRepositoryProvider)),
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
