import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class CreateDefaultProfileUseCase {
  const CreateDefaultProfileUseCase(this._repository);

  final IUserRepository _repository;

  Future<void> call(
    String userId,
    String displayName,
    double defaultCalories,
    double defaultWater,
  ) {
    return _repository.createDefaultProfile(
      UserProfile(
        uid: userId,
        displayName: displayName.isEmpty ? 'User' : displayName,
        calorieGoal: defaultCalories,
        waterGoal: defaultWater,
      ),
    );
  }
}
