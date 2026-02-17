import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  /// Create new user document
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Get user profile as real-time stream
  Stream<UserModel?> getUserStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Update user fields
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _users.doc(uid).update(data);
  }

  /// Get or create user stats subcollection
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    final doc = await _users.doc(uid).collection('stats').doc('current').get();
    if (!doc.exists) {
      final defaults = {
        'totalCheckins': 0,
        'happyDays': 0,
        'sadDays': 0,
        'totalSent': 0,
        'totalReceived': 0,
        'peopleHelped': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'lastSendDate': '',
        'badges': <String>[],
        'updatedAt': Timestamp.now(),
      };
      await _users.doc(uid).collection('stats').doc('current').set(defaults);
      return defaults;
    }
    return doc.data()!;
  }

  /// Update user stats
  Future<void> updateUserStats(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _users
        .doc(uid)
        .collection('stats')
        .doc('current')
        .set(data, SetOptions(merge: true));
  }

  /// Generate unique anonymous ID (e.g., User#4521)
  String generateAnonymousId() {
    final random = Random();
    final number = 1000 + random.nextInt(9000); // 4-digit number
    return 'User#$number';
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String uid) async {
    await _users.doc(uid).update({
      'lastActiveAt': Timestamp.now(),
    });
  }
}
