import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/skeuo_theme.dart';
import '../../state/app_controller.dart';
import '../../widgets/log_image.dart';
import '../../widgets/skeuo_button.dart';
import '../../widgets/skeuo_surface.dart';
import '../../widgets/ui_text.dart';
import '../open_camera.dart';

class FoodTab extends ConsumerWidget {
  const FoodTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final foodLogs = state.foodLogs;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MEAL HISTORY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
                color: Color(0xFF1F2937),
              ),
            ),
            SkeuoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onTap: () => openCamera(context),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (foodLogs.isEmpty)
          const EmptyState(
            message: 'No meals found. Start by scanning your food!',
          )
        else
          for (final foodLog in foodLogs) ...[
            SkeuoCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child:
                          (foodLog.imageUrl != null &&
                              foodLog.imageUrl!.isNotEmpty)
                          ? LogImage(
                              imageUrl: foodLog.imageUrl!,
                              fallback: const _FoodPlaceholder(),
                            )
                          : const _FoodPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    foodLog.description,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMM d, HH:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        foodLog.timestamp,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1,
                                      color: Skeuo.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '+${foodLog.calories.round()}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                color: Skeuo.orange,
                              ),
                            ),
                          ],
                        ),
                        if (foodLog.nutrients != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'P: ${foodLog.nutrients!.protein.round()}g   '
                            'C: ${foodLog.nutrients!.carbs.round()}g   '
                            'F: ${foodLog.nutrients!.fat.round()}g',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.deleteLog(foodLog.id),
                    iconSize: 16,
                    color: const Color(0xFFFCA5A5),
                    splashRadius: 18,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _FoodPlaceholder extends StatelessWidget {
  const _FoodPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: Skeuo.dialGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.add_rounded, size: 24, color: Skeuo.orange),
      ),
    );
  }
}
