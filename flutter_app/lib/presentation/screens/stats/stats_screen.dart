import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme.dart';
import '../../../core/constants/badges.dart';
import '../../../data/models/checkin_model.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/user_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final historyAsync = ref.watch(checkinHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Header with green gradient - matching Profile style
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: AppTheme.spacingXL,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6BCB77), Color(0xFF38ADA9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusXLarge),
                bottomRight: Radius.circular(AppTheme.radiusXLarge),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thống kê',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(LucideIcons.trendingUp, color: Colors.white),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                  child: const Icon(LucideIcons.barChart2, size: 40, color: Colors.white),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Thống kê của bạn',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          Expanded(
            child: statsAsync.when(
              data: (stats) => _buildStatsContent(context, stats, historyAsync),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(
    BuildContext context,
    Map<String, dynamic> stats,
    AsyncValue<List<CheckinModel>> historyAsync,
  ) {
    final totalSent = stats['totalSent'] ?? 0;
    final peopleHelped = stats['peopleHelped'] ?? 0;
    final currentStreak = stats['currentStreak'] ?? 0;
    final badges = List<String>.from(stats['badges'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week mood calendar
          historyAsync.when(
            data: (history) => _buildWeekCalendar(history),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // Impact cards
          Row(
            children: [
              Expanded(
                child: _ImpactCard(
                  value: '$totalSent',
                  label: 'Tin đã gửi',
                  icon: LucideIcons.send,
                  iconColor: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _ImpactCard(
                  value: '$peopleHelped',
                  label: 'Người đã giúp',
                  icon: LucideIcons.heart,
                  iconColor: const Color(0xFF6BCB77),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),

          // Streak card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFD79A8), Color(0xFFE84393)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentStreak ngày',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gửi động viên liên tiếp',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 20),

          // Badges section
          _buildBadgesSection(badges, totalSent, currentStreak, peopleHelped),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(List<CheckinModel> history) {
    final weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final last7 = history.take(7).toList().reversed.toList();

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuần này',
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final hasCheckin = index < last7.length;
              final isHappy = hasCheckin && last7[index].mood == MoodType.happy;
              return Column(
                children: [
                  Text(
                    weekDays[index],
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasCheckin ? (isHappy ? '😊' : '😢') : '•',
                    style: TextStyle(
                      fontSize: hasCheckin ? 28 : 20,
                      color: hasCheckin ? null : AppTheme.textLight,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBadgesSection(
    List<String> earnedBadgeCodes,
    int totalSent,
    int currentStreak,
    int peopleHelped,
  ) {
    final earned = AppBadges.getEarnedBadges(
      totalSent: totalSent,
      currentStreak: currentStreak,
      peopleHelped: peopleHelped,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Badges',
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: AppBadges.all.take(4).map((badge) {
              final isEarned = earned.any((e) => e.code == badge.code);
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: _BadgeItem(
                  icon: badge.icon,
                  name: badge.name,
                  isLocked: !isEarned,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _ImpactCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _ImpactCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.beVietnamPro(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String icon;
  final String name;
  final bool isLocked;

  const _BadgeItem({
    required this.icon,
    required this.name,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.3 : 1.0,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isLocked ? const Color(0xFFF8F9FE) : AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(
              fontSize: 28,
              color: isLocked ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }
}
