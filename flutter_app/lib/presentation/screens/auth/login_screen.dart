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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // toggle login/signup
  bool _isLoading = false;
  String? _error;

  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Vui long nhap email va mat khau');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Mat khau phai co it nhat 6 ky tu');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (_isLogin) {
        final cred = await authRepo.signInWithEmail(email, password);
        await ensureUserProfile(ref, cred.user!.uid, email);
      } else {
        final cred = await authRepo.signUpWithEmail(email, password);
        await createUserProfile(ref, cred.user!.uid, email);
      }
      if (mounted) context.go(Routes.home);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final cred = await authRepo.signInAnonymously();
      await createUserProfile(ref, cred.user!.uid, null);
      if (mounted) context.go(Routes.home);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.spacingXXL),
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.rainbow,
                  size: 50,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'MoodBridge',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                'Cau Noi Tam Trang',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppTheme.spacingXXL),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(LucideIcons.mail, size: 20),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: AppTheme.spacingM),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Mat khau',
                  prefixIcon: Icon(LucideIcons.lock, size: 20),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: AppTheme.spacingS),

              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: Text(
                    _error!,
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),

              const SizedBox(height: AppTheme.spacingL),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEmailAuth,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLogin ? 'Dang nhap' : 'Dang ky'),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: AppTheme.spacingM),

              // Toggle login/signup
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = !_isLogin;
                  _error = null;
                }),
                child: Text(
                  _isLogin
                      ? 'Chua co tai khoan? Dang ky'
                      : 'Da co tai khoan? Dang nhap',
                  style: GoogleFonts.beVietnamPro(color: AppTheme.primary),
                ),
              ),

              const SizedBox(height: AppTheme.spacingL),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                    child: Text(
                      'hoac',
                      style: GoogleFonts.beVietnamPro(
                        color: AppTheme.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Anonymous sign-in
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInAnonymously,
                  icon: const Icon(LucideIcons.userPlus),
                  label: const Text('Dung thu khong can dang ky'),
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
