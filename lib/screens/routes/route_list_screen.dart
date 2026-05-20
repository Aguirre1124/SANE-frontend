import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/route_model.dart';
import '../../providers/route_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class RouteListScreen extends ConsumerWidget {
  const RouteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routeListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Catálogo de Rutas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(routeListProvider),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: routesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(routeListProvider),
        ),
        data: (routes) {
          if (routes.isEmpty) {
            return const EmptyState(
              icon: Icons.route_outlined,
              title: 'Sin rutas disponibles',
              subtitle:
                  'No hay rutas sanitarias registradas en este momento.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(routeListProvider),
            child: ResponsiveCenter(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (_, i) => _RouteCard(route: routes[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route});

  final RouteModel route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/app/routes/${route.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.route,
                        color: AppColors.info, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(route.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  StatusChip(
                      value: route.tramiteType,
                      type: ChipType.tramiteType),
                  _InfoChip(
                    icon: Icons.schedule,
                    label: '~${route.estimatedDays} días',
                  ),
                  _InfoChip(
                    icon: Icons.attach_money,
                    label: _formatCop(route.estimatedCostCop),
                  ),
                  if (route.totalSteps != null)
                    _InfoChip(
                      icon: Icons.list_alt,
                      label: '${route.totalSteps} pasos',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.account_balance_outlined,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(route.targetEntity,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCop(double amount) {
    if (amount == 0) return 'Gratuito';
    return '\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
