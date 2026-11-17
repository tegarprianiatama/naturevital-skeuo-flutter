import '../entities/user_profile.dart';

abstract interface class IUserRepository {
  /// Returns the stored profile, or null when the document does not exist.
  Future<UserProfile?> fetchProfile(String userId);

  Future<void> createDefaultProfile(UserProfile profile);

  Future<void> updateGoal(String userId, GoalField field, double value);
}

enum GoalField {
  calorieGoal('calorieGoal'),
  waterGoal('waterGoal');

  const GoalField(this.columnName);

  /// SQLite column name in the `users` table.
  final String columnName;
}
