import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    if (mounted) context.go(Routes.login);
  }

  Future<void> _toggleSetting(String field, bool value) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref.read(userRepositoryProvider).updateUser(uid, {field: value});
    ref.invalidate(currentUserProvider);
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
                        'Cai dat',
                        style: GoogleFonts.lora(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(LucideIcons.settings, color: Colors.white),
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
                    data: (user) => Text(
                      user?.anonymousId ?? 'User',
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
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
                      'An danh',
                      style: GoogleFonts.raleway(fontSize: 12, color: Colors.white),
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
                error: (_, __) => const Center(child: Text('Loi tai du lieu')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(dynamic user) {
    final receiveEnc = user?.receiveEncouragements ?? true;
    final pushEnabled = user?.pushEnabled ?? true;
    final checkinReminder = user?.checkinReminderEnabled ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Quyen rieng tu'),
        _SettingCard(
          children: [
            _ToggleSetting(
              icon: LucideIcons.heart,
              title: 'Nhan tin dong vien',
              subtitle: 'Khi ban check-in buon',
              value: receiveEnc,
              onChanged: (v) => _toggleSetting('receiveEncouragements', v),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppTheme.spacingL),

        _SectionTitle(title: 'Thong bao'),
        _SettingCard(
          children: [
            _ToggleSetting(
              icon: LucideIcons.bell,
              title: 'Push notifications',
              value: pushEnabled,
              onChanged: (v) => _toggleSetting('pushEnabled', v),
            ),
            const Divider(height: 1),
            _ToggleSetting(
              icon: LucideIcons.clock,
              title: 'Nhac check-in',
              subtitle: '9:00 AM moi ngay',
              value: checkinReminder,
              onChanged: (v) => _toggleSetting('checkinReminderEnabled', v),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppTheme.spacingL),

        _SectionTitle(title: 'Thong tin'),
        _SettingCard(
          children: [
            _SettingItem(
              icon: LucideIcons.helpCircle,
              title: 'Tro giup',
              onTap: () {},
            ),
            const Divider(height: 1),
            _SettingItem(
              icon: LucideIcons.shield,
              title: 'Chinh sach bao mat',
              onTap: () {},
            ),
            const Divider(height: 1),
            _SettingItem(
              icon: LucideIcons.fileText,
              title: 'Dieu khoan su dung',
              onTap: () {},
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: AppTheme.spacingXL),

        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(LucideIcons.logOut),
            label: const Text('Dang xuat'),
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
            style: GoogleFonts.raleway(color: AppTheme.textLight, fontSize: 12),
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
        style: GoogleFonts.raleway(
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
                  style: GoogleFonts.raleway(fontSize: 15, color: AppTheme.textPrimary),
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
                  style: GoogleFonts.raleway(fontSize: 15, color: AppTheme.textPrimary),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.raleway(fontSize: 12, color: AppTheme.textLight),
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
