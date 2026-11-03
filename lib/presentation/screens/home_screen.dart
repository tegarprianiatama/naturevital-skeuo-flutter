import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/skeuo_theme.dart';
import '../state/app_controller.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/skeuo_surface.dart';
import 'tabs/food_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/settings_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/water_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              displayName: state.user?.displayName ?? 'User',
              photoUrl: state.user?.photoURL,
              onProfileTap: () => controller.setTab(AppTab.settings),
            ),
            Expanded(
              child: IndexedStack(
                index: state.tab.index,
                children: const [
                  HomeTab(),
                  FoodTab(),
                  WaterTab(),
                  StatsTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        activeTab: state.tab,
        onTabChange: controller.setTab,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.displayName,
    required this.photoUrl,
    required this.onProfileTap,
  });

  final String displayName;
  final String? photoUrl;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        gradient: Skeuo.brushedMetal,
        border: Border(bottom: BorderSide(color: Color(0x66FFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NATUREVITAL',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'CONSOLE: $displayName',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Skeuo.textMuted,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: SkeuoDial(
              size: 42,
              child: ClipOval(
                child: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? Image.network(
                        photoUrl!,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF4B5563),
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Color(0xFF4B5563),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
