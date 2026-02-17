import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_model.dart';

class CheckinRepository {
  final FirebaseFirestore _db;

  CheckinRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _checkins => _db.collection('checkins');

  /// Create a new check-in
  Future<String> createCheckin(CheckinModel checkin) async {
    final doc = await _checkins.add(checkin.toFirestore());
    return doc.id;
  }

  /// Get today's check-in for a user
  Future<CheckinModel?> getTodayCheckin(String userId) async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final snapshot = await _checkins
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: todayStr)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CheckinModel.fromFirestore(snapshot.docs.first);
  }

  /// Get sad users for matching (happy user sees these)
  Future<List<CheckinModel>> getSadUsersForMatching({
    required String excludeUserId,
    int limit = 5,
  }) async {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final snapshot = await _checkins
        .where('mood', isEqualTo: 'sad')
        .where('wantsEncouragement', isEqualTo: true)
        .where('date', isEqualTo: todayStr)
        .orderBy('createdAt', descending: true)
        .limit(limit + 1) // fetch extra to filter out self
        .get();

    return snapshot.docs
        .map((doc) => CheckinModel.fromFirestore(doc))
        .where((c) => c.userId != excludeUserId)
        .take(limit)
        .toList();
  }

  /// Get check-in history for a user
  Future<List<CheckinModel>> getCheckinHistory(
    String userId, {
    int limit = 30,
  }) async {
    final snapshot = await _checkins
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CheckinModel.fromFirestore(doc))
        .toList();
  }

  /// Stream today's check-in for a user (realtime)
  Stream<CheckinModel?> watchTodayCheckin(String userId) {
    final todayStr = todayDateString();
    return _checkins
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: todayStr)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CheckinModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// Stream sad users for matching (realtime, random 5)
  Stream<List<CheckinModel>> watchSadUsersForMatching({
    required String excludeUserId,
    int limit = 5,
  }) {
    final todayStr = todayDateString();
    return _checkins
        .where('mood', isEqualTo: 'sad')
        .where('wantsEncouragement', isEqualTo: true)
        .where('date', isEqualTo: todayStr)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => CheckinModel.fromFirestore(doc))
          .where((c) => c.userId != excludeUserId)
          .toList();
      all.shuffle();
      return all.take(limit).toList();
    });
  }

  /// Update wantsEncouragement field
  Future<void> updateWantsEncouragement(String checkinId, bool value) async {
    await _checkins.doc(checkinId).update({'wantsEncouragement': value});
  }

  /// Update display name on a checkin document
  Future<void> updateUserDisplayInfo(String checkinId, {
    required String userAnonymousId,
    String? userDisplayName,
  }) async {
    await _checkins.doc(checkinId).update({
      'userAnonymousId': userAnonymousId,
      'userDisplayName': userDisplayName,
    });
  }

  /// Delete a check-in by ID
  Future<void> deleteCheckin(String checkinId) async {
    await _checkins.doc(checkinId).delete();
  }

  /// Get today's date string in YYYY-MM-DD format
  static String todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
