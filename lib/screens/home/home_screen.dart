import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _GlowFab(
        onPressed: () => context.push('/app/business/create'),
      ),
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                onRefresh: () =>
                    ref.read(businessListProvider.notifier).refresh(),
              ),
              Expanded(
                child: businessesAsync.when(
                  loading: () => const _ShimmerList(),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () =>
                        ref.read(businessListProvider.notifier).refresh(),
                  ),
                  data: (businesses) {
                    if (businesses.isEmpty) {
                      return EmptyState(
                        icon: Icons.store_outlined,
                        title: 'Aún no tienes negocios',
                        subtitle:
                            'Crea tu primer negocio para iniciar el proceso de registro sanitario.',
                        action: ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/app/business/create'),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear negocio'),
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: () =>
                          ref.read(businessListProvider.notifier).refresh(),
                      child: ResponsiveCenter(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.xxxl,
                        ),
                        child: ListView.builder(
                          itemCount: businesses.length,
                          itemBuilder: (_, i) =>
                              _BusinessCardItem(business: businesses[i]),
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
    );
  }
}

// ── Header glassmorphism ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;

  const _Header({required this.onRefresh});

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
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Mis Negocios', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Gestiona tus establecimientos',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
              // Logo de marca discreto
              Image.asset(
                'assets/images/sane_logo_mark.png',
                width: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.refresh_outlined, size: 22),
                onPressed: onRefresh,
                tooltip: 'Actualizar',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB con glow ─────────────────────────────────────────────────────────────

class _GlowFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _GlowFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo negocio'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, i) => const _BusinessCardSkeleton(),
      ),
    );
  }
}

class _BusinessCardSkeleton extends StatelessWidget {
  const _BusinessCardSkeleton();

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerLoader(
                  width: 48,
                  height: 48,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLoader(height: 16),
                      const SizedBox(height: 8),
                      const ShimmerLoader(height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                ShimmerLoader(
                  width: 88,
                  height: 26,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(width: AppSpacing.md),
                ShimmerLoader(
                  width: 110,
                  height: 26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Business card item ────────────────────────────────────────────────────────

class _BusinessCardItem extends StatefulWidget {
  const _BusinessCardItem({required this.business});

  final BusinessModel business;

  @override
  State<_BusinessCardItem> createState() => _BusinessCardItemState();
}

class _BusinessCardItemState extends State<_BusinessCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: PremiumCard(
            onTap: () =>
                context.push('/app/business/${widget.business.id}'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundGradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.surfaceAlt],
            ),
            border: Border.all(
              color: AppColors.primary,
              width: 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícono de tienda
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: AppColors.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // Nombre + entidad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.business.tradeName,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.business.targetEntity != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_outlined,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.business.targetEntity!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                // Chips de riesgo y permiso
                if (widget.business.riskLevel != null ||
                    widget.business.tramiteType != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (widget.business.riskLevel != null)
                        StatusChip(
                          value: widget.business.riskLevel!,
                          type: ChipType.riskLevel,
                        ),
                      if (widget.business.tramiteType != null)
                        StatusChip(
                          value: widget.business.tramiteType!,
                          type: ChipType.tramiteType,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
