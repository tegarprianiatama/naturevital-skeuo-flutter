import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

class AddWaterLogUseCase {
  const AddWaterLogUseCase(this._repository);

  final ILogRepository _repository;

  Future<void> call(String userId, double amount) {
    final log = WaterLog(
      id: _generateId(),
      userId: userId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      amount: amount,
    );
    return _repository.addLog(log);
  }

  String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    return now.substring(now.length - 9);
  }
}
