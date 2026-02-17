import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../data/models/checkin_model.dart';
import '../../../data/models/encouragement_model.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/encouragement_provider.dart';
import '../../providers/user_provider.dart';

class MatchListScreen extends ConsumerWidget {
  const MatchListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sadUsers = ref.watch(sadUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Header with gradient - matching mockup
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: AppTheme.spacingXL,
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.happyGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go(Routes.home),
                      icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                const Text('🎉', style: TextStyle(fontSize: 50))
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Tuyệt vời!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  'Hãy lan toả niềm vui của bạn',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Match list
          Expanded(
            child: sadUsers.when(
              data: (matches) {
                if (matches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('😊', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: AppTheme.spacingL),
                        Text(
                          'Hôm nay mọi người đều vui!',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Chưa có ai cần động viên lúc này',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort: unsent first, already sent last
                final sentStates = <String, bool>{};
                for (final m in matches) {
                  sentStates[m.userId] = ref.watch(hasAlreadySentProvider(m.userId)).valueOrNull ?? false;
                }
                final sorted = List<CheckinModel>.from(matches)
                  ..sort((a, b) {
                    final aSent = sentStates[a.userId] ?? false;
                    final bSent = sentStates[b.userId] ?? false;
                    if (aSent == bSent) return 0;
                    return aSent ? 1 : -1; // unsent first
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final match = sorted[index];
                    return _MatchCard(
                      checkin: match,
                    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.2, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  final CheckinModel checkin;

  const _MatchCard({required this.checkin});

  String? _getReactionLabel(EncouragementModel? encouragement) {
    if (encouragement == null || encouragement.reaction == null) return null;
    switch (encouragement.reaction!) {
      case ReactionType.thanks:
        return '❤️ Cảm ơn';
      case ReactionType.feelingBetter:
        return '💕 Thả tim';
      case ReactionType.wantToChat:
        final msg = encouragement.reactionMessage;
        return msg != null && msg.isNotEmpty ? '💬 $msg' : '💬 Muốn kết nối';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alreadySent = ref.watch(hasAlreadySentProvider(checkin.userId)).valueOrNull ?? false;
    // Real-time display name (syncs when user changes name)
    final realTimeName = ref.watch(userDisplayNameProvider(checkin.userId)).valueOrNull ?? checkin.displayName;
    // Check if receiver reacted to our encouragement
    final sentToday = ref.watch(sentTodayProvider).valueOrNull ?? [];
    final sentToThis = sentToday.where((e) => e.receiverId == checkin.userId).toList();
    final sentEncouragement = sentToThis.isNotEmpty ? sentToThis.first : null;
    final reactionLabel = _getReactionLabel(sentEncouragement);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: alreadySent ? null : () {
            context.push(
              Routes.sendEncouragement,
              extra: {
                'recipientId': checkin.userId,
                'recipientName': realTimeName,
                'recipientNote': checkin.note,
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with mask emoji
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: AppTheme.sadGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text('🎭', style: TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        realTimeName,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (checkin.note != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          '"${checkin.note}"',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('🕐', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              timeago.format(checkin.createdAt, locale: 'vi'),
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: alreadySent
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Đã gửi',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (reactionLabel != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                reactionLabel,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          context.push(
                            Routes.sendEncouragement,
                            extra: {
                              'recipientId': checkin.userId,
                              'recipientName': realTimeName,
                              'recipientNote': checkin.note,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Động viên',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
