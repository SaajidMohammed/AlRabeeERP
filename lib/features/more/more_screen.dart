import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/erp_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/command_palette_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final erp = context.watch<ErpProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Modules',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Al Rabee Enterprise Suite & Admin Tools',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => context.push('/notifications'),
                        icon: Badge(
                          isLabelVisible: erp.unreadNotificationCount > 0,
                          label: Text('${erp.unreadNotificationCount}'),
                          child: const Icon(Icons.notifications_outlined, size: 20),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cardHoverLight,
                          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User Profile Card
                  AlRabeeCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Saajid Mohammed',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'admin@alrabee.com',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusBadge.success(user?.role.label ?? 'Super Admin'),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Flagship Hub',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Settings Card (Theme toggle + Command Palette)
                  Row(
                    children: [
                      Expanded(
                        child: AlRabeeCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          onTap: () {
                            theme.toggleTheme();
                            ToastService.showInfo(
                              isDark ? 'Switched to Light Theme' : 'Switched to Dark Theme',
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.pastelAmber.withValues(alpha: 0.15) : AppColors.pastelAmber,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  size: 18,
                                  color: AppColors.pastelAmberIcon,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isDark ? 'Light Mode' : 'Dark Mode',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    Text(
                                      'Toggle UI theme',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AlRabeeCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          onTap: () => context.read<CommandPaletteProvider>().open(),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.pastelLavender.withValues(alpha: 0.15) : AppColors.pastelLavender,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                  color: AppColors.pastelLavenderIcon,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quick Search',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    Text(
                                      'Commands & tools',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Modules Section List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Commercial & Supply Chain
                _buildSectionTitle('Commercial & Operations', isDark),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.people_alt_rounded,
                  iconColor: AppColors.pastelSkyIcon,
                  bgColor: AppColors.pastelSky,
                  title: 'Customers & VIP Directory',
                  subtitle: '${erp.customers.length} registered clients, balances & tiers',
                  route: '/customers',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.local_shipping_rounded,
                  iconColor: AppColors.pastelCyanIcon,
                  bgColor: AppColors.pastelCyan,
                  title: 'Purchases & Imports',
                  subtitle: '${erp.purchaseOrders.length} POs, customs bills & cold containers',
                  route: '/purchases',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.point_of_sale_rounded,
                  iconColor: AppColors.pastelMintIcon,
                  bgColor: AppColors.pastelMint,
                  title: 'POS / New Counter Sale',
                  subtitle: 'Quick retail billing, barcode scan & receipts',
                  route: '/sales/new',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.view_kanban_rounded,
                  iconColor: AppColors.pastelLavenderIcon,
                  bgColor: AppColors.pastelLavender,
                  title: 'CRM & Deals Pipeline',
                  subtitle: 'Corporate gifting leads & deal pipeline',
                  route: '/crm',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.card_giftcard_rounded,
                  iconColor: AppColors.pastelFuchsiaIcon,
                  bgColor: AppColors.pastelFuchsia,
                  title: 'Corporate Projects',
                  subtitle: 'Custom gourmet hampers & bespoke contracts',
                  route: '/projects',
                ),

                const SizedBox(height: 20),

                // 2. Finance & Analytics
                _buildSectionTitle('Finance & Accounts', isDark),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.pastelMintIcon,
                  bgColor: AppColors.pastelMint,
                  title: 'Accounting & Ledger',
                  subtitle: 'General ledger, P&L, expenses & tax GST',
                  route: '/accounting',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.pastelLavenderIcon,
                  bgColor: AppColors.pastelLavender,
                  title: 'Invoices & Billing',
                  subtitle: '${erp.invoices.length} invoices issued & payment tracking',
                  route: '/invoices',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.analytics_rounded,
                  iconColor: AppColors.pastelSkyIcon,
                  bgColor: AppColors.pastelSky,
                  title: 'Executive Reports & Analytics',
                  subtitle: 'Sales velocity, margin analysis & tax audit',
                  route: '/reports',
                ),

                const SizedBox(height: 20),

                // 3. People & Administration
                _buildSectionTitle('Staff & Administration', isDark),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.badge_rounded,
                  iconColor: AppColors.pastelAmberIcon,
                  bgColor: AppColors.pastelAmber,
                  title: 'HR & Employee Payroll',
                  subtitle: 'Staff directory, attendance & payroll slips',
                  route: '/hr',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.admin_panel_settings_rounded,
                  iconColor: AppColors.pastelRoseIcon,
                  bgColor: AppColors.pastelRose,
                  title: 'Administration & Roles',
                  subtitle: 'User access control, permissions & audit log',
                  route: '/administration',
                ),
                _buildModuleTile(
                  context,
                  isDark: isDark,
                  icon: Icons.settings_suggest_rounded,
                  iconColor: AppColors.pastelTealIcon,
                  bgColor: AppColors.pastelTeal,
                  title: 'System Settings & Tax',
                  subtitle: 'Tax rates, currency, units & branch configs',
                  route: '/settings',
                ),

                const SizedBox(height: 24),

                // Logout Button
                AlRabeeCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () => _confirmLogout(context, auth),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              'End active session on this device',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Al Rabee ERP v2.4.0 • Enterprise Edition',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AlRabeeCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => context.go(route),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? bgColor.withValues(alpha: 0.18) : bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? AppColors.textMutedDark : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await AlRabeeDialog.confirm(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of Al Rabee ERP?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      auth.logout();
      context.go('/login');
      ToastService.showInfo('Signed out successfully');
    }
  }
}
