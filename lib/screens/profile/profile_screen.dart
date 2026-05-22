import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_orbs_background.dart';
import '../../widgets/error_view.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/shimmer_loader.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts[0].isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

String _formatRole(String role) =>
    role == 'entrepreneur' ? 'Emprendedor' : role;

// ── Pantalla ──────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOrbsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _GlassHeader(),
              Expanded(
                child: authAsync.when(
                  loading: () => const _ProfileSkeleton(),
                  error: (e, _) => ErrorView(
                    error: e,
                    onRetry: () => ref.invalidate(authProvider),
                  ),
                  data: (user) {
                    if (user == null) {
                      return const Center(
                        child: Text(
                          'No hay sesión activa.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ResponsiveCenter(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xxxl,
                      ),
                      child: ListView(
                        children: [
                          // ── Tarjeta de usuario ──────────────────────────
                          _UserCard(user: user),
                          const SizedBox(height: AppSpacing.xl),
                          // ── Opciones de cuenta ──────────────────────────
                          PremiumCard(
                            padding: EdgeInsets.zero,
                            backgroundGradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surface,
                                AppColors.surfaceAlt,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.borderLight,
                              width: 1,
                            ),
                            enableGlow: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _OptionRow(
                                  icon: Icons.verified_user_outlined,
                                  iconColor: AppColors.info,
                                  label: 'Estado',
                                  trailing:
                                      _StatusBadge(status: user.status),
                                  isFirst: true,
                                ),
                                const Divider(
                                  height: 1,
                                  color: AppColors.divider,
                                  indent: AppSpacing.lg +
                                      36 +
                                      AppSpacing.md,
                                ),
                                _OptionRow(
                                  icon: Icons.edit_outlined,
                                  iconColor: AppColors.primary,
                                  label: 'Editar perfil',
                                  onTap: () =>
                                      _editProfile(context, ref, user.name),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // ── Cerrar sesión ───────────────────────────────
                          _LogoutButton(
                            onPressed: () =>
                                ref.read(authProvider.notifier).logout(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // ── Eliminar cuenta ─────────────────────────────
                          _DangerButton(
                            onPressed: () => _confirmDelete(context, ref),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
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
                hintText: '+573001234567',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
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
            const SnackBar(content: Text('Perfil actualizado')),
          );
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: AppColors.error,
            ),
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
          '¿Estás seguro? Esta acción es irreversible. Tu cuenta quedará anonimizada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
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
              content: Text(e.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

// ── Header glass (pantalla raíz — sin botón de volver) ────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader();

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
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Perfil',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tu información de cuenta',
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

// ── Tarjeta de usuario ────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.surface, AppColors.surfaceAlt],
      ),
      border: Border.all(color: AppColors.primary, width: 1),
      child: Column(
        children: [
          // Avatar con gradiente e iniciales
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(user.name),
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Chip de rol
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              _formatRole(user.role),
              style: const TextStyle(
                color: AppColors.info,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de opción dentro de una card ─────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.iconColor = AppColors.textSecondary,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst
            ? const Radius.circular(AppSpacing.radiusLarge)
            : Radius.zero,
        bottom: isLast
            ? const Radius.circular(AppSpacing.radiusLarge)
            : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textPrimary),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── Badge de estado ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'active';
    final color = isActive ? AppColors.success : AppColors.warning;
    final label = isActive ? 'Activo' : status;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón cerrar sesión ───────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Cerrar sesión'),
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

// ── Botón eliminar cuenta (zona peligrosa) ────────────────────────────────────

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_forever_outlined),
        label: const Text('Eliminar cuenta'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
      ),
    );
  }
}

// ── Skeleton de carga ─────────────────────────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de usuario
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                ShimmerLoader(
                  width: 80,
                  height: 80,
                  borderRadius: BorderRadius.circular(40),
                ),
                const SizedBox(height: AppSpacing.lg),
                const ShimmerLoader(height: 22),
                const SizedBox(height: AppSpacing.sm),
                const ShimmerLoader(height: 16),
                const SizedBox(height: AppSpacing.md),
                ShimmerLoader(
                  width: 90,
                  height: 24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Tarjeta de opciones
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: List.generate(2, (i) {
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(height: 1, color: AppColors.divider),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          ShimmerLoader(
                            width: 36,
                            height: 36,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(child: ShimmerLoader(height: 16)),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ShimmerLoader(
            height: AppSpacing.buttonHeight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          const SizedBox(height: AppSpacing.md),
          ShimmerLoader(
            height: AppSpacing.buttonHeight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ],
      ),
    );
  }
}
