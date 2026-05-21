import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/premium_card.dart';

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
        foregroundColor: AppColors.onPrimary,
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (_, i) =>
                    _BusinessCardItem(business: businesses[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
      begin: const Offset(0, 0.3),
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
            onTap: () => context.push('/app/business/${widget.business.id}'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            backgroundGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceAlt.withOpacity(0.8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
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
                      child: const Icon(Icons.store,
                          color: AppColors.onPrimary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.lg),
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
                                Icon(Icons.account_balance_outlined,
                                    size: 14, color: AppColors.textMuted),
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
                    const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                  ],
                ),
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
                            type: ChipType.riskLevel),
                      if (widget.business.tramiteType != null)
                        StatusChip(
                            value: widget.business.tramiteType!,
                            type: ChipType.tramiteType),
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
