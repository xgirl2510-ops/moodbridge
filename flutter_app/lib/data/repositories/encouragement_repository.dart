import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/encouragement_model.dart';

class EncouragementRepository {
  final FirebaseFirestore _db;

  EncouragementRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _encouragements => _db.collection('encouragements');

  /// Send an encouragement message
  Future<String> sendEncouragement(EncouragementModel encouragement) async {
    final doc = await _encouragements.add(encouragement.toFirestore());
    return doc.id;
  }

  /// Get inbox (received encouragements) as stream
  Stream<List<EncouragementModel>> getInboxStream(String userId) {
    return _encouragements
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EncouragementModel.fromFirestore(doc))
            .toList());
  }

  /// Get sent encouragements
  Future<List<EncouragementModel>> getSentHistory(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _encouragements
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => EncouragementModel.fromFirestore(doc))
        .toList();
  }

  /// Add reaction to an encouragement
  Future<void> addReaction(String encouragementId, String reaction) async {
    await _encouragements.doc(encouragementId).update({
      'reaction': reaction,
      'reactionAt': Timestamp.now(),
    });
  }

  /// Mark encouragement as read
  Future<void> markAsRead(String encouragementId) async {
    await _encouragements.doc(encouragementId).update({
      'isRead': true,
      'readAt': Timestamp.now(),
    });
  }

  /// Check if user already sent encouragement to someone today
  Future<bool> hasAlreadySent(String senderId, String receiverId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final snapshot = await _encouragements
        .where('senderId', isEqualTo: senderId)
        .where('receiverId', isEqualTo: receiverId)
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
