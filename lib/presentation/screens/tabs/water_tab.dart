import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_config.dart';
import '../../../core/skeuo_theme.dart';
import '../../../domain/entities/log_entry.dart';
import '../../state/app_controller.dart';
import '../../widgets/skeuo_surface.dart';
import '../../widgets/ui_text.dart';
import '../../widgets/water_tracker.dart';

class WaterTab extends ConsumerWidget {
  const WaterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final waterEntries = state.todayWaterEntries;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        WaterTracker(
          current: state.todayWater,
          goal: state.profile?.waterGoal ?? AppConfig.defaultWaterGoal,
          onAdd: controller.addWater,
        ),
        const SizedBox(height: 16),
        SkeuoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeuoLabel("Today's Intake"),
              const SizedBox(height: 12),
              if (waterEntries.isEmpty)
                const EmptyState(message: 'Hydration is key! Drink some water.')
              else
                for (final log in waterEntries) ...[
                  SkeuoInset(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          size: 16,
                          color: Skeuo.accent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(log as WaterLog).amount.round()}ml',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(log.timestamp),
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Skeuo.textMuted,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.deleteLog(log.id),
                          iconSize: 15,
                          color: const Color(0xFFFCA5A5),
                          splashRadius: 18,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
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
