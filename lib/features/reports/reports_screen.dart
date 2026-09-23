import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../core/widgets/cards/stat_card.dart';
import '../../models/accounting_model.dart';
import '../../models/hr_model.dart';
import '../../models/product_model.dart';
import '../../providers/erp_provider.dart';

enum ReportCategory {
  sales('Sales & Revenue', Icons.analytics_rounded, AppColors.primary),
  inventory('Inventory Valuation', Icons.inventory_2_rounded, AppColors.oceanBlue),
  procurement('Procurement & Imports', Icons.flight_land_rounded, AppColors.pistachio),
  finance('Financial & GST Tax', Icons.account_balance_rounded, AppColors.saffronGold),
  hr('HR & Payroll Statement', Icons.badge_rounded, AppColors.berryRose);

  final String label;
  final IconData icon;
  final Color color;
  const ReportCategory(this.label, this.icon, this.color);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportCategory _selectedCategory = ReportCategory.sales;
  String _selectedPeriod = 'This Month';
  String _selectedBranch = 'All Outlets';
  String _tableSearchQuery = '';

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'Q1 FY 2026', 'YTD'];
  final List<String> _branches = [
    'All Outlets',
    'Flagship Boutique — Indiranagar',
    'Airport Terminal Hub',
    'Central Cold Storage Hub',
  ];

  void _showExportPreviewDialog(BuildContext context, String format) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedCategory.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                format == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.table_view_rounded,
                color: _selectedCategory.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Al Rabee ERP — $format Export', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${_selectedCategory.label} • $_selectedPeriod', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Entity:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Text('Al Rabee Premium Gourmet & Cold Chain LLP', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Branch:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(_selectedBranch, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Generated On:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(Formatters.dateTime(DateTime.now()), style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Authorized By:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Text('Finance Director (Audit Seal #8429)', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Report includes digital signature verification, GST compliance hash, and ledger reconciliation stamps.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _selectedCategory.color, foregroundColor: Colors.white),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text('Download $format Document'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ ${_selectedCategory.label} $format downloaded successfully.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Reports & Analytics Center',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Consolidated financial audits, import logistics, live stock valuation & GST tax statements',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.table_view_rounded, size: 16),
                    label: const Text('Export Excel / CSV'),
                    onPressed: () => _showExportPreviewDialog(context, 'Excel'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Export PDF Report'),
                    onPressed: () => _showExportPreviewDialog(context, 'PDF'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time Period & Branch Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: AppTokens.borderRadiusLg,
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Period Selector Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    ..._periods.map((p) {
                      final isSel = _selectedPeriod == p;
                      return ChoiceChip(
                        label: Text(p),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedPeriod = p),
                      );
                    }),
                  ],
                ),

                // Branch Selector Dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded, size: 18, color: AppColors.oceanBlue),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedBranch,
                      underline: const SizedBox.shrink(),
                      borderRadius: AppTokens.borderRadiusMd,
                      items: _branches
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBranch = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Selector Pills (Wrapped - Zero Horizontal Scroll)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportCategory.values.map((cat) {
              final isSel = _selectedCategory == cat;
              return ChoiceChip(
                avatar: Icon(cat.icon, size: 16, color: isSel ? Colors.white : cat.color),
                label: Text(cat.label),
                selected: isSel,
                selectedColor: cat.color,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => setState(() {
                  _selectedCategory = cat;
                  _tableSearchQuery = '';
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Dynamic Executive KPI Grid
          _buildCategoryKpiGrid(erp, isDesktop),
          const SizedBox(height: 16),

          // Visual Chart Trend / Breakdown Section
          _buildCategoryChartSection(erp, isDark, isDesktop),
          const SizedBox(height: 16),

          // Detailed Table / Audit Statement
          _buildDetailedReportTable(erp, isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryKpiGrid(ErpProvider erp, bool isDesktop) {
    List<Widget> cards = [];

    switch (_selectedCategory) {
      case ReportCategory.sales:
        cards = [
          StatCard(
            title: 'Gross Invoiced Revenue',
            value: Formatters.compactCurrency(erp.monthlyRevenue),
            subtitle: '+14.8% vs previous period',
            icon: Icons.payments_rounded,
            iconColor: AppColors.primary,
          ),
          StatCard(
            title: 'Total Invoices Issued',
            value: '${erp.invoices.length}',
            subtitle: '${erp.quotations.length} active quotations',
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Average Order Value',
            value: Formatters.currency(erp.invoices.isNotEmpty ? erp.monthlyRevenue / erp.invoices.length : 0),
            subtitle: 'Corporate gifting & Counter',
            icon: Icons.shopping_basket_rounded,
            iconColor: AppColors.saffronGold,
          ),
          StatCard(
            title: 'GST Collected (5% & 12%)',
            value: Formatters.compactCurrency(erp.monthlyRevenue * 0.08),
            subtitle: 'Eligible for ITC claim',
            icon: Icons.account_balance_rounded,
            iconColor: AppColors.success,
          ),
        ];
        break;

      case ReportCategory.inventory:
        cards = [
          StatCard(
            title: 'Total Stock Valuation',
            value: Formatters.compactCurrency(erp.totalInventoryValue),
            subtitle: '${erp.products.length} distinct SKUs',
            icon: Icons.warehouse_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Cold Storage Occupancy',
            value: '88.4%',
            subtitle: 'Central Hub — 5,000 kg cap',
            icon: Icons.ac_unit_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Stock Health Index',
            value: '${erp.products.where((p) => p.stockStatus == StockStatus.healthy).length} / ${erp.products.length}',
            subtitle: 'Healthy stock ratio',
            icon: Icons.health_and_safety_rounded,
            iconColor: AppColors.success,
          ),
          StatCard(
            title: 'Reorder Alerts',
            value: '${erp.products.where((p) => p.stockStatus == StockStatus.lowStock).length}',
            subtitle: 'Items below minimum buffer',
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
          ),
        ];
        break;

      case ReportCategory.procurement:
        cards = [
          StatCard(
            title: 'Consignments Value',
            value: Formatters.compactCurrency(erp.monthlyPurchases),
            subtitle: '${erp.purchaseOrders.length} international POs',
            icon: Icons.flight_land_rounded,
            iconColor: AppColors.pistachio,
          ),
          StatCard(
            title: 'Active Global Suppliers',
            value: '${erp.suppliers.length}',
            subtitle: 'Saudi, Iran, Turkey, Belgium',
            icon: Icons.public_rounded,
            iconColor: AppColors.oceanBlue,
          ),
          StatCard(
            title: 'Import Customs & Freight',
            value: Formatters.compactCurrency(erp.monthlyPurchases * 0.12),
            subtitle: 'Port clearance & cold freight',
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.saffronGold,
          ),
          StatCard(
            title: 'Pending Supplier Bills',
            value: Formatters.compactCurrency(erp.totalPayables),
            subtitle: 'Due within 30 days',
            icon: Icons.pending_actions_rounded,
            iconColor: AppColors.berryRose,
          ),
        ];
        break;

      case ReportCategory.finance:
        cards = [
          StatCard(
            title: 'Net Profit Realized',
            value: Formatters.compactCurrency(erp.netProfit),
            subtitle: 'Est. 62% gross margin',
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.success,
          ),
          StatCard(
            title: 'Accounts Receivable',
            value: Formatters.compactCurrency(erp.totalReceivables),
            subtitle: 'Corporate VIPs & B2B clients',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.saffronGold,
          ),
          StatCard(
            title: 'Accounts Payable',
            value: Formatters.compactCurrency(erp.totalPayables),
            subtitle: 'Foreign exchange & vendors',
            icon: Icons.payments_rounded,
            iconColor: AppColors.berryRose,
          ),
          StatCard(
            title: 'Total Operating Expenses',
            value: Formatters.compactCurrency(
              erp.transactions
                  .where((t) => t.type == TransactionType.expense)
                  .fold(0.0, (s, t) => s + t.amount),
            ),
            subtitle: 'Cold chain electricity & rent',
            icon: Icons.receipt_rounded,
            iconColor: AppColors.oceanBlue,
          ),
        ];
        break;

      case ReportCategory.hr:
        cards = [
          StatCard(
            title: 'Total Monthly Payroll',
            value: Formatters.compactCurrency(erp.employees.fold(0.0, (s, e) => s + e.grossSalary)),
            subtitle: '${erp.employees.length} full-time staff',
            icon: Icons.people_rounded,
            iconColor: AppColors.berryRose,
          ),
          StatCard(
            title: 'Today\'s Attendance',
            value: '${erp.attendance.where((a) => a.status == AttendanceStatus.present).length} / ${erp.employees.length}',
            subtitle: '94.2% boutique punctuality',
            icon: Icons.how_to_reg_rounded,
            iconColor: AppColors.success,
          ),
          StatCard(
            title: 'Pending Leave Approvals',
            value: '${erp.leaveRequests.where((l) => l.status == LeaveStatus.pending).length}',
            subtitle: 'Awaiting manager signoff',
            icon: Icons.event_busy_rounded,
            iconColor: AppColors.saffronGold,
          ),
          StatCard(
            title: 'Avg. Staff Tenure',
            value: '2.8 Yrs',
            subtitle: 'Gourmet boutique team',
            icon: Icons.verified_user_rounded,
            iconColor: AppColors.oceanBlue,
          ),
        ];
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1100;

        if (isMobile) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: cards,
          );
        }

        if (isTablet) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: cards,
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChartSection(ErpProvider erp, bool isDark, bool isDesktop) {
    return SectionCard(
      title: '${_selectedCategory.label} Trend & Breakdown',
      subtitle: 'Comparative performance over recent fiscal periods • Currency: INR (₹ in Lakhs)',
      trailing: StatusBadge.gold(_selectedPeriod),
      child: SizedBox(
        height: 220,
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
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₹${value.toInt()}L',
                      style: TextStyle(
                        fontSize: 10.5,
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
                color: _selectedCategory.color,
                barWidth: 3.5,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      _selectedCategory.color.withValues(alpha: 0.35),
                      _selectedCategory.color.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedReportTable(ErpProvider erp, bool isDark) {
    return SectionCard(
      title: 'Audited Statement: ${_selectedCategory.label}',
      subtitle: 'Showing active records for $_selectedPeriod across $_selectedBranch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search in statement
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search within statement...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) => setState(() => _tableSearchQuery = val.toLowerCase()),
            ),
          ),
          const SizedBox(height: 14),

          // Statement Records
          _buildStatementRows(erp, isDark),
        ],
      ),
    );
  }

  Widget _buildStatementRows(ErpProvider erp, bool isDark) {
    switch (_selectedCategory) {
      case ReportCategory.sales:
        final invoices = erp.invoices.where((inv) {
          return _tableSearchQuery.isEmpty ||
              inv.invoiceNumber.toLowerCase().contains(_tableSearchQuery) ||
              inv.customerName.toLowerCase().contains(_tableSearchQuery);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: invoices.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, idx) {
            final inv = invoices[idx];
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${inv.customerName} • ${inv.items.length} items (${inv.paymentMethod.toUpperCase()})',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.currency(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    StatusBadge.success(inv.paymentStatus.label),
                  ],
                ),
              ],
            );
          },
        );

      case ReportCategory.inventory:
        final products = erp.products.where((p) {
          return _tableSearchQuery.isEmpty ||
              p.name.toLowerCase().contains(_tableSearchQuery) ||
              p.sku.toLowerCase().contains(_tableSearchQuery);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, idx) {
            final p = products[idx];
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.oceanBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.oceanBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('SKU: ${p.sku} • In Stock: ${p.currentStock} ${p.unit} • ${p.primaryWarehouse}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.currency(p.totalStockValue), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Cost: ₹${p.purchasePrice.toInt()}/u', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            );
          },
        );

      case ReportCategory.procurement:
        final pos = erp.purchaseOrders.where((po) {
          return _tableSearchQuery.isEmpty ||
              po.poNumber.toLowerCase().contains(_tableSearchQuery) ||
              po.supplierName.toLowerCase().contains(_tableSearchQuery);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pos.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, idx) {
            final po = pos[idx];
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pistachio.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flight_land_rounded, size: 18, color: AppColors.pistachio),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${po.supplierName} (${po.supplierCountry}) • Expected: ${Formatters.date(po.expectedDeliveryDate)}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.currency(po.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    StatusBadge.gold(po.status.label),
                  ],
                ),
              ],
            );
          },
        );

      case ReportCategory.finance:
        final txns = erp.transactions.where((t) {
          return _tableSearchQuery.isEmpty ||
              t.referenceNumber.toLowerCase().contains(_tableSearchQuery) ||
              t.title.toLowerCase().contains(_tableSearchQuery) ||
              t.partyName.toLowerCase().contains(_tableSearchQuery);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: txns.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, idx) {
            final t = txns[idx];
            final isExpense = t.type == TransactionType.expense;
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isExpense ? AppColors.berryRose : AppColors.success).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 18,
                    color: isExpense ? AppColors.berryRose : AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${t.referenceNumber} • Party: ${t.partyName} • Account: ${t.paymentAccount}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}${Formatters.currency(t.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isExpense ? AppColors.berryRose : AppColors.success,
                      ),
                    ),
                    Text(Formatters.shortDate(t.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            );
          },
        );

      case ReportCategory.hr:
        final employees = erp.employees.where((e) {
          return _tableSearchQuery.isEmpty ||
              e.name.toLowerCase().contains(_tableSearchQuery) ||
              e.employeeCode.toLowerCase().contains(_tableSearchQuery) ||
              e.department.toLowerCase().contains(_tableSearchQuery);
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: employees.length,
          separatorBuilder: (_, _) => const Divider(height: 16),
          itemBuilder: (context, idx) {
            final e = employees[idx];
            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(e.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${e.employeeCode} • ${e.designation} (${e.department})',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Formatters.currency(e.grossSalary), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    StatusBadge.success('Disbursed'),
                  ],
                ),
              ],
            );
          },
        );
    }
  }
}
