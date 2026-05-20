import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/diagnostic_model.dart';
import '../../providers/diagnostic_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class DiagnosticListScreen extends ConsumerWidget {
  const DiagnosticListScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(diagnosticSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Diagnósticos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewDiagnostic(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo diagnóstico'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
            padding: const EdgeInsets.all(16),
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

    return Card(
      child: InkWell(
        onTap: isCompleted ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
