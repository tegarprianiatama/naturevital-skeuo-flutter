import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config.dart';
import '../../../core/skeuo_theme.dart';
import '../../state/app_controller.dart';
import '../../widgets/skeuo_surface.dart';
import '../../widgets/weekly_summary.dart';

class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(appControllerProvider.select((s) => s.weeklyData));
    final profile = ref.watch(appControllerProvider.select((s) => s.profile));
    final average = weekly.fold<double>(0, (sum, d) => sum + d.calories) / 7;
    final consistency =
        weekly.where((d) => d.calories > 0).length / weekly.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        WeeklySummary(
          data: weekly,
          goal: profile?.calorieGoal ?? AppConfig.defaultCalorieGoal,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Weekly Avg',
                value: average.round().toString(),
                unit: 'kcal / day',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'Consistency',
                value: '${(consistency * 100).round()}%',
                unit: 'Tracking Streak',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SkeuoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "COACH'S CORNER",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.4,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: Border(
                    left: BorderSide(color: Skeuo.accent, width: 4),
                  ),
                ),
                child: const Text(
                  '"Looks like your calorie intake was peak on Thursday! '
                  'Consider balancing your weekend with more water-rich snacks '
                  'like cucumber or watermelon."',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return SkeuoInset(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Skeuo.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            unit.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Skeuo.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
