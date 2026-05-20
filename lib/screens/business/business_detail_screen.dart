import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/business_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({super.key, required this.businessId});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailProvider(businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Negocio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/app/business/$businessId/edit'),
            tooltip: 'Editar',
          ),
        ],
      ),
      body: businessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(businessDetailProvider(businessId)),
        ),
        data: (business) => ResponsiveCenter(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.store,
                                color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              business.tradeName,
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      if (business.targetEntity != null) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.account_balance_outlined,
                          label: 'Entidad',
                          value: business.targetEntity!,
                        ),
                      ],
                      if (business.riskLevel != null ||
                          business.tramiteType != null) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (business.riskLevel != null)
                              StatusChip(
                                  value: business.riskLevel!,
                                  type: ChipType.riskLevel),
                            if (business.tramiteType != null)
                              StatusChip(
                                  value: business.tramiteType!,
                                  type: ChipType.tramiteType),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Acciones',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.assignment_outlined,
                title: 'Diagnóstico sanitario',
                subtitle: 'Evalúa el nivel de riesgo de tu negocio',
                color: AppColors.info,
                onTap: () =>
                    context.push('/app/business/$businessId/diagnostics'),
              ),
              _ActionCard(
                icon: Icons.chat_bubble_outline,
                title: 'Asistente IA',
                subtitle: 'Resuelve dudas sobre normativas sanitarias',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

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
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted)),
        Expanded(
          child: Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  )),
        ),
      ],
    );
  }
}

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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
