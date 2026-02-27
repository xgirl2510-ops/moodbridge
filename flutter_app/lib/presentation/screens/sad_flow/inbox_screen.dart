import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/theme.dart';
import '../../../data/models/encouragement_model.dart';
import '../../providers/encouragement_provider.dart';
import '../../providers/user_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _markedAsRead = false;

  void _markAllAsRead(List<EncouragementModel> messages) {
    if (_markedAsRead) return;
    _markedAsRead = true;
    final repo = ref.read(encouragementRepositoryProvider);
    for (final m in messages) {
      if (!m.isRead) {
        repo.markAsRead(m.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final inbox = ref.watch(inboxProvider);
    final unreadCount = inbox.maybeWhen(
      data: (messages) {
        // Mark all as read when inbox is viewed
        _markAllAsRead(messages);
        return messages.where((m) => !m.isRead).length;
      },
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Column(
        children: [
          // Header with pink gradient - matching Profile style
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: AppTheme.spacingXL,
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.pinkGradient,
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
                      'Hộp thư',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: Text(
                          '$unreadCount mới',
                          style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white),
                        ),
                      ),
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
                  child: const Center(
                    child: Text('💌', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  'Tin nhắn động viên',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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

}

class _MessageCard extends ConsumerWidget {
  final EncouragementModel message;

  const _MessageCard({required this.message});

  Future<void> _handleReaction(BuildContext context, WidgetRef ref, ReactionType reaction) async {
    if (reaction == ReactionType.wantToChat) {
      final controller = TextEditingController();
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '💬 Gửi tin nhắn',
            style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 3,
              maxLength: 200,
              style: GoogleFonts.beVietnamPro(),
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn của bạn...',
                hintStyle: GoogleFonts.beVietnamPro(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Huỷ', style: GoogleFonts.beVietnamPro()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Gửi', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      if (result != null && result.isNotEmpty) {
        await reactToEncouragement(ref, encouragementId: message.id, reaction: reaction, message: result);
        // Also create a reply in sender's inbox
        await sendReplyEncouragement(
          ref,
          originalEncouragementId: message.id,
          originalSenderId: message.senderId,
          content: result,
        );
      }
    } else {
      await reactToEncouragement(ref, encouragementId: message.id, reaction: reaction);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReacted = message.reaction != null;
    // Real-time sender display name (syncs when sender changes name)
    final senderNameAsync = ref.watch(userDisplayNameProvider(message.senderId));
    final senderName = senderNameAsync.valueOrNull ?? message.displayName;

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
                  gradient: message.isReply
                    ? const LinearGradient(
                        colors: [Color(0xFFa29bfe), Color(0xFF6c5ce7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFeaa7), Color(0xFFFdcb6e)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    message.isReply ? '💬' : '🌟',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      senderName,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (message.isReply)
                      Text(
                        '↩ Phản hồi tin động viên',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: const Color(0xFF6c5ce7),
                        ),
                      ),
                  ],
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
          const SizedBox(height: 12),
          // Reaction buttons (only for non-reply messages, before reacting)
          if (!hasReacted && !message.isReply)
            Row(
              children: [
                _ReactionButton(
                  emoji: '❤️',
                  label: 'Cảm ơn',
                  onTap: () => _handleReaction(context, ref, ReactionType.thanks),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '💕',
                  label: 'Thả tim',
                  onTap: () => _handleReaction(context, ref, ReactionType.feelingBetter),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '💬',
                  label: 'Kết nối',
                  onTap: () => _handleReaction(context, ref, ReactionType.wantToChat),
                ),
              ],
            )
          else
            // Show what they reacted with
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message.reaction == ReactionType.thanks ? '❤️ Đã cảm ơn' :
                message.reaction == ReactionType.feelingBetter ? '💕 Đã thả tim' :
                '💬 Đã kết nối',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ReactionButton({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
