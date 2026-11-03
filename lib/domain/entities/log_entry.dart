enum LogType { food, water }

sealed class LogEntry {
  const LogEntry({
    required this.id,
    required this.userId,
    required this.timestamp,
  });

  final String id;
  final String userId;

  final int timestamp;

  LogType get type;

  Map<String, dynamic> toMap();

  factory LogEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    final resolvedId = id ?? (map['id'] as String?) ?? '';
    final userId = (map['userId'] as String?) ?? '';
    final rawTimestamp = map['timestamp'];
    final timestamp = rawTimestamp is num
        ? rawTimestamp.toInt()
        : int.tryParse('$rawTimestamp') ??
              DateTime.now().millisecondsSinceEpoch;

    if (map['type'] == 'water') {
      return WaterLog(
        id: resolvedId,
        userId: userId,
        timestamp: timestamp,
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
      );
    }

    final nutrients = map['nutrients'];
    return FoodLog(
      id: resolvedId,
      userId: userId,
      timestamp: timestamp,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      description: (map['description'] as String?) ?? 'Food',
      imageUrl: map['imageUrl'] as String?,
      nutrients: nutrients is Map
          ? Nutrients.fromMap(Map<String, dynamic>.from(nutrients))
          : null,
    );
  }
}

class Nutrients {
  const Nutrients({this.protein = 0, this.carbs = 0, this.fat = 0});

  final double protein;
  final double carbs;
  final double fat;

  factory Nutrients.fromMap(Map<String, dynamic> map) => Nutrients(
    protein: (map['protein'] as num?)?.toDouble() ?? 0,
    carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
    fat: (map['fat'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
}

final class FoodLog extends LogEntry {
  const FoodLog({
    required super.id,
    required super.userId,
    required super.timestamp,
    required this.calories,
    required this.description,
    this.imageUrl,
    this.nutrients,
  });

  final double calories;
  final String description;
  final String? imageUrl;
  final Nutrients? nutrients;

  @override
  LogType get type => LogType.food;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': 'food',
    'timestamp': timestamp,
    'calories': calories,
    'description': description,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (nutrients != null) 'nutrients': nutrients!.toMap(),
  };
}

final class WaterLog extends LogEntry {
  const WaterLog({
    required super.id,
    required super.userId,
    required super.timestamp,
    required this.amount,
  });

  final double amount;

  @override
  LogType get type => LogType.water;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': 'water',
    'timestamp': timestamp,
    'amount': amount,
  };
}
