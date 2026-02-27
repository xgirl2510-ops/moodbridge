import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/checkin_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _ensureProfile();
  }

  Future<void> _ensureProfile() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ensureUserProfile(ref, uid, null);
    ref.invalidate(currentUserProvider);
  }

  Future<void> _logout() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid != null) {
      await NotificationService().removeFcmToken(uid);
    }
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    if (mounted) context.go(Routes.login);
  }

  Future<void> _toggleSetting(String field, bool value) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref.read(userRepositoryProvider).updateUser(uid, {field: value});
    ref.invalidate(currentUserProvider);

    // Update local notification schedule when reminder settings change
    if (field == 'checkinReminderEnabled') {
      final user = ref.read(currentUserProvider).value;
      await NotificationService().scheduleCheckinReminder(
        enabled: value,
        time: user?.checkinReminderTime ?? '09:00',
      );
    }
  }

  Future<void> _editDisplayName() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    
    final controller = TextEditingController(text: user.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đổi tên hiển thị',
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          style: GoogleFonts.beVietnamPro(),
          decoration: InputDecoration(
            hintText: 'Nhập tên mới...',
            hintStyle: GoogleFonts.beVietnamPro(color: AppTheme.textLight),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Huỷ', style: GoogleFonts.beVietnamPro()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Lưu', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && result != user.displayName) {
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;
      await ref.read(userRepositoryProvider).updateUser(uid, {
        'displayName': result,
        'anonymousId': result,
      });
      // Also update today's checkin document so other users see the new name
      final checkinRepo = ref.read(checkinRepositoryProvider);
      final checkin = await checkinRepo.getTodayCheckin(uid);
      if (checkin != null) {
        await checkinRepo.updateUserDisplayInfo(
          checkin.id,
          userAnonymousId: result,
          userDisplayName: result,
        );
      }
      ref.invalidate(todayCheckinProvider);
      ref.invalidate(currentUserProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppTheme.spacingM,
                left: AppTheme.spacingL,
                right: AppTheme.spacingL,
                bottom: AppTheme.spacingXL,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
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
                        'Cá nhân',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox.shrink(),
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
                    child: const Icon(LucideIcons.user, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  userAsync.when(
                    data: (user) => GestureDetector(
                      onTap: _editDisplayName,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user?.anonymousId ?? 'User',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Text('Lỗi', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Text(
                      'Ẩn danh',
                      style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: userAsync.when(
                data: (user) => _buildSettings(user),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Lỗi tải dữ liệu')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(dynamic user) {
    final pushEnabled = user?.pushEnabled ?? true;
    final checkinReminder = user?.checkinReminderEnabled ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Thông báo'),
        _SettingCard(
          children: [
            _ToggleSetting(
              icon: LucideIcons.bell,
              title: 'Thông báo đẩy',
              value: pushEnabled,
              onChanged: (v) => _toggleSetting('pushEnabled', v),
            ),
            const Divider(height: 1),
            _ToggleSetting(
              icon: LucideIcons.clock,
              title: 'Nhắc check-in',
              subtitle: '9:00 AM mỗi ngày',
              value: checkinReminder,
              onChanged: (v) => _toggleSetting('checkinReminderEnabled', v),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppTheme.spacingL),

        const SizedBox(height: AppTheme.spacingXL),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: AppTheme.spacingL),

        Center(
          child: Text(
            'MoodBridge v1.0.0',
            style: GoogleFonts.beVietnamPro(color: AppTheme.textLight, fontSize: 12),
          ),
        ),
        const SizedBox(height: AppTheme.spacingXL),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingXS, bottom: AppTheme.spacingS),
      child: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.beVietnamPro(fontSize: 15, color: AppTheme.textPrimary),
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppTheme.textLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.beVietnamPro(fontSize: 15, color: AppTheme.textPrimary),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppTheme.textLight),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
