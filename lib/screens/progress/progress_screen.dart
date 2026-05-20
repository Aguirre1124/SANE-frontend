import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/progress_model.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Progreso de tramitación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(progressProvider(businessId)),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final ae = e as ApiException?;
          if (ae?.statusCode == 404) {
            return EmptyState(
              icon: Icons.track_changes_outlined,
              title: 'Sin ruta activa',
              subtitle:
                  'Realiza un diagnóstico y asigna una ruta para comenzar el seguimiento.',
              action: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/app/business/$businessId/diagnostics'),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Ir a diagnóstico'),
              ),
            );
          }
          return ErrorView(
            error: e,
            onRetry: () => ref.invalidate(progressProvider(businessId)),
          );
        },
        data: (progress) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(progressProvider(businessId)),
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                _ProgressHeader(progress: progress),
                const SizedBox(height: 20),
                if (progress.isCompleted)
                  _CompletedBanner()
                else ...[
                  Text('Pasos pendientes',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (progress.pendingSteps.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay pasos pendientes registrados.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...progress.pendingSteps.map(
                      (step) => _PendingStepCard(
                        step: step,
                        trackerId: progress.trackerId,
                        onComplete: () async {
                          try {
                            await ref
                                .read(progressProvider(businessId).notifier)
                                .completeStep(
                                    progress.trackerId, step.id);
                          } on ApiException catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(e.message),
                                    backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                      ),
                    ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.progress});

  final ProgressModel progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedSteps} / ${progress.totalSteps} pasos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${(progress.overallProgress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.overallProgress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Días transcurridos: ${progress.daysElapsed}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, color: AppColors.success, size: 48),
          const SizedBox(height: 12),
          Text(
            '¡Tramitación completada!',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: 6),
          Text(
            'Has completado todos los pasos del trámite sanitario.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendingStepCard extends StatefulWidget {
  const _PendingStepCard({
    required this.step,
    required this.trackerId,
    required this.onComplete,
  });

  final PendingStep step;
  final String trackerId;
  final Future<void> Function() onComplete;

  @override
  State<_PendingStepCard> createState() => _PendingStepCardState();
}

class _PendingStepCardState extends State<_PendingStepCard> {
  bool _completing = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.step.order}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.step.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            _completing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: () async {
                      setState(() => _completing = true);
                      await widget.onComplete();
                      if (mounted) setState(() => _completing = false);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColors.textMuted,
                    tooltip: 'Marcar como completado',
                  ),
          ],
        ),
      ),
    );
  }
}
