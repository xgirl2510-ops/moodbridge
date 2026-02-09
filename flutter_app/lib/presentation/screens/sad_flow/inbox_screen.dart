import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';
import '../../../data/models/encouragement_model.dart';
import '../../providers/encouragement_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    final unreadCount = inbox.maybeWhen(
      data: (messages) => messages.where((m) => m.reaction == null).length,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Header with pink gradient - matching mockup
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: AppTheme.spacingXL,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacingM),
                const Text('💌', style: TextStyle(fontSize: 50))
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Tin nhắn động viên',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unreadCount tin mới',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B9D),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Message list
          Expanded(
            child: inbox.when(
              data: (messages) {
                if (messages.isEmpty) return _EmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageCard(
                      message: message,
                      onReact: (reaction) => _handleReaction(ref, message, reaction),
                    ).animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index))
                        .slideY(begin: 0.2, end: 0);
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

  void _handleReaction(WidgetRef ref, EncouragementModel message, ReactionType reaction) {
    reactToEncouragement(ref, encouragementId: message.id, reaction: reaction);
  }
}

class _MessageCard extends StatelessWidget {
  final EncouragementModel message;
  final Function(ReactionType) onReact;

  const _MessageCard({required this.message, required this.onReact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFeaa7), Color(0xFFFdcb6e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🌟', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message.displayName,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message.content ?? '',
            style: GoogleFonts.beVietnamPro(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 15),
          if (message.reaction != null)
            _ReactionBadge(reaction: message.reaction!)
          else
            Row(
              children: [
                _ReactionChip(
                  emoji: '❤️',
                  label: 'Cảm ơn',
                  isSelected: false,
                  onTap: () => onReact(ReactionType.thanks),
                ),
                const SizedBox(width: 10),
                _ReactionChip(
                  emoji: '😊',
                  label: 'Vui hơn',
                  isSelected: false,
                  onTap: () => onReact(ReactionType.feelingBetter),
                ),
                const SizedBox(width: 10),
                _ReactionChip(
                  emoji: '💬',
                  label: null,
                  isSelected: false,
                  onTap: () => onReact(ReactionType.wantToChat),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  final String emoji;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReactionChip({
    required this.emoji,
    this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppTheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? AppTheme.primary : const Color(0xFFE8E8E8),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionBadge extends StatelessWidget {
  final ReactionType reaction;
  const _ReactionBadge({required this.reaction});

  String get _label {
    switch (reaction) {
      case ReactionType.thanks:
        return '❤️ Đã cảm ơn';
      case ReactionType.feelingBetter:
        return '😊 Đã vui hơn';
      case ReactionType.wantToChat:
        return '💬 Đã gửi kết nối';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        _label,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 60)),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Chưa có tin nhắn',
            style: GoogleFonts.beVietnamPro(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Lời động viên sẽ xuất hiện ở đây\nkhi có người gửi cho bạn!',
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
