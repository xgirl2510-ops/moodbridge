import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../data/models/checkin_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/encouragement_provider.dart';
import '../../providers/user_provider.dart';
import '../../../services/notification_service.dart';
import '../../widgets/mood/mood_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();
  final _noteKey = GlobalKey();
  MoodType? _selectedMood;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _noteFocusNode.addListener(() {
      if (_noteFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_noteKey.currentContext != null) {
            Scrollable.ensureVisible(
              _noteKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            );
          }
        });
      }
    });
  }

  Future<void> _setupNotifications() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;

    // Ensure user profile exists (handles DB wipe scenario)
    await ensureUserProfile(ref, uid, null);
    ref.invalidate(currentUserProvider);

    final notifService = NotificationService();

    // Save FCM token to Firestore
    await notifService.saveFcmToken(uid);

    // Schedule check-in reminder based on user settings
    final user = ref.read(currentUserProvider).value;
    await notifService.scheduleCheckinReminder(
      enabled: user?.checkinReminderEnabled ?? true,
      time: user?.checkinReminderTime ?? '09:00',
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng! ☀️';
    if (hour < 18) return 'Chào buổi chiều! 🌤️';
    return 'Chào buổi tối! 🌙';
  }

  void _onMoodSelected(MoodType mood) {
    setState(() => _selectedMood = mood);
    Future.delayed(const Duration(milliseconds: 300), () {
      _submitCheckin(mood);
    });
  }

  Future<void> _submitCheckin(MoodType mood) async {
    if (_isSubmitting) return;

    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      context.go(Routes.login);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Ensure user profile exists (handles DB wipe scenario)
      await ensureUserProfile(ref, uid, null);

      await submitCheckin(
        ref,
        mood: mood,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        wantsEncouragement: false, // Initially false; updated by bottom sheet for sad users
      );

      if (!mounted) return;

      // For sad users, show confirmation bottom sheet
      if (mood == MoodType.sad) {
        _showSadConfirmation();
      }
      // For happy users, stay on home screen to show "already checked in" state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _selectedMood = null;
        });
      }
    }
  }

  void _showSadConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const Text('💙', style: TextStyle(fontSize: 60)),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Mình hiểu...',
              style: GoogleFonts.beVietnamPro(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Ai cũng có lúc không vui.\nBạn có muốn nhận lời động viên từ người khác không?',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Không, cảm ơn',
                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Update wantsEncouragement to true
                      final checkin = ref.read(todayCheckinProvider).value;
                      if (checkin != null) {
                        await ref.read(checkinRepositoryProvider).updateWantsEncouragement(checkin.id, true);
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      context.go(Routes.inbox);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'Có, mình muốn',
                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayCheckin = ref.watch(todayCheckinProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF8F9FE),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🌈', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'MoodBridge',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppTheme.spacingXXL),

              todayCheckin.when(
                data: (checkin) {
                  if (checkin != null) {
                    return _AlreadyCheckedIn(checkin: checkin);
                  }
                  return _buildCheckinUI();
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => _buildCheckinUI(),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCheckinUI() {
    return Column(
      children: [
        // Greeting
        Center(
          child: Column(
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Hôm nay bạn cảm thấy thế nào?',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 17,
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Mood buttons
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MoodButton(
                isHappy: true,
                isSelected: _selectedMood == MoodType.happy,
                onTap: () => _onMoodSelected(MoodType.happy),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3, end: 0),
              const SizedBox(width: 20),
              MoodButton(
                isHappy: false,
                isSelected: _selectedMood == MoodType.sad,
                onTap: () => _onMoodSelected(MoodType.sad),
              ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Note input
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Thêm ghi chú (tuỳ chọn)',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ).animate().fadeIn(delay: 700.ms),
        const SizedBox(height: AppTheme.spacingS),
        TextField(
          key: _noteKey,
          controller: _noteController,
          focusNode: _noteFocusNode,
          maxLength: 200,
          maxLines: 2,
          style: GoogleFonts.beVietnamPro(),
          decoration: InputDecoration(
            hintText: 'Hôm nay tôi cảm thấy...',
            hintStyle: GoogleFonts.beVietnamPro(color: AppTheme.textLight),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ).animate().fadeIn(delay: 800.ms),

        const SizedBox(height: AppTheme.spacingXXL),

        // Info card
        _buildInfoCard(),

        if (_isSubmitting)
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spacingXL),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(LucideIcons.info, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cách hoạt động',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nếu bạn VUI, hãy gửi động viên cho người đang buồn. Nếu bạn BUỒN, bạn sẽ nhận được lời động viên!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0);
  }
}

class _AlreadyCheckedIn extends ConsumerWidget {
  final CheckinModel checkin;
  const _AlreadyCheckedIn({required this.checkin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHappy = checkin.mood == MoodType.happy;
    final sadUsers = isHappy ? ref.watch(sadUsersProvider) : null;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spacingXXL),
          Text(
            isHappy ? '😊' : '😢',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Bạn đã check-in hôm nay',
            style: GoogleFonts.beVietnamPro(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            isHappy ? 'Bạn đang vui! Hãy lan toả niềm vui.' : 'Hãy chờ tin động viên trong Inbox.',
            style: GoogleFonts.beVietnamPro(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          if (isHappy)
            sadUsers?.when(
              data: (matches) {
                final hasSadUsers = matches.isNotEmpty;
                return ElevatedButton(
                  onPressed: hasSadUsers ? () {
                    context.go(Routes.matchList);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    disabledBackgroundColor: AppTheme.border,
                    disabledForegroundColor: AppTheme.textLight,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(hasSadUsers ? '❤️' : '😊', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        hasSadUsers ? 'Gửi động viên' : 'Chưa có ai cần động viên',
                        style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  'Chưa có ai cần động viên',
                  style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ) ?? const SizedBox.shrink()
          else
            Builder(
              builder: (context) {
                final inbox = ref.watch(inboxProvider);
                final unreadCount = inbox.maybeWhen(
                  data: (messages) => messages.where((m) => !m.isRead).length,
                  orElse: () => 0,
                );
                return ElevatedButton(
                  onPressed: () => context.go(Routes.inbox),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📬', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        unreadCount > 0 ? 'Xem Inbox ($unreadCount mới)' : 'Xem Inbox',
                        style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
