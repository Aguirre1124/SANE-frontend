import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/business_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/status_chip.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GlassHeader(businessId: businessId),
              Expanded(
                child: businessAsync.when(
                  loading: () => const _DetailSkeleton(),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () =>
                        ref.invalidate(businessDetailProvider(businessId)),
                  ),
                  data: (business) => ResponsiveCenter(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    child: ListView(
                      children: [
                        // ── Tarjeta de información ──────────────────────
                        PremiumCard(
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
                                  Container(
                                    width: AppSpacing.iconXL,
                                    height: AppSpacing.iconXL,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryLight,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMedium,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.store_rounded,
                                      color: AppColors.onPrimary,
                                      size: AppSpacing.iconMedium,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Text(
                                      business.tradeName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                              if (business.targetEntity != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                _DetailRow(
                                  icon: Icons.account_balance_outlined,
                                  label: 'Entidad',
                                  value: business.targetEntity!,
                                ),
                              ],
                              if (business.riskLevel != null ||
                                  business.tramiteType != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    if (business.riskLevel != null)
                                      StatusChip(
                                        value: business.riskLevel!,
                                        type: ChipType.riskLevel,
                                      ),
                                    if (business.tramiteType != null)
                                      StatusChip(
                                        value: business.tramiteType!,
                                        type: ChipType.tramiteType,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Acciones',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ActionCard(
                          icon: Icons.assignment_outlined,
                          title: 'Diagnóstico sanitario',
                          subtitle: 'Evalúa el nivel de riesgo de tu negocio',
                          color: AppColors.info,
                          onTap: () => context
                              .push('/app/business/$businessId/diagnostics'),
                        ),
                        _ActionCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Asistente IA',
                          subtitle:
                              'Resuelve dudas sobre normativas sanitarias',
                          color: AppColors.success,
                          onTap: () =>
                              context.push('/app/business/$businessId/chat'),
                        ),
                        _ActionCard(
                          icon: Icons.track_changes_outlined,
                          title: 'Progreso de tramitación',
                          subtitle: 'Sigue el avance de tus trámites',
                          color: AppColors.warning,
                          onTap: () =>
                              context.push('/app/business/$businessId/progress'),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header con glassmorphism ──────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context) {
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
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
                color: AppColors.textPrimary,
                tooltip: 'Volver',
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detalle del negocio',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gestiona tu establecimiento',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/sane_logo_mark.png',
                width: 34,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push('/app/business/$businessId/edit'),
                tooltip: 'Editar',
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

// ── Skeleton de carga ─────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                      width: AppSpacing.iconXL,
                      height: AppSpacing.iconXL,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoader(height: 20),
                          SizedBox(height: 8),
                          ShimmerLoader(height: 14),
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
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ShimmerLoader(
                      width: 44,
                      height: 44,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoader(height: 16),
                          SizedBox(height: 6),
                          ShimmerLoader(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de detalle ───────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconSmall, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textMuted),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de acción ─────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.lg),
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceAlt],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconMedium),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
