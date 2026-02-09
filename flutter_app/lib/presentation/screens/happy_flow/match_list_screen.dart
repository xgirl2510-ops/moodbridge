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
import '../../providers/checkin_provider.dart';

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
                      onPressed: () => context.pop(),
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

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return _MatchCard(
                      checkin: match,
                      onTap: () {
                        context.push(
                          Routes.sendEncouragement,
                          extra: {
                            'recipientId': match.userId,
                            'recipientName': match.displayName,
                            'recipientNote': match.note,
                          },
                        );
                      },
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

class _MatchCard extends StatelessWidget {
  final CheckinModel checkin;
  final VoidCallback onTap;

  const _MatchCard({required this.checkin, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                        checkin.displayName,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
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
                          Text(
                            timeago.format(checkin.createdAt, locale: 'vi'),
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Động viên',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
