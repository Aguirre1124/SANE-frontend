import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isLoading) {
      ref.listenManual(authProvider, (_, next) {
        if (!next.isLoading && mounted) {
          _go(next.asData?.value != null);
        }
      });
    } else {
      _go(auth.asData?.value != null);
    }
  }

  void _go(bool isLoggedIn) {
    if (!mounted) return;
    if (isLoggedIn) {
      context.go('/app/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.verified_user,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text('SANE',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    )),
            const SizedBox(height: 6),
            Text('Smart Alimentary Navigator',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 40),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
