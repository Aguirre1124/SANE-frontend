import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/diagnostic_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/business/business_detail_screen.dart';
import '../screens/business/create_business_screen.dart';
import '../screens/business/edit_business_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/diagnostic/diagnostic_list_screen.dart';
import '../screens/diagnostic/diagnostic_result_screen.dart';
import '../screens/diagnostic/question_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/routes/route_detail_screen.dart';
import '../screens/routes/route_list_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.asData?.value != null;
      final loc = state.matchedLocation;

      if (isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      final isAuthRoute = loc == '/login' || loc == '/register';
      if (!isLoggedIn && !isAuthRoute && loc != '/splash') {
        return '/login';
      }
      if (isLoggedIn && (isAuthRoute || loc == '/splash')) {
        return '/app/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (c, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/home',
              builder: (c, s) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'business/create',
                  builder: (c, s) => const CreateBusinessScreen(),
                ),
                GoRoute(
                  path: 'business/:id',
                  builder: (_, s) => BusinessDetailScreen(
                    businessId: s.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, s) => EditBusinessScreen(
                        businessId: s.pathParameters['id']!,
                      ),
                    ),
                    GoRoute(
                      path: 'diagnostics',
                      builder: (_, s) => DiagnosticListScreen(
                        businessId: s.pathParameters['id']!,
                      ),
                    ),
                    GoRoute(
                      path: 'chat',
                      builder: (_, s) => ChatScreen(
                        businessId: s.pathParameters['id']!,
                      ),
                    ),
                    GoRoute(
                      path: 'progress',
                      builder: (_, s) => ProgressScreen(
                        businessId: s.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'diagnostic/:sessionId/question',
                  builder: (_, s) => QuestionScreen(
                    sessionId: s.pathParameters['sessionId']!,
                    businessId: (s.extra as Map?)?['businessId'] as String?,
                  ),
                ),
                GoRoute(
                  path: 'diagnostic/:sessionId/result',
                  builder: (_, s) => DiagnosticResultScreen(
                    sessionId: s.pathParameters['sessionId']!,
                    preloadedResult: s.extra is DiagnosticResult
                        ? s.extra as DiagnosticResult
                        : null,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/routes',
              builder: (c, s) => const RouteListScreen(),
              routes: [
                GoRoute(
                  path: ':routeId',
                  builder: (_, s) => RouteDetailScreen(
                    routeId: s.pathParameters['routeId']!,
                    businessId: (s.extra as Map?)?['businessId'] as String?,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/app/profile',
              builder: (c, s) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );

  ref.listen(authProvider, (prev, next) {
    router.refresh();
  });

  return router;
});
