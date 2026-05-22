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
import '../../widgets/responsive_layout.dart';

const _productTypes = [
  ('fresh_produce', 'Frutas y verduras frescas'),
  ('animal_origin', 'Productos de origen animal'),
  ('dry_processed', 'Procesados secos (harinas, mermeladas)'),
  ('ready_to_eat', 'Listos para consumir'),
  ('beverages', 'Bebidas'),
];

const _operationPlaces = [
  ('home_kitchen', 'Cocina en casa'),
  ('commercial_premises', 'Local comercial'),
  ('mobile_stand', 'Puesto móvil / carreta'),
  ('production_plant', 'Planta de producción'),
];

const _salesScopes = [
  ('local_neighbors', 'Venta local / vecinos'),
  ('supermarkets_national', 'Supermercados / distribución nacional'),
  ('export', 'Exportación'),
  ('wholesale', 'Mayorista'),
];

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() =>
      _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _formKey = GlobalKey<FormState>();

  // Tab 1
  final _tradeNameCtrl = TextEditingController();
  String? _productType;

  // Tab 2
  String? _operationPlace;
  bool _isPackaged = false;
  bool _hasBrand = false;
  bool _hasLabel = false;
  String? _salesScope;

  // Tab 3
  final _employeeCtrl = TextEditingController(text: '1');

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _tradeNameCtrl.dispose();
    _employeeCtrl.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabs.index < 2) _tabs.animateTo(_tabs.index + 1);
  }

  void _prevTab() {
    if (_tabs.index > 0) _tabs.animateTo(_tabs.index - 1);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productType == null) {
      _showError('Selecciona el tipo de producto');
      _tabs.animateTo(0);
      return;
    }
    if (_operationPlace == null || _salesScope == null) {
      _showError('Completa todos los campos de operación');
      _tabs.animateTo(1);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final business = await ref.read(businessListProvider.notifier).create({
        'trade_name': _tradeNameCtrl.text.trim(),
        'product_type': _productType,
        'operation_place': _operationPlace,
        'is_packaged': _isPackaged,
        'has_brand': _hasBrand,
        'has_label': _hasLabel,
        'sales_scope': _salesScope,
        'employee_count': int.tryParse(_employeeCtrl.text) ?? 1,
      });
      if (mounted) {
        context.pushReplacement('/app/business/${business.id}');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: AnimatedOrbsBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GlassHeader(tabs: _tabs),
                Expanded(
                  child: ResponsiveCenter(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    child: TabBarView(
                      controller: _tabs,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Tab1(
                          tradeNameCtrl: _tradeNameCtrl,
                          productType: _productType,
                          onProductTypeChanged: (v) =>
                              setState(() => _productType = v),
                          onNext: _nextTab,
                        ),
                        _Tab2(
                          operationPlace: _operationPlace,
                          isPackaged: _isPackaged,
                          hasBrand: _hasBrand,
                          hasLabel: _hasLabel,
                          salesScope: _salesScope,
                          onOperationPlaceChanged: (v) =>
                              setState(() => _operationPlace = v),
                          onPackagedChanged: (v) =>
                              setState(() => _isPackaged = v),
                          onBrandChanged: (v) => setState(() => _hasBrand = v),
                          onLabelChanged: (v) => setState(() => _hasLabel = v),
                          onSalesScopeChanged: (v) =>
                              setState(() => _salesScope = v),
                          onNext: _nextTab,
                          onBack: _prevTab,
                        ),
                        _Tab3(
                          employeeCtrl: _employeeCtrl,
                          isSubmitting: _isSubmitting,
                          onBack: _prevTab,
                          onSubmit: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header con glassmorphism + TabBar ─────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.tabs});

  final TabController tabs;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
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
                            'Nuevo negocio',
                            style:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Completa los datos del establecimiento',
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
              TabBar(
                controller: tabs,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Producto'),
                  Tab(text: 'Operación'),
                  Tab(text: 'Empleados'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 1: Producto ───────────────────────────────────────────────────────────

class _Tab1 extends StatelessWidget {
  const _Tab1({
    required this.tradeNameCtrl,
    required this.productType,
    required this.onProductTypeChanged,
    required this.onNext,
  });

  final TextEditingController tradeNameCtrl;
  final String? productType;
  final ValueChanged<String?> onProductTypeChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: tradeNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre comercial *',
            prefixIcon: Icon(Icons.store_outlined),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'El nombre es requerido' : null,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Tipo de producto *',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._productTypes.map((t) => _RadioTile(
              value: t.$1,
              label: t.$2,
              groupValue: productType,
              onChanged: onProductTypeChanged,
            )),
        const SizedBox(height: AppSpacing.xxl),
        _GlowButton(
          onPressed: onNext,
          label: 'Siguiente',
          icon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── Tab 2: Operación ──────────────────────────────────────────────────────────

class _Tab2 extends StatelessWidget {
  const _Tab2({
    required this.operationPlace,
    required this.isPackaged,
    required this.hasBrand,
    required this.hasLabel,
    required this.salesScope,
    required this.onOperationPlaceChanged,
    required this.onPackagedChanged,
    required this.onBrandChanged,
    required this.onLabelChanged,
    required this.onSalesScopeChanged,
    required this.onNext,
    required this.onBack,
  });

  final String? operationPlace;
  final bool isPackaged;
  final bool hasBrand;
  final bool hasLabel;
  final String? salesScope;
  final ValueChanged<String?> onOperationPlaceChanged;
  final ValueChanged<bool> onPackagedChanged;
  final ValueChanged<bool> onBrandChanged;
  final ValueChanged<bool> onLabelChanged;
  final ValueChanged<String?> onSalesScopeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Lugar de operación *',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._operationPlaces.map((p) => _RadioTile(
              value: p.$1,
              label: p.$2,
              groupValue: operationPlace,
              onChanged: onOperationPlaceChanged,
            )),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Características del producto',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        _CheckTile(
          label: '¿El producto va empacado?',
          value: isPackaged,
          onChanged: onPackagedChanged,
        ),
        _CheckTile(
          label: '¿Tiene marca registrada?',
          value: hasBrand,
          onChanged: onBrandChanged,
        ),
        _CheckTile(
          label: '¿Tiene etiqueta?',
          value: hasLabel,
          onChanged: onLabelChanged,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Alcance de ventas *',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        ..._salesScopes.map((s) => _RadioTile(
              value: s.$1,
              label: s.$2,
              groupValue: salesScope,
              onChanged: onSalesScopeChanged,
            )),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(child: _SecondaryButton(onPressed: onBack, label: 'Anterior')),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _GlowButton(
                onPressed: onNext,
                label: 'Siguiente',
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ── Tab 3: Empleados ──────────────────────────────────────────────────────────

class _Tab3 extends StatelessWidget {
  const _Tab3({
    required this.employeeCtrl,
    required this.isSubmitting,
    required this.onBack,
    required this.onSubmit,
  });

  final TextEditingController employeeCtrl;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Información laboral',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextFormField(
          controller: employeeCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de empleados',
            prefixIcon: Icon(Icons.group_outlined),
            hintText: '1',
          ),
          validator: (v) {
            final n = int.tryParse(v ?? '');
            if (n == null || n < 0) return 'Ingresa un número válido';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(onPressed: onBack, label: 'Anterior'),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _GlowButton(
                onPressed: onSubmit,
                label: 'Crear negocio',
                icon: Icons.check_rounded,
                isLoading: isSubmitting,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Botón primario con glow (wrapper de AnimatedElevatedButton) ───────────────

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool isLoading;

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
        isLoading: isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (!isLoading) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(icon, size: AppSpacing.iconSmall),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Botón secundario (Anterior) ───────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded, size: AppSpacing.iconSmall),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
    );
  }
}

// ── Radio tile ────────────────────────────────────────────────────────────────

class _RadioTile extends StatelessWidget {
  const _RadioTile({
    required this.value,
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  final String value;
  final String label;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textMuted,
              size: AppSpacing.iconMedium,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      selected ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Check tile ────────────────────────────────────────────────────────────────

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: value ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? AppColors.success : AppColors.textMuted,
              size: AppSpacing.iconMedium,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
