import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class DiagnosticResultScreen extends ConsumerWidget {
  const DiagnosticResultScreen({
    super.key,
    required this.sessionId,
    this.preloadedResult,
  });

  final String sessionId;
  final DiagnosticResult? preloadedResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (preloadedResult != null) {
      return _ResultBody(result: preloadedResult!, sessionId: sessionId);
    }

    final resultAsync = ref.watch(diagnosticResultProvider(sessionId));
    return resultAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedOrbsBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LoadingHeader(),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedOrbsBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LoadingHeader(),
                Expanded(
                  child: ErrorView(
                    error: e,
                    onRetry: () =>
                        ref.invalidate(diagnosticResultProvider(sessionId)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (result) =>
          _ResultBody(result: result, sessionId: sessionId),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.result, required this.sessionId});

  final DiagnosticResult result;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResultHeaderWidget(result: result),
              Expanded(
                child: ResponsiveCenter(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  child: ListView(
                    children: [
                      _ResultHeroCard(result: result),
                      const SizedBox(height: AppSpacing.xxl),
                      _SummaryCard(result: result),
                      const SizedBox(height: AppSpacing.xl),
                      _ChecklistCard(checklist: result.checklist),
                      const SizedBox(height: AppSpacing.xl),
                      _NormativasCard(normativas: result.normativasApplied),
                      const SizedBox(height: AppSpacing.xxl),
                      _DownloadPDFButton(),
                      const SizedBox(height: AppSpacing.xl),
                      if (result.assignedRouteId != null)
                        ElevatedButton.icon(
                          onPressed: () => context
                              .push('/app/routes/${result.assignedRouteId}'),
                          icon: const Icon(Icons.route),
                          label: const Text('Ver ruta de tramitación'),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () => context.push('/app/routes'),
                          icon: const Icon(Icons.search),
                          label:
                              const Text('Explorar rutas disponibles'),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
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

// ── Loading Header ────────────────────────────────────────────────────────────

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

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
                onPressed: () => Navigator.pop(context),
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
                    Text('Resultado', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Cargando diagnóstico',
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

// ── Header glassmorphism ──────────────────────────────────────────────────────

class _ResultHeaderWidget extends StatelessWidget {
  const _ResultHeaderWidget({required this.result});

  final DiagnosticResult result;

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
                onPressed: () => Navigator.pop(context),
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
                    Text('Resultado', style: tt.headlineMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Diagnóstico completado',
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

// ── HERO Result Card ──────────────────────────────────────────────────────────

class _ResultHeroCard extends StatelessWidget {
  const _ResultHeroCard({required this.result});

  final DiagnosticResult result;

  Color _riskColor() => switch (result.riskLevel) {
        'high' => AppColors.catRiskHigh,
        'medium' => AppColors.catRiskMedium,
        'low' => AppColors.catRiskLow,
        _ => AppColors.primary,
      };

  String _riskLabel() => switch (result.riskLevel) {
        'high' => 'Alto riesgo',
        'medium' => 'Riesgo medio',
        'low' => 'Bajo riesgo',
        _ => 'Diagnóstico completado',
      };

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor();
    final progress = result.confidenceScore;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: riskColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: riskColor.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              // Check icon with glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: riskColor.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withValues(alpha: 0.4),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle,
                  color: riskColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Risk level
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(
                    color: riskColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _riskLabel(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Trámite type chip
              StatusChip(
                value: result.tramiteType,
                type: ChipType.tramiteType,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Entity with icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_outlined,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    result.targetEntity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Confidence score with visual progress
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confianza',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: riskColor,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.surface.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(riskColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      enableHoverEffect: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            result.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.checklist});

  final List<String> checklist;

  @override
  Widget build(BuildContext context) {
    if (checklist.isEmpty) {
      return const SizedBox.shrink();
    }
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      enableHoverEffect: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documentos requeridos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...checklist.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index != checklist.length - 1 ? AppSpacing.lg : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NormativasCard extends StatelessWidget {
  const _NormativasCard({required this.normativas});

  final List<String> normativas;

  @override
  Widget build(BuildContext context) {
    if (normativas.isEmpty) return const SizedBox.shrink();
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      enableHoverEffect: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Normativas aplicadas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: normativas
                .map((n) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        n,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Download PDF Button with glow ────────────────────────────────────────────

class _DownloadPDFButton extends StatefulWidget {
  const _DownloadPDFButton();

  @override
  State<_DownloadPDFButton> createState() => _DownloadPDFButtonState();
}

class _DownloadPDFButtonState extends State<_DownloadPDFButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.3 * _glowAnimation.value,
                ),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Descarga de PDF disponible próximamente'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              elevation: 8,
            ),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Descargar resultado en PDF'),
          ),
        );
      },
    );
  }
}
