import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/skeuo_theme.dart';
import '../state/app_controller.dart';
import '../widgets/skeuo_button.dart';
import '../widgets/skeuo_surface.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);

    ref.listen(appControllerProvider.select((s) => s.error), (_, error) {
      if (error == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SkeuoCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SkeuoDial(
                    size: 96,
                    child: Icon(
                      Icons.water_drop_outlined,
                      size: 40,
                      color: Skeuo.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NATUREVITAL',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -1,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'YOUR PRIVATE WELLNESS CONSOLE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: Skeuo.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Track your fuel and hydration with AI-powered vision '
                    'and skeuomorphic precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SkeuoButton(
                    enabled: !state.signingIn,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: () => controller.signIn(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (state.signingIn)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Skeuo.accent,
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        Text(
                          state.signingIn
                              ? 'CONNECTING...'
                              : 'SIGN IN WITH GOOGLE',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
