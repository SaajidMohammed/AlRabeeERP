import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation/app_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/crm/crm_screen.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../features/sales/pos_new_sale_screen.dart';
import '../../features/purchases/purchases_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/accounting/accounting_screen.dart';
import '../../features/hr/hr_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/administration/administration_screen.dart';
import '../../features/settings/settings_screen.dart';

import '../../features/invoices/invoices_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/more/more_screen.dart';

CustomTransitionPage<void> _buildCustomTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.explore_off_rounded, size: 56, color: Color(0xFF6366F1)),
          const SizedBox(height: 16),
          const Text(
            'Page Not Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/invoices',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const InvoicesScreen(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const MoreScreen(),
          ),
        ),
        GoRoute(
          path: '/crm',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const CrmScreen(),
          ),
        ),
        GoRoute(
          path: '/customers',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const CustomersScreen(),
          ),
        ),
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const ProductsScreen(),
          ),
        ),
        GoRoute(
          path: '/sales',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const SalesScreen(),
          ),
        ),
        GoRoute(
          path: '/sales/new',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const PosNewSaleScreen(),
          ),
        ),
        GoRoute(
          path: '/purchases',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const PurchasesScreen(),
          ),
        ),
        GoRoute(
          path: '/inventory',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const InventoryScreen(),
          ),
        ),
        GoRoute(
          path: '/accounting',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const AccountingScreen(),
          ),
        ),
        GoRoute(
          path: '/hr',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const HrScreen(),
          ),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const ProjectsScreen(),
          ),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const ReportsScreen(),
          ),
        ),
        GoRoute(
          path: '/administration',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const AdministrationScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildCustomTransition(
            context,
            state,
            const SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);

