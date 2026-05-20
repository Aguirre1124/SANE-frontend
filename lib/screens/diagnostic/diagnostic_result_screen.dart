import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/error_view.dart';
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
        appBar: AppBar(title: const Text('Resultado')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Resultado')),
        body: ErrorView(
          error: e,
          onRetry: () => ref.invalidate(diagnosticResultProvider(sessionId)),
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
      appBar: AppBar(title: const Text('Resultado del diagnóstico')),
      body: ResponsiveCenter(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _ResultHeader(result: result),
            const SizedBox(height: 20),
            _SummaryCard(result: result),
            const SizedBox(height: 20),
            _ChecklistCard(checklist: result.checklist),
            const SizedBox(height: 20),
            _NormativasCard(normativas: result.normativasApplied),
            const SizedBox(height: 24),
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
                label: const Text('Explorar rutas disponibles'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result});

  final DiagnosticResult result;

  Color _riskColor() => switch (result.riskLevel) {
        'high' => AppColors.error,
        'medium' => AppColors.warning,
        'low' => AppColors.success,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _riskColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor().withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: _riskColor(), size: 48),
          const SizedBox(height: 12),
          Text(
            'Diagnóstico completado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusChip(value: result.riskLevel, type: ChipType.riskLevel),
              const SizedBox(width: 8),
              StatusChip(value: result.tramiteType, type: ChipType.tramiteType),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(result.targetEntity,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Confianza: ${(result.confidenceScore * 100).toInt()}%',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(result.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    )),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documentos requeridos',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...checklist.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Normativas aplicadas',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: normativas
                  .map((n) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.4)),
                        ),
                        child: Text(n,
                            style: const TextStyle(
                                color: AppColors.info, fontSize: 12)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
