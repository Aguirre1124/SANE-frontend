import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/business_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/responsive_layout.dart';

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
  ConsumerState<EditBusinessScreen> createState() =>
      _EditBusinessScreenState();
}

class _EditBusinessScreenState
    extends ConsumerState<EditBusinessScreen> {
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
              content: Text(e.message), backgroundColor: AppColors.error),
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
      appBar: AppBar(title: const Text('Editar negocio')),
      body: businessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(error: e),
        data: (business) {
          if (!_initialized) {
            _tradeNameCtrl.text = business.tradeName;
            _initialized = true;
          }
          return Form(
            key: _formKey,
            child: ResponsiveCenter(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  TextFormField(
                    controller: _tradeNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre comercial',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Requerido'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _legalNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Razón social (opcional)',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'NIT (opcional)',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Tipo de producto'),
                  const SizedBox(height: 8),
                  _DropdownField(
                    label: 'Tipo de producto',
                    value: _productType,
                    items: _productTypes,
                    onChanged: (v) => setState(() => _productType = v),
                  ),
                  const SizedBox(height: 14),
                  _DropdownField(
                    label: 'Lugar de operación',
                    value: _operationPlace,
                    items: _operationPlaces,
                    onChanged: (v) => setState(() => _operationPlace = v),
                  ),
                  const SizedBox(height: 14),
                  _DropdownField(
                    label: 'Alcance de ventas',
                    value: _salesScope,
                    items: _salesScopes,
                    onChanged: (v) => setState(() => _salesScope = v),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Características'),
                  _SwitchTile(
                    label: '¿Empacado?',
                    value: _isPackaged,
                    onChanged: (v) => setState(() => _isPackaged = v),
                  ),
                  _SwitchTile(
                    label: '¿Tiene marca?',
                    value: _hasBrand,
                    onChanged: (v) => setState(() => _hasBrand = v),
                  ),
                  _SwitchTile(
                    label: '¿Tiene etiqueta?',
                    value: _hasLabel,
                    onChanged: (v) => setState(() => _hasLabel = v),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel('Información laboral'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _employeeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Empleados',
                      prefixIcon: Icon(Icons.group_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _revenueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ingresos mensuales (COP, opcional)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar cambios'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontSize: 16),
      );
}

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
      dropdownColor: AppColors.surface,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((i) => DropdownMenuItem(value: i.$1, child: Text(i.$2)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

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
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.primary,
    );
  }
}
