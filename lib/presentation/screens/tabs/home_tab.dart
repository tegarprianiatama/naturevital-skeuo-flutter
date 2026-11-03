import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_config.dart';
import '../../../core/skeuo_theme.dart';
import '../../../domain/entities/log_entry.dart';
import '../../state/app_controller.dart';
import '../../state/app_state.dart';
import '../../widgets/gauge.dart';
import '../../widgets/skeuo_button.dart';
import '../../widgets/skeuo_surface.dart';
import '../../widgets/ui_text.dart';
import '../open_camera.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayCalories = ref.watch(
      appControllerProvider.select((s) => s.todayCalories),
    );
    final todayWater = ref.watch(
      appControllerProvider.select((s) => s.todayWater),
    );
    final profile = ref.watch(appControllerProvider.select((s) => s.profile));
    final recent = ref
        .watch(appControllerProvider.select((s) => s.todayEntries))
        .take(3)
        .toList();
    final controller = ref.read(appControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Gauge(
                value: todayCalories,
                max: profile?.calorieGoal ?? AppConfig.defaultCalorieGoal,
                label: 'Calories',
                unit: 'kcal',
                color: Skeuo.danger,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gauge(
                value: todayWater,
                max: profile?.waterGoal ?? AppConfig.defaultWaterGoal,
                label: 'Water',
                unit: 'ml',
                color: Skeuo.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SkeuoButton(
                padding: const EdgeInsets.symmetric(vertical: 20),
                onTap: () => openCamera(context),
                child: const Column(
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 24),
                    SizedBox(height: 6),
                    Text(
                      'SCAN FOOD',
                      style: TextStyle(fontSize: 9, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SkeuoButton(
                variant: SkeuoButtonVariant.secondary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                onTap: () => controller.setTab(AppTab.water),
                child: const Column(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 24),
                    SizedBox(height: 6),
                    Text(
                      'TRACK WATER',
                      style: TextStyle(fontSize: 9, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SkeuoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeuoLabel('Recent Activity'),
                  GestureDetector(
                    onTap: () => controller.setTab(AppTab.food),
                    child: const SkeuoLabel(
                      'View All',
                      color: Skeuo.accent,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                const EmptyState(message: 'No activity logged today.')
              else
                for (final log in recent) ...[
                  LogListTile(
                    icon: log is FoodLog
                        ? Icons.add_rounded
                        : Icons.water_drop_outlined,
                    iconColor: log is FoodLog ? Skeuo.orange : Skeuo.accent,
                    title: switch (log) {
                      FoodLog() => log.description,
                      WaterLog() => '${log.amount.round()}ml Water',
                    },
                    subtitle:
                        '${DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(log.timestamp))} • '
                        '${log is FoodLog ? '${log.calories.round()} kcal' : 'Intake'}',
                    onDelete: () => controller.deleteLog(log.id),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
