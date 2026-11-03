import '../repositories/log_repository.dart';

class DeleteLogUseCase {
  const DeleteLogUseCase(this._repository);

  final ILogRepository _repository;

  Future<void> call(String logId) => _repository.deleteLog(logId);
}
