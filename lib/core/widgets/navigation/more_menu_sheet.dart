import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/design_system/design_system.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

class MoreMenuSheet extends StatelessWidget {
  const MoreMenuSheet({super.key});

  static void show(BuildContext context) {
    AlRabeeBottomSheet.show(
      context: context,
      title: 'More Modules',
      subtitle: 'Al Rabee Enterprise Management Suite',
      child: const MoreMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = context.watch<ThemeProvider>();
    final auth = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Business Section
        _buildSectionHeader('Commercial & Supply Chain', isDark),
        _buildMenuItem(
          context,
          icon: Icons.people_alt_rounded,
          iconColor: AppColors.pastelSkyIcon,
          bgColor: AppColors.pastelSky,
          title: 'Customers & VIPs',
          subtitle: 'Directory, purchase history & loyalty balance',
          route: '/customers',
        ),
        _buildMenuItem(
          context,
          icon: Icons.local_shipping_rounded,
          iconColor: AppColors.pastelCyanIcon,
          bgColor: AppColors.pastelCyan,
          title: 'Purchases & Imports',
          subtitle: 'PO workflows, air cargo & customs bills',
          route: '/purchases',
        ),
        _buildMenuItem(
          context,
          icon: Icons.view_kanban_rounded,
          iconColor: AppColors.pastelLavenderIcon,
          bgColor: AppColors.pastelLavender,
          title: 'CRM & Deals Pipeline',
          subtitle: 'Corporate gifting, leads & quotations',
          route: '/crm',
        ),
        _buildMenuItem(
          context,
          icon: Icons.card_giftcard_rounded,
          iconColor: AppColors.pastelFuchsiaIcon,
          bgColor: AppColors.pastelFuchsia,
          title: 'Corporate Projects',
          subtitle: 'Custom gourmet hampers & catering contracts',
          route: '/projects',
        ),

        const SizedBox(height: 16),

        // Finance Section
        _buildSectionHeader('Finance & Accounts', isDark),
        _buildMenuItem(
          context,
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.pastelMintIcon,
          bgColor: AppColors.pastelMint,
          title: 'Accounting & Ledger',
          subtitle: 'General ledger, P&L, expenses & tax GST',
          route: '/accounting',
        ),

        const SizedBox(height: 16),

        // People Section
        _buildSectionHeader('Human Resources & Payroll', isDark),
        _buildMenuItem(
          context,
          icon: Icons.badge_rounded,
          iconColor: AppColors.pastelAmberIcon,
          bgColor: AppColors.pastelAmber,
          title: 'Employees & Attendance',
          subtitle: 'Staff payroll, leave requests & attendance',
          route: '/hr',
        ),

        const SizedBox(height: 16),

        // Administration Section
        _buildSectionHeader('Administration & Settings', isDark),
        _buildMenuItem(
          context,
          icon: Icons.notifications_none_rounded,
          iconColor: AppColors.pastelLavenderIcon,
          bgColor: AppColors.pastelLavender,
          title: 'Notifications Center',
          subtitle: 'System alerts, low stock & payment notices',
          route: '/notifications',
        ),
        _buildMenuItem(
          context,
          icon: Icons.admin_panel_settings_rounded,
          iconColor: AppColors.pastelSkyIcon,
          bgColor: AppColors.pastelSky,
          title: 'Security & Audit Logs',
          subtitle: 'Role permissions & immutable activity audit',
          route: '/administration',
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings_suggest_rounded,
          iconColor: AppColors.pastelTealIcon,
          bgColor: AppColors.pastelTeal,
          title: 'System Settings',
          subtitle: 'Tax rates, branch configs & printing setup',
          route: '/settings',
        ),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 10),

        // Quick Controls (Dark Mode & Logout)
        Row(
          children: [
            Expanded(
              child: AlRabeeButton.outlined(
                label: theme.isDark ? 'Light Theme' : 'Dark Theme',
                icon: theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                onPressed: () => theme.toggleTheme(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AlRabeeButton.danger(
                label: 'Logout',
                icon: Icons.logout_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  auth.logout();
                  context.go('/login');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop();
            context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? iconColor.withValues(alpha: 0.18) : bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
