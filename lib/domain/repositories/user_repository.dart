import '../entities/user_profile.dart';

abstract interface class IUserRepository {
  Stream<UserProfile?> watchProfile(String userId);

  Future<void> createDefaultProfile(UserProfile profile);

  Future<void> updateGoal(String userId, GoalField field, double value);
}

enum GoalField {
  calorieGoal('calorieGoal'),
  waterGoal('waterGoal');

  const GoalField(this.firestoreName);

  final String firestoreName;
}
