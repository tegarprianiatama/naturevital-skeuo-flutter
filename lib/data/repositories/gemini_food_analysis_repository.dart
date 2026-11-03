import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../domain/entities/food_analysis.dart';
import '../../domain/repositories/food_analysis_repository.dart';

class GeminiFoodAnalysisRepository implements IFoodAnalysisRepository {
  GeminiFoodAnalysisRepository({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
  });

  final String apiKey;
  final String model;

  static const _prompt = '''
Analyze this food image and provide an estimation of its nutritional content.
Return the response in JSON format with the following structure:
{
  "foodName": "string",
  "calories": number,
  "protein": number (grams),
  "carbs": number (grams),
  "fat": number (grams),
  "confidence": number (0-1),
  "reasoning": "string"
}
Be realistic and conservative with calorie estimates. If there are multiple items, sum them up.''';

  @override
  Future<FoodAnalysis> analyzeFood(String base64Image) async {
    if (apiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is not set. Run with '
        '--dart-define=GEMINI_API_KEY=<your key>.',
      );
    }

    final generativeModel = GenerativeModel(
      model: model,
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final response = await generativeModel.generateContent([
      Content.multi([
        DataPart('image/jpeg', base64Decode(base64Image)),
        TextPart(_prompt),
      ]),
    ]);

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw StateError('No response from AI');
    }

    return FoodAnalysis.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }
}
