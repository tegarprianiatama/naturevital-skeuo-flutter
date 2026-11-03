import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/app_config.dart';
import '../../core/providers.dart';
import '../../domain/entities/food_analysis.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import 'app_state.dart';

class AppController extends Notifier<AppState> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;
  StreamSubscription<List<LogEntry>>? _logsSub;

  bool _disposed = false;
  String? _profileInitializingFor;

  @override
  AppState build() {
    ref.onDispose(() {
      _disposed = true;
      _authSub?.cancel();
      _profileSub?.cancel();
      _logsSub?.cancel();
    });

    Future.microtask(_listenToAuth);
    return const AppState();
  }

  void _listenToAuth() {
    if (_disposed) return;

    _authSub = ref
        .read(authServiceProvider)
        .authStateChanges
        .listen(
          (user) {
            if (_disposed) return;

            if (user == null) {
              _profileSub?.cancel();
              _logsSub?.cancel();
              _profileInitializingFor = null;
              state = const AppState(loading: false);
              return;
            }

            state = state.copyWith(
              user: user,
              loading: false,
              clearError: true,
            );
            _bindUser(user);
          },
          onError: (Object error, StackTrace stack) {
            if (_disposed) return;
            state = state.copyWith(
              loading: false,
              error: _friendlyError(error),
            );
          },
        );
  }

  void _bindUser(User user) {
    _profileSub?.cancel();
    _logsSub?.cancel();

    _profileSub = ref
        .read(subscribeProfileUseCaseProvider)(user.uid)
        .listen(
          (profile) {
            if (_disposed) return;

            if (profile != null) {
              state = state.copyWith(profile: profile);
              return;
            }

            // Profile document does not exist yet: create the default one once.
            if (_profileInitializingFor == user.uid) return;
            _profileInitializingFor = user.uid;

            ref
                .read(createDefaultProfileUseCaseProvider)(
                  user.uid,
                  user.displayName ?? 'User',
                  AppConfig.defaultCalorieGoal,
                  AppConfig.defaultWaterGoal,
                )
                .catchError((Object error) {
                  _profileInitializingFor = null;
                  if (!_disposed) {
                    state = state.copyWith(error: _friendlyError(error));
                  }
                });
          },
          onError: (Object error, StackTrace stack) {
            if (_disposed) return;
            state = state.copyWith(error: _friendlyError(error));
          },
        );

    _logsSub = ref
        .read(subscribeLogsUseCaseProvider)(user.uid)
        .listen(
          (logs) {
            if (_disposed) return;
            state = state.copyWith(logs: logs);
          },
          onError: (Object error, StackTrace stack) {
            if (_disposed) return;
            state = state.copyWith(error: _friendlyError(error));
          },
        );
  }

  Future<void> signIn() async {
    if (state.signingIn) return;
    state = state.copyWith(signingIn: true, clearError: true);

    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } on GoogleSignInException catch (error) {
      if (error.code != GoogleSignInExceptionCode.canceled) {
        state = state.copyWith(error: _friendlyError(error));
      }
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    } finally {
      state = state.copyWith(signingIn: false);
    }
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }

  void setTab(AppTab tab) {
    state = state.copyWith(tab: tab, clearError: true);
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> addFood(FoodAnalysis analysis, String imageUrl) async {
    final user = state.user;
    if (user == null) return;

    // Switch tab to Dash immediately (optimistic redirect)
    setTab(AppTab.home);

    try {
      await ref.read(addFoodLogUseCaseProvider)(user.uid, analysis, imageUrl);
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    }
  }

  Future<void> addWater(double amount) async {
    final user = state.user;
    if (user == null) return;

    try {
      await ref.read(addWaterLogUseCaseProvider)(user.uid, amount);
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await ref.read(deleteLogUseCaseProvider)(id);
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    }
  }

  Future<void> updateGoal(GoalField field, double value) async {
    final user = state.user;
    if (user == null || state.profile == null) return;

    // Optimistic update so the text field does not flicker.
    final current = state.profile!;
    state = state.copyWith(
      profile: field == GoalField.calorieGoal
          ? current.copyWith(calorieGoal: value)
          : current.copyWith(waterGoal: value),
    );

    try {
      await ref.read(updateGoalUseCaseProvider)(user.uid, field, value);
    } catch (error) {
      state = state.copyWith(profile: current, error: _friendlyError(error));
    }
  }

  String _friendlyError(Object error) {
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        return 'Google Sign-In belum dikonfigurasi: serverClientId kosong.\n'
            '1) Buka console.cloud.google.com/apis/credentials '
            '(project naturevital-skeuo) dan salin "Web client" ID.\n'
            '2) Jalankan dengan '
            '--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>.apps.googleusercontent.com\n'
            'Alternatif: taruh android/app/google-services.json dari '
            'flutterfire configure, maka plugin akan membacanya otomatis.';
      }
      return 'Google Sign-In failed: ${error.description ?? error.code.name}';
    }
    if (error is FirebaseAuthException) {
      return 'Auth error: ${error.message ?? error.code}';
    }
    return error.toString();
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);
