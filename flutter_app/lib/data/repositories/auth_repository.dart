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

}
