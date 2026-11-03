import 'package:flutter/material.dart';

import '../../core/skeuo_theme.dart';
import 'skeuo_button.dart';
import 'skeuo_surface.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({
    super.key,
    required this.current,
    required this.goal,
    required this.onAdd,
  });

  final double current;
  final double goal;
  final ValueChanged<double> onAdd;

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  double _customAmount = 250;

  @override
  Widget build(BuildContext context) {
    return SkeuoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeuoInset(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Skeuo.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Text(
                    '${widget.current.round()} / ${widget.goal.round()} ml',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Skeuo.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SkeuoButton(
                  variant: SkeuoButtonVariant.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => widget.onAdd(250),
                  child: const Column(
                    children: [
                      Text('+250', style: TextStyle(fontSize: 18)),
                      Text(
                        'Glass',
                        style: TextStyle(fontSize: 10, color: Skeuo.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkeuoButton(
                  variant: SkeuoButtonVariant.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: () => widget.onAdd(500),
                  child: const Column(
                    children: [
                      Text('+500', style: TextStyle(fontSize: 18)),
                      Text(
                        'Bottle',
                        style: TextStyle(fontSize: 10, color: Skeuo.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SkeuoInset(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        onTap: () => setState(
                          () => _customAmount = (_customAmount - 50).clamp(
                            50,
                            2000,
                          ),
                        ),
                      ),
                      Text(
                        '${_customAmount.round()} ml',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        onTap: () => setState(
                          () => _customAmount = (_customAmount + 50).clamp(
                            50,
                            2000,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SkeuoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                onTap: () => widget.onAdd(_customAmount),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: const Color(0xFF6B7280)),
      ),
    );
  }
}
