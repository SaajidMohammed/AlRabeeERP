import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/command_palette_provider.dart';
import '../../../providers/erp_provider.dart';

class _ScreenMeta {
  final String title;
  final String category;
  final IconData icon;

  const _ScreenMeta({
    required this.title,
    required this.category,
    required this.icon,
  });
}

_ScreenMeta _resolveScreenMeta(String path) {
  if (path == '/dashboard') {
    return const _ScreenMeta(
      title: 'Dashboard',
      category: 'Overview',
      icon: Icons.dashboard_rounded,
    );
  }
  if (path == '/sales/new') {
    return const _ScreenMeta(
      title: 'POS / New Sale',
      category: 'Counter Billing',
      icon: Icons.point_of_sale_rounded,
    );
  }
  if (path.startsWith('/sales')) {
    return const _ScreenMeta(
      title: 'Sales & Invoices',
      category: 'Commercial',
      icon: Icons.receipt_long_rounded,
    );
  }
  if (path.startsWith('/products')) {
    return const _ScreenMeta(
      title: 'Product Master',
      category: 'Catalog & SKUs',
      icon: Icons.inventory_2_rounded,
    );
  }
  if (path.startsWith('/inventory')) {
    return const _ScreenMeta(
      title: 'Inventory & Stock',
      category: 'Warehousing & Batches',
      icon: Icons.warehouse_rounded,
    );
  }
  if (path.startsWith('/purchases')) {
    return const _ScreenMeta(
      title: 'Purchases & Imports',
      category: 'Procurement & POs',
      icon: Icons.local_shipping_rounded,
    );
  }
  if (path.startsWith('/customers')) {
    return const _ScreenMeta(
      title: 'Customers & VIPs',
      category: 'Client Directory',
      icon: Icons.people_alt_rounded,
    );
  }
  if (path.startsWith('/crm')) {
    return const _ScreenMeta(
      title: 'CRM & Leads',
      category: 'Deal Pipeline',
      icon: Icons.view_kanban_rounded,
    );
  }
  if (path.startsWith('/accounting')) {
    return const _ScreenMeta(
      title: 'Finance & Ledger',
      category: 'Accounting & Expenses',
      icon: Icons.account_balance_wallet_rounded,
    );
  }
  if (path.startsWith('/hr')) {
    return const _ScreenMeta(
      title: 'HR & Payroll',
      category: 'Staff & Attendance',
      icon: Icons.badge_rounded,
    );
  }
  if (path.startsWith('/projects')) {
    return const _ScreenMeta(
      title: 'Corporate Projects',
      category: 'Custom Hampers & Orders',
      icon: Icons.card_giftcard_rounded,
    );
  }
  if (path.startsWith('/reports')) {
    return const _ScreenMeta(
      title: 'Executive Reports',
      category: 'Analytics & Insights',
      icon: Icons.analytics_rounded,
    );
  }
  if (path.startsWith('/administration')) {
    return const _ScreenMeta(
      title: 'Administration',
      category: 'Roles & Audit Security',
      icon: Icons.admin_panel_settings_rounded,
    );
  }
  if (path.startsWith('/settings')) {
    return const _ScreenMeta(
      title: 'System Settings',
      category: 'Configuration & Tax',
      icon: Icons.settings_suggest_rounded,
    );
  }
  return const _ScreenMeta(
    title: 'Al Rabee ERP',
    category: 'Enterprise',
    icon: Icons.storefront_rounded,
  );
}

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenNotifications;

  const Topbar({
    super.key,
    this.onOpenDrawer,
    this.onOpenNotifications,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppTokens.topbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final themeProvider = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();
    final erp = context.watch<ErpProvider>();
    final palette = context.read<CommandPaletteProvider>();

    final currentPath = GoRouterState.of(context).uri.path;
    final screenMeta = _resolveScreenMeta(currentPath);
    final isSubRoute = currentPath == '/sales/new';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppTokens.topbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: isDesktop
              ? _buildDesktopHeader(
                  context,
                  isDark: isDark,
                  screenMeta: screenMeta,
                  erp: erp,
                  auth: auth,
                  themeProvider: themeProvider,
                  palette: palette,
                )
              : _buildMobileHeader(
                  context,
                  isDark: isDark,
                  screenMeta: screenMeta,
                  isSubRoute: isSubRoute,
                  erp: erp,
                  auth: auth,
                  themeProvider: themeProvider,
                  palette: palette,
                ),
        ),
      ),
    );
  }

  /// Mobile Header Layout:
  /// Left: Hamburger or Back Button + Brand Icon
  /// Center: "AL RABEE ERP" App Name + Dynamic Active Screen Name
  /// Right: Search button + Dark mode toggle + Notification bell + Avatar
  Widget _buildMobileHeader(
    BuildContext context, {
    required bool isDark,
    required _ScreenMeta screenMeta,
    required bool isSubRoute,
    required ErpProvider erp,
    required AuthProvider auth,
    required ThemeProvider themeProvider,
    required CommandPaletteProvider palette,
  }) {
    return Row(
      children: [
        // Navigation Leading Button (Back on sub-page, otherwise Drawer menu)
        if (isSubRoute)
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            tooltip: 'Back to Sales',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/sales');
              }
            },
          )
        else
          IconButton(
            icon: const Icon(Icons.menu_rounded, size: 22),
            tooltip: 'Navigation Menu',
            onPressed: onOpenDrawer,
          ),

        const SizedBox(width: 4),

        // Brand Emblem Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),

        const SizedBox(width: 10),

        // App Name + Dynamic Screen Title
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Brand Name & Subtitle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AL RABEE ERP',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      screenMeta.category,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),

              // Active Screen Title with Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    screenMeta.icon,
                    size: 15,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      screenMeta.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Action Buttons
        // 1. Instant Search / Command Palette
        IconButton(
          icon: const Icon(Icons.search_rounded, size: 20),
          tooltip: 'Search & Shortcuts',
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => palette.open(),
        ),

        // 2. Notification Bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 21),
              tooltip: 'Notifications',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: onOpenNotifications,
            ),
            if (erp.unreadNotificationCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    '${erp.unreadNotificationCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // 3. User Avatar Menu
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: _buildUserMenu(context, auth, isDark),
        ),
      ],
    );
  }

  /// Desktop Header Layout:
  /// Left: Brand / Screen Title + Breadcrumbs + Branch Selector
  /// Center: Quick Search Input with Ctrl+K
  /// Right: + POS Sale Button + Theme toggle + Notifications + Profile Avatar
  Widget _buildDesktopHeader(
    BuildContext context, {
    required bool isDark,
    required _ScreenMeta screenMeta,
    required ErpProvider erp,
    required AuthProvider auth,
    required ThemeProvider themeProvider,
    required CommandPaletteProvider palette,
  }) {
    return Row(
      children: [
        // Left: Screen Title & Breadcrumbs
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(screenMeta.icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Al Rabee ERP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    Text(
                      screenMeta.category,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  screenMeta.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(width: 24),

        // Search Bar / Ctrl+K Palette trigger
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: InkWell(
                onTap: () => palette.open(),
                borderRadius: AppTokens.borderRadiusMd,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardHoverLight,
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 18,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search products, customers, invoices...',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          'Ctrl K',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Branch Selector Dropdown
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardHoverLight,
            borderRadius: AppTokens.borderRadiusMd,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: erp.selectedBranch,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              items: const [
                DropdownMenuItem(
                  value: 'Main Flagship Showroom - Mumbai',
                  child: Row(
                    children: [
                      Icon(Icons.store_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Flagship Showroom - Mumbai'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Central Cold Chain Hub - Bhiwandi',
                  child: Row(
                    children: [
                      Icon(Icons.ac_unit_rounded, size: 16, color: AppColors.oceanBlue),
                      SizedBox(width: 6),
                      Text('Cold Storage Hub - Bhiwandi'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Airport Cargo Fast-Fulfillment Hub',
                  child: Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, size: 16, color: AppColors.saffronGold),
                      SizedBox(width: 6),
                      Text('Air Cargo Hub - Terminal 2'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) erp.setBranch(val);
              },
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Quick Action Button (+ New Sale / POS)
        ElevatedButton.icon(
          onPressed: () => context.go('/sales/new'),
          icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
          label: const Text('New Sale / POS'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 36),
          ),
        ),

        const SizedBox(width: 8),

        // Theme Toggle
        IconButton(
          icon: Icon(
            themeProvider.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
          tooltip: themeProvider.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          onPressed: themeProvider.toggleTheme,
        ),

        // Notification Bell
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
              tooltip: 'Notifications',
              onPressed: onOpenNotifications,
            ),
            if (erp.unreadNotificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${erp.unreadNotificationCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 4),

        // User Menu Dropdown
        _buildUserMenu(context, auth, isDark),
      ],
    );
  }

  Widget _buildUserMenu(BuildContext context, AuthProvider auth, bool isDark) {
    return PopupMenuButton<String>(
      tooltip: 'User Profile & Settings',
      offset: const Offset(0, 44),
      child: CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(auth.currentUser?.avatarUrl ?? ''),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auth.currentUser?.name ?? 'Admin',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                auth.currentUser?.email ?? 'admin@alrabee.com',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  auth.currentRole.label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'settings',
          child: const Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 10),
              Text('ERP Settings', style: TextStyle(fontSize: 13)),
            ],
          ),
          onTap: () => context.go('/settings'),
        ),
        PopupMenuItem(
          value: 'audit',
          child: const Row(
            children: [
              Icon(Icons.history_rounded, size: 18),
              SizedBox(width: 10),
              Text('Audit Logs', style: TextStyle(fontSize: 13)),
            ],
          ),
          onTap: () => context.go('/administration'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text('Logout Session', style: TextStyle(fontSize: 13, color: AppColors.error)),
            ],
          ),
          onTap: () {
            auth.logout();
            context.go('/login');
          },
        ),
      ],
    );
  }
}
