import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

/// Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Current user profile from Firestore
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  return ref.read(userRepositoryProvider).getUser(uid);
});

/// User stats (totalSent, streak, badges, etc.)
final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return {};
  return ref.read(userRepositoryProvider).getUserStats(uid);
});

/// Create user profile after auth signup
Future<void> createUserProfile(WidgetRef ref, String uid, String? email) async {
  final userRepo = ref.read(userRepositoryProvider);
  final anonymousId = userRepo.generateAnonymousId();
  final now = DateTime.now();

  final user = UserModel(
    uid: uid,
    email: email,
    displayName: anonymousId,
    anonymousId: anonymousId,
    createdAt: now,
    updatedAt: now,
    lastActiveAt: now,
  );

  await userRepo.createUser(user);
}
