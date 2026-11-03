import 'package:flutter/material.dart';

import '../../core/skeuo_theme.dart';
import 'skeuo_surface.dart';

class SkeuoLabel extends StatelessWidget {
  const SkeuoLabel(
    this.text, {
    super.key,
    this.fontSize = 10,
    this.letterSpacing = 1.6,
    this.color = const Color(0xFF4B5563),
    this.italic = false,
  });

  final String text;
  final double fontSize;
  final double letterSpacing;
  final Color color;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
        color: color,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SkeuoInset(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Skeuo.textMuted,
        ),
      ),
    );
  }
}

class LogListTile extends StatelessWidget {
  const LogListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onDelete,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SkeuoInset(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SkeuoDial(
            size: 40,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Skeuo.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            iconSize: 16,
            color: const Color(0xFFFCA5A5),
            splashRadius: 18,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
