import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/status_chip.dart';

class DiagnosticListScreen extends ConsumerWidget {
  const DiagnosticListScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(diagnosticSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DiagnosticHeader(
                onBack: () => context.pop(),
              ),
              Expanded(
                child: sessionsAsync.when(
                  loading: () => const _DiagnosticShimmerList(),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () {
                      ref.read(diagnosticListRefreshProvider.notifier).update((s) => s + 1);
                    },
                  ),
                  data: (sessions) {
                    final filtered = sessions
                        .where((s) => s.businessId == businessId || s.businessId == null)
                        .toList()
                      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Sin diagnósticos',
                        subtitle:
                            'Inicia un diagnóstico sanitario para conocer qué trámites necesitas.',
                        action: ElevatedButton.icon(
                          onPressed: () => _startNewDiagnostic(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Iniciar diagnóstico'),
                        ),
                      );
                    }

                    return ResponsiveCenter(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xxxl,
                      ),
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _DiagnosticCard(
                          session: filtered[i],
                          onTap: () {
                            if (filtered[i].status == 'completed') {
                              context.push(
                                  '/app/diagnostic/${filtered[i].sessionId}/result');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _NewDiagnosticFAB(
        onPressed: () => _startNewDiagnostic(context, ref),
      ),
    );
  }

  Future<void> _startNewDiagnostic(
      BuildContext context, WidgetRef ref) async {
    try {
      final notifier =
          ref.read(diagnosticFlowProvider(businessId).notifier);
      final result = await notifier.startDiagnostic(businessId: businessId);
      if (context.mounted) {
        context.push('/app/diagnostic/${result.sessionId}/question',
            extra: {'businessId': businessId, 'fromFlow': true});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard({required this.session, required this.onTap});

  final DiagnosticSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == 'completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: PremiumCard(
        onTap: isCompleted ? onTap : null,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_outline
                    : Icons.hourglass_bottom,
                color:
                    isCompleted ? AppColors.success : AppColors.info,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusChip(
                          value: session.status,
                          type: ChipType.diagnosticStatus),
                      if (session.totalInteractions != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${session.totalInteractions} respuestas',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(session.startedAt),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

// ── Header glassmorphism ──────────────────────────────────────────────────────

class _DiagnosticHeader extends StatelessWidget {
  const _DiagnosticHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack,
                tooltip: 'Volver',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Diagnósticos', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Evaluación sanitaria',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _DiagnosticShimmerList extends StatelessWidget {
  const _DiagnosticShimmerList();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, _) => const _DiagnosticCardSkeleton(),
      ),
    );
  }
}

class _DiagnosticCardSkeleton extends StatelessWidget {
  const _DiagnosticCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            ShimmerLoader(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoader(
                    width: 100,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  ShimmerLoader(
                    width: 150,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── New Diagnostic FAB with glow ──────────────────────────────────────────────

class _NewDiagnosticFAB extends StatefulWidget {
  const _NewDiagnosticFAB({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_NewDiagnosticFAB> createState() => _NewDiagnosticFABState();
}

class _NewDiagnosticFABState extends State<_NewDiagnosticFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: widget.onPressed,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
            elevation: 12,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo diagnóstico'),
          ),
        );
      },
    );
  }
}
