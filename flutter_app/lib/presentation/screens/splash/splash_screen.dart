import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    
    await authState.when(
      data: (user) async {
        if (user != null) {
          // Already logged in, go to home
          if (mounted) context.go(Routes.home);
        } else {
          // Not logged in - auto sign in anonymously
          try {
            final authRepo = ref.read(authRepositoryProvider);
            await authRepo.signInAnonymously();
            if (mounted) context.go(Routes.home);
          } catch (e) {
            // If anonymous sign-in fails, still go to home
            debugPrint('Anonymous sign-in error: $e');
            if (mounted) context.go(Routes.home);
          }
        }
      },
      loading: () async {
        // Wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _initAndNavigate();
      },
      error: (_, __) async {
        // Try anonymous sign-in on error
        try {
          final authRepo = ref.read(authRepositoryProvider);
          await authRepo.signInAnonymously();
          if (mounted) context.go(Routes.home);
        } catch (e) {
          debugPrint('Anonymous sign-in error: $e');
          if (mounted) context.go(Routes.home);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFA29BFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rainbow emoji logo
                const Text(
                  '🌈',
                  style: TextStyle(fontSize: 80),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  'MoodBridge',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Cầu Nối Tâm Trạng',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms),
                const SizedBox(height: 80),
                // Bouncing dots loader
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .scale(
                          delay: Duration(milliseconds: index * 160),
                          duration: 400.ms,
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: 400.ms,
                          begin: const Offset(1, 1),
                          end: const Offset(0.5, 0.5),
                          curve: Curves.easeInOut,
                        ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
