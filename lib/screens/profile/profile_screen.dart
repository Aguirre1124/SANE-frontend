import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/responsive_layout.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No hay sesión activa.'));
          }
          return ResponsiveCenter(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person,
                        size: 44, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(user.name,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(user.email,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    user.role == 'entrepreneur' ? 'Emprendedor' : user.role,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.info),
                  ),
                ),
                const SizedBox(height: 32),
                _InfoTile(
                    label: 'Estado',
                    value: user.status == 'active' ? 'Activo' : user.status),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _editProfile(context, ref, user.name),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Eliminar cuenta'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editProfile(
      BuildContext context, WidgetRef ref, String currentName) async {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  hintText: '+573001234567'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await ref.read(authProvider.notifier).updateProfile(
              nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
              phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado')));
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.message), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar cuenta'),
        content: const Text(
            '¿Estás seguro? Esta acción es irreversible. Tu cuenta quedará anonimizada.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authProvider.notifier).deleteAccount();
        if (context.mounted) context.go('/login');
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.message), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  )),
        ],
      ),
    );
  }
}
