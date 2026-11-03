class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.calorieGoal,
    required this.waterGoal,
  });

  final String uid;
  final String displayName;
  final double calorieGoal;
  final double waterGoal;

  UserProfile copyWith({
    String? uid,
    String? displayName,
    double? calorieGoal,
    double? waterGoal,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: (map['uid'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? 'User',
      calorieGoal: (map['calorieGoal'] as num?)?.toDouble() ?? 2200,
      waterGoal: (map['waterGoal'] as num?)?.toDouble() ?? 2500,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'displayName': displayName,
    'calorieGoal': calorieGoal,
    'waterGoal': waterGoal,
  };
}
