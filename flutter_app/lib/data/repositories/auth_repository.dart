import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Current auth user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (nullable)
  User? get currentUser => _auth.currentUser;

  /// Current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in anonymously (for quick access, no account needed)
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Link anonymous account to email/password
  Future<UserCredential> linkWithEmail(String email, String password) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return await _auth.currentUser!.linkWithCredential(credential);
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
