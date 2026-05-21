import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/animated_bottom_nav.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_outlined, label: 'Inicio'),
    (icon: Icons.route_outlined, label: 'Rutas'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);

    if (wide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _SideNav(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onTap,
            ),
            Container(width: 1, color: AppColors.border),
            Expanded(child: widget.navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.navigationShell,
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
        items: ShellScreen._destinations
            .map((d) => BottomNavItem(icon: d.icon, label: d.label))
            .toList(),
      ),
    );
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  static const _destinations = ShellScreen._destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_user,
                      color: AppColors.onPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Text('SANE',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        )),
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < _destinations.length; i++)
            _NavItem(
              icon: _destinations[i].icon,
              label: _destinations[i].label,
              isActive: currentIndex == i,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: isActive
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
