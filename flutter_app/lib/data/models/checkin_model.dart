import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodType { happy, sad }

class CheckinModel {
  final String id;
  final String userId;
  final MoodType mood;
  final String? note;
  final bool wantsEncouragement;
  final int matchedCount;
  final String date; // YYYY-MM-DD
  final DateTime createdAt;
  
  // Denormalized user info
  final String userAnonymousId;
  final String? userDisplayName;
  final String? userAvatarUrl;

  CheckinModel({
    required this.id,
    required this.userId,
    required this.mood,
    this.note,
    this.wantsEncouragement = true,
    this.matchedCount = 0,
    required this.date,
    required this.createdAt,
    required this.userAnonymousId,
    this.userDisplayName,
    this.userAvatarUrl,
  });

  factory CheckinModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckinModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      mood: data['mood'] == 'happy' ? MoodType.happy : MoodType.sad,
      note: data['note'],
      wantsEncouragement: data['wantsEncouragement'] ?? true,
      matchedCount: data['matchedCount'] ?? 0,
      date: data['date'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userAnonymousId: data['userAnonymousId'] ?? 'User#0000',
      userDisplayName: data['userDisplayName'],
      userAvatarUrl: data['userAvatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'mood': mood == MoodType.happy ? 'happy' : 'sad',
      'note': note,
      'wantsEncouragement': wantsEncouragement,
      'matchedCount': matchedCount,
      'date': date,
      'createdAt': Timestamp.fromDate(createdAt),
      'userAnonymousId': userAnonymousId,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
    };
  }

  /// Get display name (anonymous if not public)
  String get displayName => userDisplayName ?? userAnonymousId;

  /// Check if checkin is from today
  bool get isToday {
    final now = DateTime.now();
    final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return date == todayString;
  }
}
