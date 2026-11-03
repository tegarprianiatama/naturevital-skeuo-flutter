import '../repositories/user_repository.dart';

class UpdateGoalUseCase {
  const UpdateGoalUseCase(this._repository);

  final IUserRepository _repository;

  Future<void> call(String userId, GoalField field, double value) =>
      _repository.updateGoal(userId, field, value);
}
