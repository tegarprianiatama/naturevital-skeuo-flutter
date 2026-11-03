class FoodAnalysis {
  const FoodAnalysis({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.reasoning,
  });

  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double confidence;
  final String reasoning;

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
      foodName: (json['foodName'] as String?) ?? 'Unknown food',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      reasoning: (json['reasoning'] as String?) ?? '',
    );
  }
}
