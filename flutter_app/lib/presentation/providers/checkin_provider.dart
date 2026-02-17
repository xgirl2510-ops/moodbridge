import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/checkin_model.dart';
import '../../data/repositories/checkin_repository.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Repository provider
final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  return CheckinRepository();
});

/// Today's check-in for current user (realtime)
final todayCheckinProvider = StreamProvider<CheckinModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.read(checkinRepositoryProvider).watchTodayCheckin(uid);
});

/// Sad users available for matching (realtime, random 5)
final sadUsersProvider = StreamProvider.autoDispose<List<CheckinModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref
      .read(checkinRepositoryProvider)
      .watchSadUsersForMatching(excludeUserId: uid);
});

/// Check-in history for mood calendar
final checkinHistoryProvider = FutureProvider<List<CheckinModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  return ref.read(checkinRepositoryProvider).getCheckinHistory(uid);
});

/// Submit a mood check-in
Future<CheckinModel?> submitCheckin(
  WidgetRef ref, {
  required MoodType mood,
  String? note,
  bool wantsEncouragement = true,
}) async {
  final uid = ref.read(currentUserIdProvider);
  if (uid == null) return null;

  final user = ref.read(currentUserProvider).value;
  final checkinRepo = ref.read(checkinRepositoryProvider);
  final userRepo = ref.read(userRepositoryProvider);

  final checkin = CheckinModel(
    id: '',
    userId: uid,
    mood: mood,
    note: note,
    wantsEncouragement: wantsEncouragement,
    date: CheckinRepository.todayDateString(),
    createdAt: DateTime.now(),
    userAnonymousId: user?.anonymousId ?? 'User#0000',
    userDisplayName: user?.displayName,
    userAvatarUrl: user?.avatarUrl,
  );

  await checkinRepo.createCheckin(checkin);

  // Update user stats (non-blocking, don't fail the checkin)
  try {
    final stats = await userRepo.getUserStats(uid);
    final totalCheckins = (stats['totalCheckins'] ?? 0) + 1;
    final happyDays =
        (stats['happyDays'] ?? 0) + (mood == MoodType.happy ? 1 : 0);
    final sadDays = (stats['sadDays'] ?? 0) + (mood == MoodType.sad ? 1 : 0);
    await userRepo.updateUserStats(uid, {
      'totalCheckins': totalCheckins,
      'happyDays': happyDays,
      'sadDays': sadDays,
    });
  } catch (e) {
    // Stats update failed but checkin was created successfully
    print('[MoodBridge] Stats update failed during checkin: $e');
  }

  // Refresh providers
  ref.invalidate(todayCheckinProvider);
  ref.invalidate(userStatsProvider);

  return checkin;
}
