import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthSignInStatus { success, cancelled, error }

/// Structured outcome of a Google Sign-In attempt.
class AuthSignInResult {
  final AuthSignInStatus status;
  final UserCredential? credential;
  final String? errorMessage;
  final String? rawError;
  final String? errorCode;

  const AuthSignInResult.success(this.credential)
      : status = AuthSignInStatus.success,
        errorMessage = null,
        rawError = null,
        errorCode = null;

  const AuthSignInResult.cancelled()
      : status = AuthSignInStatus.cancelled,
        credential = null,
        errorMessage = 'Sign-in cancelled by user.',
        rawError = null,
        errorCode = 'cancelled';

  const AuthSignInResult.error(this.errorMessage, {this.rawError, this.errorCode})
      : status = AuthSignInStatus.error,
        credential = null;

  bool get isSuccess => status == AuthSignInStatus.success;
  bool get isCancelled => status == AuthSignInStatus.cancelled;
  bool get isError => status == AuthSignInStatus.error;
}

/// Production-ready Firebase Authentication & Google Sign-In Service for AVAN.
/// Supports Progressive / Optional Auth, seamless credential linking, diagnostic error parsing,
/// and re-authenticated account deletion.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  @visibleForTesting
  static FirebaseAuth? customAuthInstance;

  @visibleForTesting
  static GoogleSignIn? customGoogleSignInInstance;

  // Exact SHA-1 fingerprints generated for AVAN
  static const String releaseSha1 = '14:D9:AD:4E:98:69:0D:15:E2:EC:9A:CD:C5:7E:B4:6B:C3:0C:3C:27';
  static const String debugSha1 = 'D5:00:47:B3:45:F5:1B:D3:0D:09:57:FE:07:02:8C:AE:DE:E1:E2:EB';

  static String? lastError;
  static String? lastErrorCode;
  static final List<String> diagnosticLogs = [];

  static void logDiagnostic(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    diagnosticLogs.add('[$timestamp] $message');
    if (diagnosticLogs.length > 30) diagnosticLogs.removeAt(0);
    debugPrint('[AuthService] $message');
  }

  FirebaseAuth get _auth {
    if (customAuthInstance != null) return customAuthInstance!;
    return FirebaseAuth.instance;
  }

  GoogleSignIn get _googleSignIn {
    if (customGoogleSignInInstance != null) return customGoogleSignInInstance!;
    return GoogleSignIn();
  }

  /// Parses raw platform or Firebase exceptions into human-readable diagnostic messages.
  static String parseErrorMessage(dynamic error) {
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('10') || errStr.contains('developer_error')) {
      return 'Developer Error (10): App SHA-1 fingerprint is missing in Firebase Console, or Google Sign-In is not enabled.';
    } else if (errStr.contains('12500') || errStr.contains('sign_in_failed')) {
      return 'Sign-In Failed (12500): Google Play Services was unable to authenticate. Verify device network and Play Services.';
    } else if (errStr.contains('operation-not-allowed')) {
      return 'Google Sign-In is disabled in Firebase Console (Authentication > Sign-in method).';
    } else if (errStr.contains('network') || errStr.contains('unavailable')) {
      return 'Network connection error. Please verify your internet connection.';
    } else if (errStr.contains('account-exists-with-different-credential')) {
      return 'An account already exists with the same email using a different sign-in provider.';
    } else if (errStr.contains('popup_closed') || errStr.contains('canceled') || errStr.contains('cancelled')) {
      return 'Sign-in cancelled by user.';
    }
    return error.toString();
  }

  /// Real-time stream of user authentication state changes.
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      debugPrint('[AuthService] authStateChanges stream error (handled): $e');
      return const Stream.empty();
    }
  }

  /// Currently signed in user, if any.
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  bool get isSignedIn => currentUser != null;
  String? get userId => currentUser?.uid;
  String? get userEmail => currentUser?.email;
  String? get displayName => currentUser?.displayName;
  String? get photoUrl => currentUser?.photoURL;

  /// Signs in the user with their Google Account using native Google Play Services.
  Future<AuthSignInResult> signInWithGoogle() async {
    logDiagnostic("Initiating Google Sign-In flow...");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        logDiagnostic("Google Sign-In cancelled by user.");
        return const AuthSignInResult.cancelled();
      }

      logDiagnostic("Google account picked: ${googleUser.email}. Fetching auth tokens...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        const err = "Failed to obtain auth tokens from Google Play Services.";
        lastError = err;
        lastErrorCode = "missing_tokens";
        logDiagnostic(err);
        return const AuthSignInResult.error(err, errorCode: "missing_tokens");
      }

      logDiagnostic("Obtained tokens (idToken present: ${googleAuth.idToken != null}). Signing into Firebase...");
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      logDiagnostic("Successfully signed in user: ${userCredential.user?.email} (${userCredential.user?.uid})");
      lastError = null;
      lastErrorCode = null;
      return AuthSignInResult.success(userCredential);
    } catch (e) {
      final userFriendly = parseErrorMessage(e);
      lastError = userFriendly;
      lastErrorCode = e is FirebaseAuthException ? e.code : 'auth_error';
      logDiagnostic("Google Sign-In error: $e (Parsed: $userFriendly)");
      return AuthSignInResult.error(userFriendly, rawError: e.toString(), errorCode: lastErrorCode);
    }
  }

  /// Signs out the user from both Firebase and Google Sign-In.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      logDiagnostic("User signed out successfully.");
    } catch (e) {
      logDiagnostic("Error during signOut: $e");
    }
  }

  /// Permanently deletes the user account from Firebase with re-authentication support.
  Future<bool> deleteAccount() async {
    logDiagnostic("Initiating user account deletion...");
    try {
      final user = _auth.currentUser;
      if (user == null) {
        logDiagnostic("No authenticated user to delete.");
        return false;
      }

      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          logDiagnostic("Account deletion requires recent login. Re-authenticating...");
          final reauth = await _googleSignIn.signIn();
          if (reauth != null) {
            final auth = await reauth.authentication;
            final cred = GoogleAuthProvider.credential(
              accessToken: auth.accessToken,
              idToken: auth.idToken,
            );
            await user.reauthenticateWithCredential(cred);
            await user.delete();
          } else {
            logDiagnostic("Re-authentication cancelled by user.");
            return false;
          }
        } else {
          rethrow;
        }
      }

      await _googleSignIn.signOut();
      logDiagnostic("User account deleted successfully.");
      return true;
    } catch (e) {
      lastError = parseErrorMessage(e);
      logDiagnostic("Account deletion error: $e");
      return false;
    }
  }
}
