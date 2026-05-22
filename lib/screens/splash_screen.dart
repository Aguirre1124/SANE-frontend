import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/animated_orbs_background.dart';
import '../widgets/sane_logo.dart';

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
      body: AnimatedOrbsBackground(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SaneLogo(width: 180),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
