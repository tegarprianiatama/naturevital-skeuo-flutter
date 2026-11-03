import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements IUserRepository {
  FirebaseUserRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _profileRef(String userId) =>
      _db.collection('users').doc(userId);

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _profileRef(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserProfile.fromMap(data);
    });
  }

  @override
  Future<void> createDefaultProfile(UserProfile profile) {
    return _profileRef(profile.uid).set(profile.toMap());
  }

  @override
  Future<void> updateGoal(String userId, GoalField field, double value) {
    return _profileRef(userId)
        .set({field.firestoreName: value}, SetOptions(merge: true));
  }
}
