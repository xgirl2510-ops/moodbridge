import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../core/constants/templates.dart';
import '../../../data/models/encouragement_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/encouragement_provider.dart';
import '../../providers/user_provider.dart';

class SendEncouragementScreen extends ConsumerStatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? recipientNote;

  const SendEncouragementScreen({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.recipientNote,
  });

  @override
  ConsumerState<SendEncouragementScreen> createState() =>
      _SendEncouragementScreenState();
}

class _SendEncouragementScreenState
    extends ConsumerState<SendEncouragementScreen> {
  final _customMessageController = TextEditingController();
  String? _selectedTemplateId;
  bool _isCustomMessage = false;
  bool _isSending = false;
  late List<MessageTemplate> _shuffledTemplates;

  static const int _customMessageUnlockThreshold = 5;

  @override
  void initState() {
    super.initState();
    // Shuffle templates randomly each time screen opens
    _shuffledTemplates = List<MessageTemplate>.from(AppTemplates.all)..shuffle();
    // Auto-select first template (random after shuffle)
    if (_shuffledTemplates.isNotEmpty) {
      _selectedTemplateId = _shuffledTemplates.first.id;
    }
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _sendEncouragement() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      context.go(Routes.login);
      return;
    }

    if (!_isCustomMessage && _selectedTemplateId == null) return;
    if (_isCustomMessage && _customMessageController.text.trim().isEmpty) return;

    // Ensure user profile exists before sending
    await ensureUserProfile(ref, uid, null);
    await _doSend();
  }

  Future<void> _doSend() async {
    setState(() => _isSending = true);

    try {
      String? content;
      MessageType messageType;
      String? templateId;

      if (_isCustomMessage) {
        content = _customMessageController.text.trim();
        messageType = MessageType.text;
        templateId = null;
      } else {
        final template = AppTemplates.getById(_selectedTemplateId!);
        content = template?.content;
        templateId = _selectedTemplateId;
        messageType = MessageType.template;
      }

      final success = await sendEncouragementMessage(
        ref,
        receiverId: widget.recipientId,
        messageType: messageType,
        content: content,
        templateId: templateId,
      );

      if (!mounted) return;

      if (success) {
        // Refresh providers
        ref.invalidate(totalSentCountProvider);
        ref.invalidate(hasAlreadySentProvider(widget.recipientId));
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn đã gửi cho người này hôm nay rồi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), duration: const Duration(seconds: 5)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 60))
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Đã gửi!',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Lời động viên của bạn đã được gửi đi.\nCảm ơn bạn đã lan toả niềm vui!',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Tiếp tục',
                    style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
              left: AppTheme.spacingM,
              right: AppTheme.spacingM,
              bottom: AppTheme.spacingL,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text('←', style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'Gửi động viên',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildRecipientInfo(),
                  _buildMessageOptions(),
                ],
              ),
            ),
          ),
          _buildSendButton(context),
        ],
      ),
    );
  }

  Widget _buildRecipientInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF0F0F0)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppTheme.sadGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Center(
              child: Text('🎭', style: TextStyle(fontSize: 35)),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.recipientName,
            style: GoogleFonts.beVietnamPro(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (widget.recipientNote != null) ...[
            const SizedBox(height: 5),
            Text(
              '"${widget.recipientNote}"',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageOptions() {
    final totalSentAsync = ref.watch(totalSentCountProvider);
    final totalSent = totalSentAsync.valueOrNull ?? 0;
    final customUnlocked = totalSent >= _customMessageUnlockThreshold;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn lời động viên:',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 15),

          // Custom message input - on top, only visible after 5 sends
          if (customUnlocked) ...[
            GestureDetector(
              onTap: () => setState(() {
                _isCustomMessage = true;
                _selectedTemplateId = null;
              }),
              child: AnimatedContainer(
                duration: AppTheme.animationFast,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _isCustomMessage
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _isCustomMessage ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('✏️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Viết lời động viên riêng',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          fontWeight: _isCustomMessage ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_isCustomMessage)
                      const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                  ],
                ),
              ),
            ),
            if (_isCustomMessage) ...[
              TextField(
                controller: _customMessageController,
                maxLines: 3,
                maxLength: 200,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.beVietnamPro(),
                decoration: InputDecoration(
                  hintText: 'Viết lời động viên của bạn...',
                  hintStyle: GoogleFonts.beVietnamPro(color: AppTheme.textLight),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ] else ...[
            // Show progress hint toward unlocking custom message
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gửi $totalSent/$_customMessageUnlockThreshold lời động viên để mở khoá viết riêng',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Template buttons (shuffled)
          ..._shuffledTemplates.map((template) {
            final isSelected = _selectedTemplateId == template.id && !_isCustomMessage;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedTemplateId = template.id;
                _isCustomMessage = false;
              }),
              child: AnimatedContainer(
                duration: AppTheme.animationFast,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Text(template.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        template.content,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final canSend = _isCustomMessage
        ? _customMessageController.text.trim().isNotEmpty
        : _selectedTemplateId != null;


    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canSend ? (_isSending ? null : _sendEncouragement) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSending)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              else ...[
                Text(
                  'Gửi đi 💕',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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

// Removed _ActionButton - only template selection allowed
