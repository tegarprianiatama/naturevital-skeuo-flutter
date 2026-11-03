import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/skeuo_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/state/app_controller.dart';

class NatureVitalApp extends StatelessWidget {
  const NatureVitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NatureVital',
      navigatorKey: ChuckerFlutter.navigatorKey,
      debugShowCheckedModeBanner:
          dotenv.get('DEBUG_FLUTTER_BANNER', fallback: 'false') == 'true',
      theme: Skeuo.theme(),
      home: const RootGate(),
    );
  }
}

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);

    if (state.loading) return const _SplashScreen();
    if (state.user == null) return const LoginScreen();
    return const HomeScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Skeuo.accent,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'LOADING...',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: Skeuo.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
