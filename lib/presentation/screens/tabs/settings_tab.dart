import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/skeuo_theme.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../state/app_controller.dart';
import '../../widgets/skeuo_surface.dart';
import '../../widgets/ui_text.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final profile = state.profile;

    if (profile == null) {
      return const Center(
        child: CircularProgressIndicator(color: Skeuo.accent),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        SkeuoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeuoLabel(
                'Goals & Targets',
                italic: true,
                letterSpacing: 1.4,
              ),
              const SizedBox(height: 14),
              _GoalInput(
                label: 'DAILY CALORIES (KCAL)',
                value: profile.calorieGoal,
                onChanged: (value) =>
                    controller.updateGoal(GoalField.calorieGoal, value),
              ),
              const SizedBox(height: 14),
              _GoalInput(
                label: 'DAILY WATER (ML)',
                value: profile.waterGoal,
                onChanged: (value) =>
                    controller.updateGoal(GoalField.waterGoal, value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SkeuoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeuoLabel('Personal', italic: true, letterSpacing: 1.4),
              const SizedBox(height: 12),
              SkeuoInset(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Log Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    SkeuoDial(
                      size: 40,
                      child: IconButton(
                        onPressed: () => _confirmLogout(context, controller),
                        iconSize: 16,
                        color: const Color(0xFFEF4444),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.logout),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'Naturevital Skeuo V1.0.0',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              color: Skeuo.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AppController controller,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Skeuo.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('You can sign back in with Google any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOG OUT', style: TextStyle(color: Skeuo.danger)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await controller.signOut();
    }
  }
}

class _GoalInput extends StatefulWidget {
  const _GoalInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_GoalInput> createState() => _GoalInputState();
}

class _GoalInputState extends State<_GoalInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value.round().toString(),
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _GoalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != oldWidget.value) {
      _controller.text = widget.value.round().toString();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || parsed <= 0) {
      _controller.text = widget.value.round().toString();
      return;
    }
    if (parsed != widget.value) widget.onChanged(parsed);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: SkeuoLabel(
            widget.label,
            fontSize: 9,
            letterSpacing: 1.2,
            color: Skeuo.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        SkeuoInset(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _commit(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Skeuo.accent,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
