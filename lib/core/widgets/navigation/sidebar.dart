import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../../models/user_model.dart';
import '../../../models/lead_model.dart';
import '../../../models/purchase_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/erp_provider.dart';

class Sidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;
    final auth = context.watch<AuthProvider>();
    final erp = context.watch<ErpProvider>();

    return AnimatedContainer(
      duration: AppTokens.durationNormal,
      width: widget.isCollapsed
          ? AppTokens.sidebarWidthCollapsed
          : AppTokens.sidebarWidthExpanded,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sidebarBgDark : AppColors.sidebarBgLight,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Brand Header
          _buildBrandHeader(isDark),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

          // User Persona Switcher Pill
          if (!widget.isCollapsed) _buildRoleSwitcherBadge(context, auth, isDark),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: '/dashboard',
                  currentPath: currentPath,
                ),
                const SizedBox(height: 14),
                _buildGroupHeader('COMMERCE & CRM'),
                _buildNavItem(
                  context,
                  icon: Icons.view_kanban_rounded,
                  title: 'CRM & Leads',
                  route: '/crm',
                  currentPath: currentPath,
                  badge: erp.leads.any((l) => l.stage == LeadStage.newLead)
                      ? '${erp.leads.where((l) => l.stage == LeadStage.newLead).length}'
                      : null,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: 'Customers',
                  route: '/customers',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  title: 'Sales & Invoices',
                  route: '/sales',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.local_shipping_rounded,
                  title: 'Purchases & POs',
                  route: '/purchases',
                  currentPath: currentPath,
                  badge: erp.purchaseOrders.any((p) => p.status == PurchaseStatus.ordered)
                      ? '${erp.purchaseOrders.where((p) => p.status == PurchaseStatus.ordered).length}'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildGroupHeader('CATALOG & STOCK'),
                _buildNavItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Products Master',
                  route: '/products',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.warehouse_rounded,
                  title: 'Inventory & Stock',
                  route: '/inventory',
                  currentPath: currentPath,
                  badge: erp.lowStockProducts.isNotEmpty
                      ? '${erp.lowStockProducts.length}'
                      : null,
                  badgeColor: AppColors.warning,
                ),
                const SizedBox(height: 14),
                _buildGroupHeader('OPERATIONS'),
                _buildNavItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: 'Accounting',
                  route: '/accounting',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.badge_rounded,
                  title: 'HR & Attendance',
                  route: '/hr',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.assignment_rounded,
                  title: 'Projects & Tasks',
                  route: '/projects',
                  currentPath: currentPath,
                ),
                const SizedBox(height: 14),
                _buildGroupHeader('ENTERPRISE'),
                _buildNavItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Reports Center',
                  route: '/reports',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Administration',
                  route: '/administration',
                  currentPath: currentPath,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  route: '/settings',
                  currentPath: currentPath,
                ),
              ],
            ),
          ),

          // Bottom Collapse Action
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: InkWell(
              onTap: widget.onToggleCollapse,
              borderRadius: AppTokens.borderRadiusMd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: widget.isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!widget.isCollapsed)
                      Text(
                        'Collapse Menu',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    Icon(
                      widget.isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                      size: 20,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark) {
    return Container(
      height: AppTokens.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment:
            widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.pistachio],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppTokens.borderRadiusMd,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'الربيع',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AL RABEE',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.saffronGoldLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ERP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Premium Delicacies',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleSwitcherBadge(BuildContext context, AuthProvider auth, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: InkWell(
        onTap: () => _showRoleSwitchDialog(context, auth),
        borderRadius: AppTokens.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
            borderRadius: AppTokens.borderRadiusMd,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(auth.currentUser?.avatarUrl ?? ''),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUser?.name ?? 'Admin',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      auth.currentRole.label,
                      style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSwitchDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Switch Demo Role Persona'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: UserRole.values.map((role) {
                final isCurrent = auth.currentRole == role;
                return ListTile(
                  leading: Icon(
                    isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isCurrent ? AppColors.primary : null,
                  ),
                  title: Text(role.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(role.description, style: const TextStyle(fontSize: 11)),
                  selected: isCurrent,
                  onTap: () {
                    auth.switchDemoRole(role);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupHeader(String title) {
    if (widget.isCollapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6, top: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textMutedDark
              : AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required String currentPath,
    String? badge,
    Color? badgeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = currentPath == route || (route != '/dashboard' && currentPath.startsWith(route));

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: AppTokens.borderRadiusMd,
          child: AnimatedContainer(
            duration: AppTokens.durationFast,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? AppColors.sidebarActiveDark : AppColors.sidebarActiveLight)
                  : Colors.transparent,
              borderRadius: AppTokens.borderRadiusMd,
              border: Border.all(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
