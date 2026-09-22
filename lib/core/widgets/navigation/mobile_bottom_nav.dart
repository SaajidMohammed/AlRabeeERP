import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

class MobileBottomNav extends StatelessWidget {
  final VoidCallback onOpenMore;

  const MobileBottomNav({super.key, required this.onOpenMore});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    int getSelectedIndex() {
      if (currentPath == '/dashboard') return 0;
      if (currentPath.startsWith('/sales')) return 1;
      if (currentPath.startsWith('/inventory') || currentPath.startsWith('/products')) return 2;
      if (currentPath.startsWith('/crm') || currentPath.startsWith('/customers')) return 3;
      return 4;
    }

    final selectedIndex = getSelectedIndex();

    return Container(
      height: AppTokens.bottomNavHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => context.go('/dashboard'),
          ),
          _buildItem(
            context,
            icon: Icons.receipt_long_rounded,
            label: 'Sales',
            isSelected: selectedIndex == 1,
            onTap: () => context.go('/sales'),
          ),
          _buildItem(
            context,
            icon: Icons.inventory_2_rounded,
            label: 'Inventory',
            isSelected: selectedIndex == 2,
            onTap: () => context.go('/inventory'),
          ),
          _buildItem(
            context,
            icon: Icons.view_kanban_rounded,
            label: 'CRM',
            isSelected: selectedIndex == 3,
            onTap: () => context.go('/crm'),
          ),
          _buildItem(
            context,
            icon: Icons.menu_rounded,
            label: 'More',
            isSelected: selectedIndex == 4,
            onTap: onOpenMore,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
