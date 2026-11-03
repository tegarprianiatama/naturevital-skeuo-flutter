import 'package:flutter/material.dart';

import '../../core/skeuo_theme.dart';

enum SkeuoButtonVariant { primary, secondary, inset }

class SkeuoButton extends StatefulWidget {
  const SkeuoButton({
    super.key,
    required this.child,
    this.onTap,
    this.variant = SkeuoButtonVariant.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.radius = 12,
    this.enabled = true,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final SkeuoButtonVariant variant;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool enabled;
  final Color? color;

  @override
  State<SkeuoButton> createState() => _SkeuoButtonState();
}

class _SkeuoButtonState extends State<SkeuoButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isInset = widget.variant == SkeuoButtonVariant.inset;
    final active = _pressed || isInset;

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: isInset ? null : Skeuo.bg,
              gradient: isInset ? Skeuo.insetGradient : null,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: active
                    ? const Color(0x22FFFFFF)
                    : const Color(0x4DFFFFFF),
              ),
              boxShadow: active ? const [] : Skeuo.shadowButton,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.color ??
                    (widget.variant == SkeuoButtonVariant.inset
                        ? const Color(0xFF6B7280)
                        : Skeuo.accent),
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.4,
                decoration: TextDecoration.none,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.color ??
                      (widget.variant == SkeuoButtonVariant.inset
                          ? const Color(0xFF6B7280)
                          : Skeuo.accent),
                  size: 20,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
