import 'package:flutter/material.dart';

import '../../core/skeuo_theme.dart';

class SkeuoCard extends StatelessWidget {
  const SkeuoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Skeuo.bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Skeuo.border),
        boxShadow: Skeuo.shadowOut,
      ),
      child: child,
    );
  }
}

class SkeuoInset extends StatelessWidget {
  const SkeuoInset({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: Skeuo.insetGradient,
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: child,
    );
  }
}

class SkeuoDial extends StatelessWidget {
  const SkeuoDial({
    super.key,
    required this.child,
    this.size,
    this.radius,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double? size;
  final double? radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
        gradient: Skeuo.dialGradient,
        boxShadow: Skeuo.shadowDial,
      ),
      child: child,
    );
  }
}
