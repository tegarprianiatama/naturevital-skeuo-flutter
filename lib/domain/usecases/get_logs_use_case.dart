import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

class GetLogsUseCase {
  const GetLogsUseCase(this._repository);

  final ILogRepository _repository;

  Future<List<LogEntry>> call(String userId) => _repository.fetchLogs(userId);
}
