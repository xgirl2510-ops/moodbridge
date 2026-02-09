import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? phone;
  final String displayName;
  final String? avatarUrl;
  final String anonymousId;
  
  // Privacy settings
  final bool isPublic;
  final bool receiveEncouragements;
  final bool showMoodNote;
  
  // Notification settings
  final bool pushEnabled;
  final bool checkinReminderEnabled;
  final String checkinReminderTime;
  
  // Status
  final bool isActive;
  final bool isBanned;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActiveAt;

  UserModel({
    required this.uid,
    this.email,
    this.phone,
    required this.displayName,
    this.avatarUrl,
    required this.anonymousId,
    this.isPublic = false,
    this.receiveEncouragements = true,
    this.showMoodNote = false,
    this.pushEnabled = true,
    this.checkinReminderEnabled = true,
    this.checkinReminderTime = '09:00',
    this.isActive = true,
    this.isBanned = false,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActiveAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      phone: data['phone'],
      displayName: data['displayName'] ?? 'User',
      avatarUrl: data['avatarUrl'],
      anonymousId: data['anonymousId'] ?? 'User#0000',
      isPublic: data['isPublic'] ?? false,
      receiveEncouragements: data['receiveEncouragements'] ?? true,
      showMoodNote: data['showMoodNote'] ?? false,
      pushEnabled: data['pushEnabled'] ?? true,
      checkinReminderEnabled: data['checkinReminderEnabled'] ?? true,
      checkinReminderTime: data['checkinReminderTime'] ?? '09:00',
      isActive: data['isActive'] ?? true,
      isBanned: data['isBanned'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'anonymousId': anonymousId,
      'isPublic': isPublic,
      'receiveEncouragements': receiveEncouragements,
      'showMoodNote': showMoodNote,
      'pushEnabled': pushEnabled,
      'checkinReminderEnabled': checkinReminderEnabled,
      'checkinReminderTime': checkinReminderTime,
      'isActive': isActive,
      'isBanned': isBanned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    bool? isPublic,
    bool? receiveEncouragements,
    bool? showMoodNote,
    bool? pushEnabled,
    bool? checkinReminderEnabled,
    String? checkinReminderTime,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      phone: phone,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      anonymousId: anonymousId,
      isPublic: isPublic ?? this.isPublic,
      receiveEncouragements: receiveEncouragements ?? this.receiveEncouragements,
      showMoodNote: showMoodNote ?? this.showMoodNote,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      checkinReminderEnabled: checkinReminderEnabled ?? this.checkinReminderEnabled,
      checkinReminderTime: checkinReminderTime ?? this.checkinReminderTime,
      isActive: isActive,
      isBanned: isBanned,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActiveAt: lastActiveAt,
    );
  }
}
