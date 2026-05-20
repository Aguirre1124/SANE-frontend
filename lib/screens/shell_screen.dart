import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../widgets/responsive_layout.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
    (icon: Icons.route_outlined, activeIcon: Icons.route, label: 'Rutas'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);

    if (wide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _SideNav(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
            ),
            Container(width: 1, color: AppColors.border),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          items: _destinations
              .map((d) => BottomNavigationBarItem(
                    icon: Icon(d.icon),
                    activeIcon: Icon(d.activeIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified_user,
                      color: Colors.white, size: 20),
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
              activeIcon: _destinations[i].activeIcon,
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
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
