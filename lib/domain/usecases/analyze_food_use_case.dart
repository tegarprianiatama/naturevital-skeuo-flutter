import '../entities/food_analysis.dart';
import '../repositories/food_analysis_repository.dart';

class AnalyzeFoodUseCase {
  const AnalyzeFoodUseCase(this._repository);

  final IFoodAnalysisRepository _repository;

  Future<FoodAnalysis> call(String base64Image) =>
      _repository.analyzeFood(base64Image);
}
