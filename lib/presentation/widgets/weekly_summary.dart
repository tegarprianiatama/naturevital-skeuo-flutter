import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/skeuo_theme.dart';
import '../state/app_state.dart';
import 'skeuo_surface.dart';

class WeeklySummary extends StatelessWidget {
  const WeeklySummary({super.key, required this.data, required this.goal});

  final List<DailyCalories> data;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final highest = data.fold<double>(
      0,
      (max, day) => math.max(max, day.calories),
    );
    final maxY = math.max(goal, highest) * 1.15;

    return SkeuoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Calories',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF374151),
            ),
          ),
          const Text(
            'Last 7 Days',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: Skeuo.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SkeuoInset(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY == 0 ? 100 : maxY,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('EEE').format(data[index].date),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < data.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data[i].calories,
                            width: 16,
                            color: data[i].calories > goal
                                ? Skeuo.danger
                                : Skeuo.accent,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${goal.round()} kcal',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Skeuo.textMuted,
                ),
              ),
              const Row(
                children: [
                  _LegendDot(color: Skeuo.accent, label: 'Under'),
                  SizedBox(width: 12),
                  _LegendDot(color: Skeuo.danger, label: 'Over Goal'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Skeuo.textMuted,
          ),
        ),
      ],
    );
  }
}
