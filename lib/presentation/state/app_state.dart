import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/log_entry.dart';
import '../../domain/entities/user_profile.dart';

enum AppTab { home, food, water, stats, settings }

class DailyCalories {
  const DailyCalories({required this.date, required this.calories});

  final DateTime date;
  final double calories;
}

class AppState {
  const AppState({
    this.user,
    this.loading = true,
    this.signingIn = false,
    this.profile,
    this.logs = const [],
    this.tab = AppTab.home,
    this.error,
  });

  final User? user;
  final bool loading;
  final bool signingIn;
  final UserProfile? profile;
  final List<LogEntry> logs;
  final AppTab tab;
  final String? error;

  AppState copyWith({
    User? user,
    bool clearUser = false,
    bool? loading,
    bool? signingIn,
    UserProfile? profile,
    List<LogEntry>? logs,
    AppTab? tab,
    String? error,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return AppState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      signingIn: signingIn ?? this.signingIn,
      profile: clearProfile ? null : (profile ?? this.profile),
      logs: logs ?? this.logs,
      tab: tab ?? this.tab,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<LogEntry> get todayEntries {
    final now = DateTime.now();
    return logs.where((log) {
      final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  double get todayCalories => todayEntries.fold(0, (sum, log) {
    return log is FoodLog ? sum + log.calories : sum;
  });

  double get todayWater => todayEntries.fold(0, (sum, log) {
    return log is WaterLog ? sum + log.amount : sum;
  });

  List<LogEntry> get todayWaterEntries =>
      todayEntries.whereType<WaterLog>().toList();

  List<FoodLog> get foodLogs =>
      logs.whereType<FoodLog>().toList(growable: false);

  List<DailyCalories> get weeklyData {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - index));
      final calories = logs
          .whereType<FoodLog>()
          .where((log) {
            final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day;
          })
          .fold<double>(0, (sum, log) => sum + log.calories);

      return DailyCalories(date: day, calories: calories);
    });
  }
}
