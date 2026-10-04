import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthSignInStatus { success, cancelled, error }

/// Structured outcome of a Sign-In attempt.
class AuthSignInResult {
  final AuthSignInStatus status;
  final User? user;
  final String? errorMessage;
  final String? rawError;
  final String? errorCode;

  const AuthSignInResult.success(this.user)
      : status = AuthSignInStatus.success,
        errorMessage = null,
        rawError = null,
        errorCode = null;

  const AuthSignInResult.cancelled()
      : status = AuthSignInStatus.cancelled,
        user = null,
        errorMessage = 'Sign-in cancelled by user.',
        rawError = null,
        errorCode = 'cancelled';

  const AuthSignInResult.error(this.errorMessage, {this.rawError, this.errorCode})
      : status = AuthSignInStatus.error,
        user = null;

  bool get isSuccess => status == AuthSignInStatus.success;
  bool get isCancelled => status == AuthSignInStatus.cancelled;
  bool get isError => status == AuthSignInStatus.error;

  /// Backwards-compatibility getter for any code referencing result.credential?.user
  _CredentialCompat? get credential => user != null ? _CredentialCompat(user!) : null;
}

class _CredentialCompat {
  final User user;
  const _CredentialCompat(this.user);
}

/// Production-ready Supabase Native Authentication Service for AVAN.
/// Supports native Email/Password sign-up & sign-in, session streams, password resets,
/// and guest fallback mode.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Certificate fingerprints retained for diagnostics and environment validation
  static const String playStoreSha1 = '56:8B:98:6A:2A:1C:4F:90:9D:1C:A3:A3:35:A0:25:88:0E:05:8E:FA';
  static const String playStoreSha256 = '77:E0:D5:73:FE:84:67:9E:CD:78:CA:C1:7B:0D:84:6C:C8:28:42:79:E1:B1:8F:B1:18:94:57:F1:ED:B1:FA:86';
  static const String uploadSha1 = '7C:13:70:38:09:EB:C8:82:6E:16:C6:DF:3D:A3:40:31:D4:CA:2E:22';
  static const String releaseSha1 = '14:D9:AD:4E:98:69:0D:15:E2:EC:9A:CD:C5:7E:B4:6B:C3:0C:3C:27';
  static const String debugSha1 = 'D5:00:47:B3:45:F5:1B:D3:0D:09:57:FE:07:02:8C:AE:DE:E1:E2:EB';

  static const String webClientId = '659993815762-7rocmta0r18956jg4605l4riam24g3s7.apps.googleusercontent.com';

  static const MethodChannel _appInfoChannel = MethodChannel('com.avanapp.avan_app/app_info');

  /// Reads the exact SHA-1 fingerprint of the signing certificate used by the running APK.
  static Future<String?> getRunningAppSha1() async {
    try {
      final sha1 = await _appInfoChannel.invokeMethod<String>('getAppSigningSha1');
      return sha1;
    } catch (e) {
      debugPrint('[AuthService] Could not retrieve running app SHA-1: $e');
      return null;
    }
  }

  static String? lastError;
  static String? lastErrorCode;
  static final List<String> diagnosticLogs = [];

  static void logDiagnostic(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    diagnosticLogs.add('[$timestamp] $message');
    if (diagnosticLogs.length > 30) diagnosticLogs.removeAt(0);
    debugPrint('[AuthService] $message');
  }

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  GoTrueClient? get _auth => _client?.auth;

  /// Parses raw platform or Supabase auth exceptions into human-readable messages.
  static String parseErrorMessage(dynamic error) {
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('invalid login credentials') || errStr.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please verify your credentials and try again.';
    } else if (errStr.contains('email not confirmed') || errStr.contains('email_not_confirmed')) {
      return 'Please check your inbox and confirm your email address before signing in.';
    } else if (errStr.contains('user already registered') || errStr.contains('already_registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    } else if (errStr.contains('password') && (errStr.contains('short') || errStr.contains('least') || errStr.contains('6'))) {
      return 'Password should be at least 6 characters long.';
    } else if (errStr.contains('10') || errStr.contains('developer_error')) {
      return 'Developer Error (10): App SHA-1 is missing in Console, or sign-in is disabled.';
    } else if (errStr.contains('operation-not-allowed')) {
      return 'Email/Password sign-in is disabled in Firebase Console.';
    } else if (errStr.contains('network') || errStr.contains('unavailable') || errStr.contains('socketexception')) {
      return 'Network connection error. Please verify your internet connection.';
    } else if (errStr.contains('popup_closed') || errStr.contains('canceled') || errStr.contains('cancelled')) {
      return 'Sign-in cancelled by user.';
    }
    return error.toString();
  }

  /// Real-time stream of user authentication state changes from Supabase.
  Stream<User?> get authStateChanges {
    try {
      final auth = _auth;
      if (auth == null) return const Stream.empty();
      return auth.onAuthStateChange.map((data) => data.session?.user);
    } catch (e) {
      debugPrint('[AuthService] authStateChanges stream error (handled): $e');
      return const Stream.empty();
    }
  }

  /// Currently signed in Supabase user, if any.
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  bool get isSignedIn => currentUser != null;
  String? get userId => currentUser?.id;
  String? get userEmail => currentUser?.email;
  String? get displayName =>
      currentUser?.userMetadata?['name'] as String? ??
      currentUser?.userMetadata?['display_name'] as String? ??
      currentUser?.email?.split('@').first;
  String? get photoUrl => currentUser?.userMetadata?['avatar_url'] as String?;

  /// Signs in an existing user with Supabase Native Email & Password.
  Future<AuthSignInResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    logDiagnostic("Initiating Supabase Native Email sign-in for: $email...");
    try {
      final auth = _auth;
      if (auth == null) {
        const err = "Supabase client not initialized.";
        lastError = err;
        return const AuthSignInResult.error(err);
      }

      final response = await auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        const err = "Sign in failed: no user session returned.";
        lastError = err;
        return const AuthSignInResult.error(err);
      }

      logDiagnostic("Successfully signed in user: ${user.email} (${user.id})");
      lastError = null;
      lastErrorCode = null;
      return AuthSignInResult.success(user);
    } catch (e) {
      final userFriendly = parseErrorMessage(e);
      lastError = userFriendly;
      lastErrorCode = e is AuthException ? e.statusCode : 'auth_error';
      logDiagnostic("Supabase sign-in error: $e (Parsed: $userFriendly)");
      return AuthSignInResult.error(userFriendly, rawError: e.toString(), errorCode: lastErrorCode);
    }
  }

  /// Registers a new user account with Supabase Native Email & Password.
  Future<AuthSignInResult> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    logDiagnostic("Initiating Supabase Native sign-up for: $email...");
    try {
      final auth = _auth;
      if (auth == null) {
        const err = "Supabase client not initialized.";
        lastError = err;
        return const AuthSignInResult.error(err);
      }

      final response = await auth.signUp(
        email: email.trim(),
        password: password,
        data: displayName != null && displayName.isNotEmpty
            ? {'name': displayName, 'display_name': displayName}
            : null,
      );

      final user = response.user;
      if (user == null) {
        const err = "Registration failed: no user returned.";
        lastError = err;
        return const AuthSignInResult.error(err);
      }

      logDiagnostic("Successfully registered user: ${user.email} (${user.id})");
      lastError = null;
      lastErrorCode = null;
      return AuthSignInResult.success(user);
    } catch (e) {
      final userFriendly = parseErrorMessage(e);
      lastError = userFriendly;
      lastErrorCode = e is AuthException ? e.statusCode : 'signup_error';
      logDiagnostic("Supabase sign-up error: $e (Parsed: $userFriendly)");
      return AuthSignInResult.error(userFriendly, rawError: e.toString(), errorCode: lastErrorCode);
    }
  }

  /// Sends a password reset email using Supabase Auth.
  Future<AuthSignInResult> resetPasswordForEmail(String email) async {
    try {
      final auth = _auth;
      if (auth == null) {
        return const AuthSignInResult.error("Supabase client not initialized.");
      }
      await auth.resetPasswordForEmail(email.trim());
      logDiagnostic("Password reset email sent to: $email");
      return const AuthSignInResult.success(null);
    } catch (e) {
      final msg = parseErrorMessage(e);
      return AuthSignInResult.error(msg, rawError: e.toString());
    }
  }

  /// Compatibility fallback for existing Google Sign-In callers.
  Future<AuthSignInResult> signInWithGoogle() async {
    return const AuthSignInResult.error("Google Sign-In has been replaced with Supabase Native Email Sign-In.");
  }

  /// Signs out the user from Supabase.
  Future<void> signOut() async {
    try {
      await _auth?.signOut();
      logDiagnostic("User signed out from Supabase successfully.");
    } catch (e) {
      logDiagnostic("Error during signOut: $e");
    }
  }

  /// Terminates user session on this device.
  Future<bool> deleteAccount() async {
    logDiagnostic("Initiating user account deletion / sign-out...");
    try {
      await signOut();
      logDiagnostic("User session wiped successfully.");
      return true;
    } catch (e) {
      lastError = parseErrorMessage(e);
      logDiagnostic("Account deletion error: $e");
      return false;
    }
  }
}
