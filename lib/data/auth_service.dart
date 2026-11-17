import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_config.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  static const _logTag = '[NatureVital.Auth]';

  final FirebaseAuth _firebaseAuth;

  bool _googleSignInReady = false;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> _ensureGoogleSignIn() async {
    if (_googleSignInReady) return;

    final serverClientId = AppConfig.googleServerClientId;
    _log('initialize', {
      'projectId': AppConfig.firebaseProjectId,
      'appId': AppConfig.firebaseAppId,
      'apiKeySet': AppConfig.firebaseApiKey.isNotEmpty,
      'serverClientId': serverClientId.isEmpty ? '<empty>' : serverClientId,
    });

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      );
    } on GoogleSignInException catch (error, stack) {
      _log('GoogleSignIn.initialize failed', {
        'code': error.code.name,
        'description': error.description,
        'details': error.details,
      }, stack);
      rethrow;
    }

    _googleSignInReady = true;
  }

  Future<void> signInWithGoogle() async {
    await _ensureGoogleSignIn();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error, stack) {
      _log('GoogleSignIn.authenticate failed', {
        'code': error.code.name,
        'description': error.description,
        'details': error.details,
      }, stack);
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      _log('GoogleSignIn.authenticate returned no idToken', {
        'email': account.email,
      });
      throw GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description:
            'Google tidak mengembalikan idToken untuk ${account.email}. '
            'Pastikan GOOGLE_SERVER_CLIENT_ID berisi OAuth client bertipe '
            '"Web application" dari project Firebase yang sama.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    try {
      final result = await _firebaseAuth.signInWithCredential(credential);
      _log('Firebase signInWithCredential succeeded', {
        'uid': result.user?.uid,
        'providers': result.user?.providerData
            .map((provider) => provider.providerId)
            .toList(),
      });
    } on FirebaseAuthException catch (error, stack) {
      _log('Firebase signInWithCredential failed', {
        'code': error.code,
        'message': error.message,
        'email': error.email,
      }, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google Sign-In may not have been initialized (e.g. session restored
      // from Firebase only). Nothing to clear in that case.
    }
  }

  /// Writes structured auth diagnostics to the Flutter console and Android
  /// logcat (filter with `adb logcat | grep NatureVital.Auth`).
  void _log(
    String event, [
    Map<String, Object?> details = const {},
    StackTrace? stack,
  ]) {
    final buffer = StringBuffer('$_logTag $event');
    for (final entry in details.entries) {
      buffer.write('\n  ${entry.key}: ${entry.value}');
    }
    if (stack != null) buffer.write('\n$stack');
    debugPrint(buffer.toString());
  }
}
