import '../entities/food_analysis.dart';
import '../entities/log_entry.dart';
import '../repositories/log_repository.dart';

class AddFoodLogUseCase {
  const AddFoodLogUseCase(this._repository);

  final ILogRepository _repository;

  Future<void> call(String userId, FoodAnalysis analysis, String imageUrl) {
    final log = FoodLog(
      id: _generateId(),
      userId: userId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      calories: analysis.calories,
      description: analysis.foodName,
      imageUrl: imageUrl,
      nutrients: Nutrients(
        protein: analysis.protein,
        carbs: analysis.carbs,
        fat: analysis.fat,
      ),
    );
    return _repository.addLog(log);
  }

  String _generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer();
    var seed = random;
    for (var i = 0; i < 13; i++) {
      seed = seed * 1103515245 + 12345;
      buffer.write(chars[(seed.abs() >> 4) % chars.length]);
    }
    return buffer.toString();
  }
}
