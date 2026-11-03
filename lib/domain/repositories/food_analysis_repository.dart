import '../entities/food_analysis.dart';

abstract interface class IFoodAnalysisRepository {
  Future<FoodAnalysis> analyzeFood(String base64Image);
}
