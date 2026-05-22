import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/business_provider.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/shimmer_loader.dart';

const _productTypes = [
  ('fresh_produce', 'Frutas y verduras frescas'),
  ('animal_origin', 'Productos de origen animal'),
  ('dry_processed', 'Procesados secos'),
  ('ready_to_eat', 'Listos para consumir'),
  ('beverages', 'Bebidas'),
];

const _operationPlaces = [
  ('home_kitchen', 'Cocina en casa'),
  ('commercial_premises', 'Local comercial'),
  ('mobile_stand', 'Puesto móvil'),
  ('production_plant', 'Planta de producción'),
];

const _salesScopes = [
  ('local_neighbors', 'Venta local / vecinos'),
  ('supermarkets_national', 'Supermercados / distribución nacional'),
  ('export', 'Exportación'),
  ('wholesale', 'Mayorista'),
];

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key, required this.businessId});

  final String businessId;

  @override
  ConsumerState<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tradeNameCtrl = TextEditingController();
  final _legalNameCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _employeeCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();
  String? _productType;
  String? _operationPlace;
  String? _salesScope;
  bool _isPackaged = false;
  bool _hasBrand = false;
  bool _hasLabel = false;
  bool _initialized = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tradeNameCtrl.dispose();
    _legalNameCtrl.dispose();
    _nitCtrl.dispose();
    _employeeCtrl.dispose();
    _revenueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final body = <String, dynamic>{};
    if (_tradeNameCtrl.text.trim().isNotEmpty) {
      body['trade_name'] = _tradeNameCtrl.text.trim();
    }
    if (_legalNameCtrl.text.trim().isNotEmpty) {
      body['legal_name'] = _legalNameCtrl.text.trim();
    }
    if (_nitCtrl.text.trim().isNotEmpty) {
      body['nit'] = _nitCtrl.text.trim();
    }
    if (_productType != null) body['product_type'] = _productType;
    if (_operationPlace != null) body['operation_place'] = _operationPlace;
    if (_salesScope != null) body['sales_scope'] = _salesScope;
    body['is_packaged'] = _isPackaged;
    body['has_brand'] = _hasBrand;
    body['has_label'] = _hasLabel;
    if (_employeeCtrl.text.isNotEmpty) {
      body['employee_count'] = int.tryParse(_employeeCtrl.text) ?? 1;
    }
    if (_revenueCtrl.text.isNotEmpty) {
      body['monthly_revenue'] = double.tryParse(_revenueCtrl.text);
    }

    try {
      await ref
          .read(businessListProvider.notifier)
          .updateBusiness(widget.businessId, body);
      if (mounted) {
        ref.invalidate(businessDetailProvider(widget.businessId));
        context.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessDetailProvider(widget.businessId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GlassHeader(businessId: widget.businessId),
              Expanded(
                child: businessAsync.when(
                  loading: () => const _EditSkeleton(),
                  error: (e, _) => ErrorView(error: e),
                  data: (business) {
                    if (!_initialized) {
                      _tradeNameCtrl.text = business.tradeName;
                      _initialized = true;
                    }
                    return Form(
                      key: _formKey,
                      child: ResponsiveCenter(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.xxxl,
                        ),
                        child: ListView(
                          children: [
                            // ── Identificación ──────────────────────────
                            const _SectionLabel('Identificación'),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _tradeNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nombre comercial',
                                prefixIcon: Icon(Icons.store_outlined),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Requerido'
                                      : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _legalNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Razón social (opcional)',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _nitCtrl,
                              decoration: const InputDecoration(
                                labelText: 'NIT (opcional)',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            // ── Clasificación ───────────────────────────
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionLabel('Clasificación'),
                            const SizedBox(height: AppSpacing.md),
                            _DropdownField(
                              label: 'Tipo de producto',
                              value: _productType,
                              items: _productTypes,
                              onChanged: (v) =>
                                  setState(() => _productType = v),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _DropdownField(
                              label: 'Lugar de operación',
                              value: _operationPlace,
                              items: _operationPlaces,
                              onChanged: (v) =>
                                  setState(() => _operationPlace = v),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _DropdownField(
                              label: 'Alcance de ventas',
                              value: _salesScope,
                              items: _salesScopes,
                              onChanged: (v) =>
                                  setState(() => _salesScope = v),
                            ),
                            // ── Características ─────────────────────────
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionLabel('Características'),
                            const SizedBox(height: AppSpacing.md),
                            _SwitchTile(
                              label: '¿El producto va empacado?',
                              value: _isPackaged,
                              onChanged: (v) =>
                                  setState(() => _isPackaged = v),
                            ),
                            _SwitchTile(
                              label: '¿Tiene marca registrada?',
                              value: _hasBrand,
                              onChanged: (v) =>
                                  setState(() => _hasBrand = v),
                            ),
                            _SwitchTile(
                              label: '¿Tiene etiqueta?',
                              value: _hasLabel,
                              onChanged: (v) =>
                                  setState(() => _hasLabel = v),
                            ),
                            // ── Información laboral ─────────────────────
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionLabel('Información laboral'),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _employeeCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Número de empleados',
                                prefixIcon: Icon(Icons.group_outlined),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _revenueCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText:
                                    'Ingresos mensuales (COP, opcional)',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                            ),
                            // ── Botón guardar ───────────────────────────
                            const SizedBox(height: AppSpacing.xxxl),
                            _SaveButton(
                              isSubmitting: _isSubmitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    );
                  },
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
                      'Editar negocio',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actualiza los datos del establecimiento',
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton de carga ─────────────────────────────────────────────────────────

class _EditSkeleton extends StatelessWidget {
  const _EditSkeleton();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de identificación
          ShimmerLoader(
            width: 120,
            height: 14,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerLoader(
                height: AppSpacing.inputHeight,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Sección dropdowns
          ShimmerLoader(
            width: 100,
            height: 14,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerLoader(
                height: AppSpacing.inputHeight,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Sección switches
          ShimmerLoader(
            width: 110,
            height: 14,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ShimmerLoader(
                height: 52,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Etiqueta de sección con acento cian ───────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Dropdown estilizado ───────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<(String, String)> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.surfaceAlt,
      decoration: InputDecoration(labelText: label),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      items: items
          .map(
            (i) => DropdownMenuItem(
              value: i.$1,
              child: Text(
                i.$2,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Switch tile estilizado ────────────────────────────────────────────────────

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.border,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight:
                      value ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Botón guardar con glow ────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSubmitting, required this.onPressed});

  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedElevatedButton(
        onPressed: onPressed,
        isLoading: isSubmitting,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Guardar cambios'),
            if (!isSubmitting) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.check_rounded,
                size: AppSpacing.iconSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
