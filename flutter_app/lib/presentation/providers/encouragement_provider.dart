import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/encouragement_model.dart';
import '../../data/repositories/encouragement_repository.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Repository provider
final encouragementRepositoryProvider =
    Provider<EncouragementRepository>((ref) {
  return EncouragementRepository();
});

/// Inbox stream (received encouragements for current user)
final inboxProvider = StreamProvider<List<EncouragementModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.read(encouragementRepositoryProvider).getInboxStream(uid);
});

/// Send an encouragement message
Future<bool> sendEncouragementMessage(
  WidgetRef ref, {
  required String receiverId,
  required MessageType messageType,
  String? content,
  String? templateId,
  String? receiverCheckinId,
}) async {
  final uid = ref.read(currentUserIdProvider);
  if (uid == null) return false;

  final encRepo = ref.read(encouragementRepositoryProvider);

  // Check spam limit: 1 message per person per day
  final alreadySent = await encRepo.hasAlreadySent(uid, receiverId);
  if (alreadySent) return false;

  final user = ref.read(currentUserProvider).value;

  final encouragement = EncouragementModel(
    id: '',
    senderId: uid,
    receiverId: receiverId,
    receiverCheckinId: receiverCheckinId,
    messageType: messageType,
    content: content,
    templateId: templateId,
    createdAt: DateTime.now(),
    senderAnonymousId: user?.anonymousId ?? 'User#0000',
    senderDisplayName: user?.isPublic == true ? user?.displayName : null,
    senderAvatarUrl: user?.avatarUrl,
  );

  await encRepo.sendEncouragement(encouragement);

  // Update sender stats
  final userRepo = ref.read(userRepositoryProvider);
  final stats = await userRepo.getUserStats(uid);
  final totalSent = (stats['totalSent'] ?? 0) + 1;
  await userRepo.updateUserStats(uid, {
    'totalSent': totalSent,
    'lastSendDate': DateTime.now().toIso8601String().substring(0, 10),
  });

  ref.invalidate(userStatsProvider);
  return true;
}

/// React to an encouragement
Future<void> reactToEncouragement(
  WidgetRef ref, {
  required String encouragementId,
  required ReactionType reaction,
}) async {
  final encRepo = ref.read(encouragementRepositoryProvider);

  String reactionStr;
  switch (reaction) {
    case ReactionType.thanks:
      reactionStr = 'thanks';
    case ReactionType.feelingBetter:
      reactionStr = 'feeling_better';
    case ReactionType.wantToChat:
      reactionStr = 'want_to_chat';
  }

  await encRepo.addReaction(encouragementId, reactionStr);
}
