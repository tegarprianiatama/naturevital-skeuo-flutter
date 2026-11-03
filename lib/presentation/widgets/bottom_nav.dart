import 'package:flutter/material.dart';

import '../../core/skeuo_theme.dart';
import '../state/app_state.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  final AppTab activeTab;
  final ValueChanged<AppTab> onTabChange;

  static const _tabs = [
    (AppTab.home, Icons.home_outlined, 'Dash'),
    (AppTab.food, Icons.restaurant_outlined, 'Food'),
    (AppTab.water, Icons.water_drop_outlined, 'Water'),
    (AppTab.stats, Icons.pie_chart_outline, 'Stats'),
    (AppTab.settings, Icons.settings_outlined, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: Skeuo.brushedMetal,
            border: Border.all(color: const Color(0x80FFFFFF)),
            boxShadow: Skeuo.shadowOut,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final (tab, icon, label) in _tabs)
                _NavItem(
                  icon: icon,
                  label: label,
                  active: activeTab == tab,
                  onTap: () => onTabChange(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 62,
        height: 62,
        transform: Matrix4.translationValues(0, active ? -8 : 0, 0),
        decoration: active
            ? BoxDecoration(
                shape: BoxShape.circle,
                gradient: Skeuo.dialGradient,
                boxShadow: Skeuo.shadowButton,
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? Skeuo.accent : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: active ? Skeuo.accent : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
