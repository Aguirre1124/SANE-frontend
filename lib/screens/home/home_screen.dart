import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Negocios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(businessListProvider.notifier).refresh(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/business/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo negocio'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.read(businessListProvider.notifier).refresh(),
        ),
        data: (businesses) {
          if (businesses.isEmpty) {
            return EmptyState(
              icon: Icons.store_outlined,
              title: 'No tienes negocios registrados',
              subtitle:
                  'Crea tu primer negocio para iniciar el proceso de registro sanitario.',
              action: ElevatedButton.icon(
                onPressed: () => context.push('/app/business/create'),
                icon: const Icon(Icons.add),
                label: const Text('Crear negocio'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(businessListProvider.notifier).refresh(),
            child: ResponsiveCenter(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (_, i) =>
                    _BusinessCard(business: businesses[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  const _BusinessCard({required this.business});

  final BusinessModel business;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/app/business/${business.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.store,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      business.tradeName,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textMuted),
                ],
              ),
              if (business.targetEntity != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(business.targetEntity!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
              if (business.riskLevel != null ||
                  business.tramiteType != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
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
    );
  }
}
