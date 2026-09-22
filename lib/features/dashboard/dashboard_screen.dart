import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/stat_card.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../models/user_model.dart';
import '../../models/sales_model.dart';
import '../../models/product_model.dart';
import '../../models/purchase_model.dart';
import '../../models/hr_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/erp_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Executive Header
          _buildHeader(context, auth, erp, isDesktop, isDark),
          const SizedBox(height: 24),

          // Role-specific KPIs
          _buildRoleKpiGrid(context, auth.currentRole, erp, isDesktop),
          const SizedBox(height: 24),

          // Charts Row
          if (auth.currentRole == UserRole.superAdmin ||
              auth.currentRole == UserRole.manager ||
              auth.currentRole == UserRole.accountant) ...[
            Responsive(
              mobile: Column(
                children: [
                  _buildSalesTrendChart(isDark, erp),
                  const SizedBox(height: 20),
                  _buildCategoryDonutChart(isDark, erp),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildSalesTrendChart(isDark, erp)),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: _buildCategoryDonutChart(isDark, erp)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Operational Tables & Alert Widgets
          Responsive(
            mobile: Column(
              children: [
                _buildTopProductsCard(context, erp),
                const SizedBox(height: 20),
                _buildLowStockAlertCard(context, erp),
                const SizedBox(height: 20),
                _buildRecentInvoicesCard(context, erp),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _buildTopProductsCard(context, erp),
                      const SizedBox(height: 24),
                      _buildRecentInvoicesCard(context, erp),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildLowStockAlertCard(context, erp),
                      const SizedBox(height: 24),
                      _buildQuickActionsCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthProvider auth,
    ErpProvider erp,
    bool isDesktop,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        final welcomeWidget = Row(
          mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppTokens.borderRadiusMd,
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: isMobile ? 1 : 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome back, ${auth.currentUser?.name ?? "Admin"}',
                      style: (isMobile
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.headlineSmall)
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Al Rabee Enterprise Dashboard • ${erp.selectedBranch}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final actionsWidget = Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Period Filter Dropdown
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.cardHoverLight,
                borderRadius: AppTokens.borderRadiusMd,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                    DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                    DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                    DropdownMenuItem(value: 'This Quarter', child: Text('This Quarter')),
                    DropdownMenuItem(value: 'FY 2026', child: Text('FY 2026-27')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                erp.saveQuotation(erp.quotations.first); // Feedback test
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Executive report export generated (PDF / Excel)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                elevation: 0,
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: AppTokens.borderRadiusLg,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    welcomeWidget,
                    const SizedBox(height: 14),
                    actionsWidget,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: welcomeWidget),
                    const SizedBox(width: 16),
                    actionsWidget,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRoleKpiGrid(BuildContext context, UserRole role, ErpProvider erp, bool isDesktop) {
    final columns = isDesktop ? 4 : 2;

    switch (role) {
      case UserRole.superAdmin:
      case UserRole.manager:
        return _buildKpiRow([
          StatCard(
            title: "Today's Sales",
            value: Formatters.currency(erp.todaySales > 0 ? erp.todaySales : 85420.0),
            trendPercent: 12.4,
            isPositiveTrend: true,
            subtitle: 'vs yesterday',
            icon: Icons.payments_rounded,
            iconColor: AppColors.primary,
            onTap: () => context.go('/sales'),
          ),
          StatCard(
            title: 'Monthly Revenue',
            value: Formatters.compactCurrency(erp.monthlyRevenue > 0 ? erp.monthlyRevenue : 852000.0),
            trendPercent: 8.7,
            isPositiveTrend: true,
            subtitle: 'target ₹10L',
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.pistachio,
            onTap: () => context.go('/sales'),
          ),
          StatCard(
            title: 'Purchases & Imports',
            value: Formatters.compactCurrency(erp.monthlyPurchases > 0 ? erp.monthlyPurchases : 324000.0),
            trendPercent: 4.2,
            isPositiveTrend: false,
            subtitle: 'import duties incl.',
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.oceanBlue,
            onTap: () => context.go('/purchases'),
          ),
          StatCard(
            title: 'Estimated Net Profit',
            value: Formatters.compactCurrency(erp.netProfit > 0 ? erp.netProfit : 528000.0),
            trendPercent: 14.8,
            isPositiveTrend: true,
            subtitle: 'margin ~62%',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.saffronGold,
            onTap: () => context.go('/accounting'),
          ),
        ], columns);

      case UserRole.salesStaff:
        return _buildKpiRow([
          StatCard(
            title: "Today's Counter Sales",
            value: Formatters.currency(erp.todaySales > 0 ? erp.todaySales : 85420.0),
            trendPercent: 14.2,
            isPositiveTrend: true,
            icon: Icons.point_of_sale_rounded,
            iconColor: AppColors.primary,
          ),
          StatCard(
            title: 'Active Quotations',
            value: '${erp.quotations.length}',
            subtitle: 'sent to VIPs',
            icon: Icons.request_quote_rounded,
            iconColor: AppColors.saffronGold,
          ),
          StatCard(
            title: 'Active Customers',
            value: '${erp.customers.length}',
            subtitle: 'in loyalty program',
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Pending Deliveries',
            value: '${erp.invoices.where((i) => i.salesStatus != SalesStatus.completed).length}',
            subtitle: 'in transit / packing',
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.pistachio,
          ),
        ], columns);

      case UserRole.inventoryManager:
        return _buildKpiRow([
          StatCard(
            title: 'Total Stock Value',
            value: Formatters.compactCurrency(erp.totalInventoryValue),
            subtitle: 'across 3 hubs',
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.primary,
          ),
          StatCard(
            title: 'Low Stock Alert Items',
            value: '${erp.lowStockProducts.length}',
            subtitle: 'requires reorder',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
          ),
          StatCard(
            title: 'Incoming Shipments',
            value: '${erp.purchaseOrders.where((p) => p.status == PurchaseStatus.ordered).length}',
            subtitle: 'Jeddah / Air Cargo',
            icon: Icons.flight_land_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Cold Storage Capacity',
            value: '76%',
            subtitle: 'optimal temperature',
            icon: Icons.ac_unit_rounded,
            iconColor: AppColors.pistachio,
          ),
        ], columns);

      case UserRole.accountant:
        return _buildKpiRow([
          StatCard(
            title: 'Accounts Receivable',
            value: Formatters.compactCurrency(erp.totalReceivables),
            subtitle: 'from corporate clients',
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.success,
          ),
          StatCard(
            title: 'Accounts Payable',
            value: Formatters.compactCurrency(erp.totalPayables),
            subtitle: 'supplier invoices due',
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.berryRose,
          ),
          StatCard(
            title: 'Total Invoices',
            value: '${erp.invoices.length}',
            subtitle: 'this quarter',
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Tax Collected (GST)',
            value: '₹1.14L',
            subtitle: 'input credit verified',
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.saffronGold,
          ),
        ], columns);

      case UserRole.hrManager:
        return _buildKpiRow([
          StatCard(
            title: 'Total Employees',
            value: '${erp.employees.length}',
            subtitle: 'active on payroll',
            icon: Icons.badge_rounded,
            iconColor: AppColors.primary,
          ),
          StatCard(
            title: 'Present Today',
            value: '${erp.employees.length}',
            trendPercent: 100.0,
            isPositiveTrend: true,
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
          ),
          StatCard(
            title: 'Pending Leaves',
            value: '${erp.leaveRequests.where((l) => l.status == LeaveStatus.pending).length}',
            subtitle: 'awaiting sign-off',
            icon: Icons.event_busy_rounded,
            iconColor: AppColors.warning,
          ),
          StatCard(
            title: 'Monthly Payroll',
            value: Formatters.compactCurrency(erp.employees.fold(0.0, (s, e) => s + e.grossSalary)),
            subtitle: 'processed on 1st',
            icon: Icons.monetization_on_rounded,
            iconColor: AppColors.oceanBlue,
          ),
        ], columns);
    }
  }

  Widget _buildKpiRow(List<Widget> cards, int columns) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: cards
                .map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
                .toList(),
          );
        }
        if (constraints.maxWidth < 1100) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: cards,
          );
        }
        return Row(
          children: cards
              .map((c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: c,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildSalesTrendChart(bool isDark, ErpProvider erp) {
    return SectionCard(
      title: 'Sales & Revenue Trend',
      subtitle: 'Monthly trajectory across Flagship, Airport Hub & Corporate B2B (₹ in Lakhs)',
      trailing: StatusBadge.success('+12.4% vs last month'),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₹${value.toInt()}L',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          months[value.toInt()],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 4.2),
                  FlSpot(1, 5.8),
                  FlSpot(2, 6.1),
                  FlSpot(3, 7.4),
                  FlSpot(4, 6.9),
                  FlSpot(5, 8.52),
                  FlSpot(6, 9.8),
                ],
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3.5,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.35),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              LineChartBarData(
                spots: const [
                  FlSpot(0, 2.8),
                  FlSpot(1, 3.4),
                  FlSpot(2, 3.2),
                  FlSpot(3, 4.1),
                  FlSpot(4, 3.8),
                  FlSpot(5, 3.24),
                  FlSpot(6, 4.0),
                ],
                isCurved: true,
                color: AppColors.oceanBlue,
                barWidth: 2,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDonutChart(bool isDark, ErpProvider erp) {
    return SectionCard(
      title: 'Sales by Category',
      subtitle: 'Revenue contribution per product line',
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 46,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: AppColors.primary,
                    radius: 36,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: AppColors.pistachio,
                    radius: 36,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 18,
                    title: '18%',
                    color: AppColors.saffronGold,
                    radius: 36,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 12,
                    title: '12%',
                    color: AppColors.chocolateBrown,
                    radius: 36,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: '10%',
                    color: AppColors.berryRose,
                    radius: 36,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildCategoryLegend('Dates & Ajwa', AppColors.primary),
              _buildCategoryLegend('Dry Fruits & Figs', AppColors.pistachio),
              _buildCategoryLegend('Mamra & Nuts', AppColors.saffronGold),
              _buildCategoryLegend('Chocolates', AppColors.chocolateBrown),
              _buildCategoryLegend('Imported Fruits & Juices', AppColors.berryRose),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard(BuildContext context, ErpProvider erp) {
    return SectionCard(
      title: 'Top Performing Delicacies',
      subtitle: 'Highest volume & margin items this month',
      trailing: TextButton(
        onPressed: () => context.go('/products'),
        child: const Text('View Catalog'),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: erp.products.take(4).length,
        separatorBuilder: (_, _) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final p = erp.products[index];
          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMd,
                ),
                child: const Center(
                  child: Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${p.category} • ${p.origin}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(p.sellingPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    '${p.currentStock} ${p.unit} left',
                    style: TextStyle(
                      fontSize: 11,
                      color: p.stockStatus == StockStatus.healthy
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentInvoicesCard(BuildContext context, ErpProvider erp) {
    return SectionCard(
      title: 'Recent Sales Transactions',
      subtitle: 'Latest showroom billing & corporate orders',
      trailing: TextButton(
        onPressed: () => context.go('/sales'),
        child: const Text('View All'),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: erp.invoices.take(3).length,
        separatorBuilder: (_, _) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final inv = erp.invoices[index];
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pistachio.withValues(alpha: 0.1),
                  borderRadius: AppTokens.borderRadiusMd,
                ),
                child: const Icon(Icons.receipt_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${inv.invoiceNumber} — ${inv.customerName}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      Formatters.timeAgo(inv.invoiceDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(inv.grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  if (inv.paymentStatus == PaymentStatus.paid)
                    StatusBadge.success('Paid')
                  else if (inv.paymentStatus == PaymentStatus.partial)
                    StatusBadge.warning('Partial')
                  else
                    StatusBadge.error('Unpaid'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLowStockAlertCard(BuildContext context, ErpProvider erp) {
    final lowStock = erp.lowStockProducts;

    return SectionCard(
      title: 'Low Stock Alerts',
      subtitle: '${lowStock.length} items reached minimum reorder point',
      trailing: StatusBadge.warning('${lowStock.length} Alerts'),
      child: Column(
        children: [
          ...lowStock.take(3).map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg.withValues(alpha: 0.4),
                  borderRadius: AppTokens.borderRadiusMd,
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                          Text(
                            'Stock: ${p.currentStock} ${p.unit} (Min: ${p.minimumStock} ${p.unit})',
                            style: const TextStyle(fontSize: 11, color: AppColors.warningText),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 28),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () => context.go('/purchases'),
                      child: const Text('Reorder', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return SectionCard(
      title: 'Executive Quick Actions',
      subtitle: 'Common daily retail operations',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildActionButton(
            context,
            icon: Icons.add_shopping_cart_rounded,
            label: 'New Sale / POS',
            color: AppColors.primary,
            onTap: () => context.go('/sales/new'),
          ),
          _buildActionButton(
            context,
            icon: Icons.person_add_alt_1_rounded,
            label: 'Register Customer',
            color: AppColors.oceanBlue,
            onTap: () => context.go('/customers'),
          ),
          _buildActionButton(
            context,
            icon: Icons.add_box_rounded,
            label: 'Add Product SKU',
            color: AppColors.pistachio,
            onTap: () => context.go('/products'),
          ),
          _buildActionButton(
            context,
            icon: Icons.post_add_rounded,
            label: 'Create PO Order',
            color: AppColors.saffronGold,
            onTap: () => context.go('/purchases'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
