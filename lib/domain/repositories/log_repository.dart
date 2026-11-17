import '../entities/log_entry.dart';

abstract interface class ILogRepository {
  /// Returns the user's logs, newest first.
  Future<List<LogEntry>> fetchLogs(String userId);

  Future<void> addLog(LogEntry log);

  Future<void> deleteLog(String logId);
}
