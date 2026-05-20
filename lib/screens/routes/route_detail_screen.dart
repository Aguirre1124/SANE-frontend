import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/route_model.dart';
import '../../providers/route_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  const RouteDetailScreen({
    super.key,
    required this.routeId,
    this.businessId,
  });

  final String routeId;
  final String? businessId;

  @override
  ConsumerState<RouteDetailScreen> createState() =>
      _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> {
  bool _assigning = false;

  Future<void> _assignRoute() async {
    if (widget.businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Selecciona un negocio primero para iniciar esta ruta.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _assigning = true);
    try {
      final tracker = await ref.read(
        assignRouteProvider((
          routeId: widget.routeId,
          businessId: widget.businessId!,
        )).future,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ruta iniciada: ${tracker.routeName}'),
            backgroundColor: AppColors.success,
          ),
        );
        context.push('/app/business/${widget.businessId}/progress');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeDetailProvider(widget.routeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle de ruta')),
      body: routeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(routeDetailProvider(widget.routeId)),
        ),
        data: (route) => ResponsiveCenter(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              _RouteHeader(route: route),
              const SizedBox(height: 20),
              if (route.steps != null && route.steps!.isNotEmpty) ...[
                Text('Pasos del trámite',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...route.steps!
                    .map((step) => _StepCard(step: step)),
              ] else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No hay pasos detallados para esta ruta.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _assigning ? null : _assignRoute,
                icon: _assigning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_assigning
                    ? 'Iniciando...'
                    : 'Iniciar esta ruta'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.route});

  final RouteModel route;

  String _formatCop(double amount) {
    if (amount == 0) return 'Gratuito';
    return '\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(route.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(route.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    )),
            const SizedBox(height: 16),
            StatusChip(value: route.tramiteType, type: ChipType.tramiteType),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.schedule,
                    label: 'Duración estimada',
                    value: '~${route.estimatedDays} días',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.attach_money,
                    label: 'Costo estimado',
                    value: _formatCop(route.estimatedCostCop),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Stat(
              icon: Icons.account_balance_outlined,
              label: 'Entidad',
              value: route.targetEntity,
            ),
            const SizedBox(height: 8),
            _Stat(
              icon: Icons.library_books_outlined,
              label: 'Normativa',
              value: route.normativaRef,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  const _StepCard({required this.step});

  final RouteStep step;

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.order}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title,
                            style: Theme.of(context).textTheme.titleLarge),
                        if (step.isOptional)
                          Text('Opcional',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 8),
                  Text(step.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          )),
                  if (step.entityName != null) ...[
                    const SizedBox(height: 10),
                    _StepDetail(
                        icon: Icons.account_balance_outlined,
                        text: step.entityName!),
                  ],
                  if (step.entityAddress != null)
                    _StepDetail(
                        icon: Icons.location_on_outlined,
                        text: step.entityAddress!),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StepDetail(
                            icon: Icons.schedule,
                            text: '~${step.estimatedDays} días'),
                      ),
                      Expanded(
                        child: _StepDetail(
                          icon: Icons.attach_money,
                          text: step.estimatedCostCop == 0
                              ? 'Gratuito'
                              : '\$${step.estimatedCostCop.toInt()} COP',
                        ),
                      ),
                    ],
                  ),
                  if (step.documents.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Documentos requeridos',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    ...step.documents.map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              doc.isRequired
                                  ? Icons.check_circle_outline
                                  : Icons.radio_button_unchecked,
                              size: 14,
                              color: doc.isRequired
                                  ? AppColors.success
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(doc.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 13)),
                            ),
                            if (!doc.isRequired)
                              const Text('Opcional',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepDetail extends StatelessWidget {
  const _StepDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
