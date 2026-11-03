import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/log_entry.dart';
import '../../domain/repositories/log_repository.dart';

class FirebaseLogRepository implements ILogRepository {
  FirebaseLogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _logs => _db.collection('logs');

  @override
  Stream<List<LogEntry>> watchLogs(String userId) {
    return _logs
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LogEntry.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<void> addLog(LogEntry log) {
    return _logs.doc(log.id).set(log.toMap());
  }

  @override
  Future<void> deleteLog(String logId) {
    return _logs.doc(logId).delete();
  }
}
