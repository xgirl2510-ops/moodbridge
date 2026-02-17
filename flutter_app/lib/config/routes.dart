import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/happy_flow/match_list_screen.dart';
import '../presentation/screens/happy_flow/send_encouragement_screen.dart';
import '../presentation/screens/sad_flow/inbox_screen.dart';
import '../presentation/screens/stats/stats_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const matchList = '/match-list';
  static const sendEncouragement = '/send-encouragement';
  static const inbox = '/inbox';
  static const stats = '/stats';
  static const profile = '/profile';
}

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      // Splash (no bottom nav)
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Match list moved to ShellRoute for bottom nav

      // Send encouragement (no bottom nav)
      GoRoute(
        path: Routes.sendEncouragement,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SendEncouragementScreen(
            recipientId: extra?['recipientId'] ?? '',
            recipientName: extra?['recipientName'] ?? 'Người lạ',
            recipientNote: extra?['recipientNote'],
          );
        },
      ),

      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.inbox,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InboxScreen(),
            ),
          ),
          GoRoute(
            path: Routes.stats,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: Routes.matchList,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MatchListScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
