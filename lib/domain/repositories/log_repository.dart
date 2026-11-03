import '../entities/log_entry.dart';

abstract interface class ILogRepository {
  Stream<List<LogEntry>> watchLogs(String userId);

  Future<void> addLog(LogEntry log);

  Future<void> deleteLog(String logId);
}
