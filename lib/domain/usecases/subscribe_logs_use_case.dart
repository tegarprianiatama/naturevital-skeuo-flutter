import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

class SubscribeLogsUseCase {
  const SubscribeLogsUseCase(this._repository);

  final ILogRepository _repository;

  Stream<List<LogEntry>> call(String userId) => _repository.watchLogs(userId);
}
