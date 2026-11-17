import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/app_config.dart';
import '../../core/providers.dart';
import '../../domain/entities/food_analysis.dart';
import '../../domain/repositories/user_repository.dart';
import 'app_state.dart';

/// Single global controller.
///
/// Storage is local (SQLite), so there is no realtime data stream: the state
/// is a snapshot that is explicitly reloaded after every write. Firebase is
/// used for authentication only.
class AppController extends Notifier<AppState> {
  StreamSubscription<User?>? _authSub;

  bool _disposed = false;
  String? _profileInitializingFor;
  String? _boundUid;

  @override
  AppState build() {
    ref.onDispose(() {
      _disposed = true;
      _authSub?.cancel();
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
              _boundUid = null;
              _profileInitializingFor = null;
              // Local data stays on disk but is never shown while signed out.
              state = const AppState(loading: false);
              return;
            }

            if (_boundUid == user.uid) {
              state = state.copyWith(user: user, loading: false, clearError: true);
              return;
            }

            _boundUid = user.uid;
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

  /// Loads profile + logs for [user]. Keeps `loading` true until both are
  /// ready so account switching never flashes another user's data.
  Future<void> _bindUser(User user) async {
    state = state.copyWith(
      user: user,
      loading: true,
      clearError: true,
      clearUser: false,
      clearProfile: true,
      logs: const [],
    );

    await _loadProfile(user.uid);
    await _loadLogs(user.uid);

    if (!_disposed) state = state.copyWith(loading: false);
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final profile = await ref.read(getProfileUseCaseProvider)(uid);
      if (_disposed) return;

      if (profile != null) {
        state = state.copyWith(profile: profile);
        return;
      }

      // Profile row does not exist yet: create the default one once.
      if (_profileInitializingFor == uid) return;
      _profileInitializingFor = uid;

      await ref.read(createDefaultProfileUseCaseProvider)(
        uid,
        state.user?.displayName ?? 'User',
        AppConfig.defaultCalorieGoal,
        AppConfig.defaultWaterGoal,
      );
      if (_disposed) return;

      final created = await ref.read(getProfileUseCaseProvider)(uid);
      if (!_disposed && created != null) {
        state = state.copyWith(profile: created);
      }
    } catch (error) {
      _profileInitializingFor = null;
      if (!_disposed) {
        state = state.copyWith(error: _friendlyError(error));
      }
    }
  }

  Future<void> _loadLogs(String uid) async {
    try {
      final logs = await ref.read(getLogsUseCaseProvider)(uid);
      if (_disposed) return;
      state = state.copyWith(logs: logs);
    } catch (error) {
      if (!_disposed) {
        state = state.copyWith(error: _friendlyError(error));
      }
    }
  }

  Future<void> _refreshLogs() async {
    final user = state.user;
    if (user == null) return;
    await _loadLogs(user.uid);
  }

  Future<void> _refreshProfile() async {
    final user = state.user;
    if (user == null) return;
    await _loadProfile(user.uid);
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

    // Switch tab to Dash immediately (optimistic redirect).
    setTab(AppTab.home);

    try {
      await ref.read(addFoodLogUseCaseProvider)(user.uid, analysis, imageUrl);
      await _refreshLogs();
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    }
  }

  Future<void> addWater(double amount) async {
    final user = state.user;
    if (user == null) return;

    try {
      await ref.read(addWaterLogUseCaseProvider)(user.uid, amount);
      await _refreshLogs();
    } catch (error) {
      state = state.copyWith(error: _friendlyError(error));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      await ref.read(deleteLogUseCaseProvider)(id);
      await _refreshLogs();
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
      await _refreshProfile();
    } catch (error) {
      state = state.copyWith(profile: current, error: _friendlyError(error));
    }
  }

  /// Reloads profile and logs from SQLite after a backup restore/import.
  Future<void> reloadFromStorage() async {
    final user = state.user;
    if (user == null) return;

    state = state.copyWith(loading: true, clearError: true);
    await _refreshProfile();
    await _refreshLogs();
    if (!_disposed) state = state.copyWith(loading: false);
  }

  String _friendlyError(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google Sign-In dibatalkan.';
        case GoogleSignInExceptionCode.clientConfigurationError:
          return 'Google Sign-In belum dikonfigurasi: serverClientId kosong.\n'
              '1) Buka console.cloud.google.com/apis/credentials '
              '(project naturevital-skeuo) dan salin "Web client" ID.\n'
              '2) Isi GOOGLE_SERVER_CLIENT_ID di file .env.\n'
              'Alternatif: taruh android/app/google-services.json dari '
              'flutterfire configure, maka plugin akan membacanya otomatis.';
        case GoogleSignInExceptionCode.providerConfigurationError:
        case GoogleSignInExceptionCode.unknownError:
          return 'Google Sign-In gagal: '
              '${error.description ?? error.code.name}.\n'
              'Penyebab paling umum: OAuth client Android untuk package '
              'naturevital.skeuo + SHA-1 sertifikat (debug/release) belum '
              'terdaftar, atau terdaftar di project Google Cloud yang berbeda '
              'dari GOOGLE_SERVER_CLIENT_ID. Cek logcat: status '
              '"UNREGISTERED_ON_API_CONSOLE" berarti SHA-1 belum didaftarkan.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google Sign-In tidak bisa menampilkan UI. Coba lagi.';
        case GoogleSignInExceptionCode.interrupted:
          return 'Google Sign-In terganggu. Coba lagi.';
        case GoogleSignInExceptionCode.userMismatch:
          return 'Google Sign-In: akun yang dipilih bukan akun aktif.';
      }
    }
    if (error is FirebaseAuthException) {
      return 'Auth error (${error.code}): '
          '${error.message ?? 'no message from Firebase'}';
    }
    return error.toString();
  }
}

final appControllerProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);
