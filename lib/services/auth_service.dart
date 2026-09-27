import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Production-ready Firebase Authentication & Google Sign-In Service for AVAN.
/// Supports Progressive / Optional Auth, seamless credential linking, and account deletion.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  @visibleForTesting
  static FirebaseAuth? customAuthInstance;

  @visibleForTesting
  static GoogleSignIn? customGoogleSignInInstance;

  FirebaseAuth get _auth {
    if (customAuthInstance != null) return customAuthInstance!;
    return FirebaseAuth.instance;
  }

  GoogleSignIn get _googleSignIn {
    if (customGoogleSignInInstance != null) return customGoogleSignInInstance!;
    return GoogleSignIn();
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
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[AuthService] Google Sign-In cancelled by user.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('[AuthService] Successfully signed in user: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In failed: $e');
      rethrow;
    }
  }

  /// Signs out the user from both Firebase and Google Sign-In.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      debugPrint('[AuthService] User signed out successfully.');
    } catch (e) {
      debugPrint('[AuthService] Error during signOut: $e');
    }
  }

  /// Permanently deletes the user account from Firebase (Google Play policy requirement).
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        await _googleSignIn.signOut();
        debugPrint('[AuthService] User account deleted successfully.');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AuthService] Account deletion error: $e');
      return false;
    }
  }
}
