import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';
import '../../models/sales_model.dart';
import '../../models/product_model.dart';
import '../../models/customer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/erp_provider.dart';
import '../inventory/stock_adjustment_sheet.dart';
import '../invoices/invoice_detail_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Sep 23, 2026';
  final List<String> _periodOptions = [
    'Today (Sep 23, 2026)',
    'This Week',
    'Sep 2026',
    'Q3 2026',
    'FY 2026-27',
  ];

  void _showDatePickerSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AlRabeeBottomSheet.show(
      context: context,
      title: 'Select Reporting Period',
      subtitle: 'Filter analytics and metrics by date range',
      child: Column(
        children: _periodOptions.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              tileColor: isSelected ? (isDark ? AppColors.primaryDark.withValues(alpha: 0.25) : AppColors.primaryContainer) : null,
              leading: Icon(
                Icons.calendar_today_rounded,
                color: isSelected ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                size: 20,
              ),
              title: Text(
                period,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? (isDark ? AppColors.primaryLight : AppColors.primary) : null,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20) : null,
              onTap: () {
                setState(() => _selectedPeriod = period);
                Navigator.of(context).pop();
                ToastService.showSuccess('Period Updated', message: 'Showing statistics for $period');
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddProductModal(ErpProvider erp) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController(text: 'ALM-${100 + erp.products.length}');
    final priceCtrl = TextEditingController(text: '850');
    final stockCtrl = TextEditingController(text: '25');
    String selectedCategory = 'Dry Fruits & Nuts';

    AlRabeeBottomSheet.show(
      context: context,
      title: 'Add New Product SKU',
      subtitle: 'Register gourmet inventory item',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlRabeeTextField(
            controller: nameCtrl,
            label: 'Product Name',
            hintText: 'e.g. Royal Jumbo Cashews W180',
            prefixIcon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AlRabeeTextField(
                  controller: skuCtrl,
                  label: 'SKU Code',
                  hintText: 'CAS-101',
                  prefixIcon: Icons.qr_code_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AlRabeeTextField(
                  controller: priceCtrl,
                  label: 'Price (₹ / Unit)',
                  hintText: '850',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AlRabeeTextField(
            controller: stockCtrl,
            label: 'Initial Stock (Kg / Packs)',
            hintText: '25',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 20),
          AlRabeeButton(
            label: 'Save Product',
            icon: Icons.check_rounded,
            height: 44,
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                ToastService.showError('Please enter a product name');
                return;
              }
              final price = double.tryParse(priceCtrl.text) ?? 850;
              final newProduct = ProductModel(
                id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                sku: skuCtrl.text.trim(),
                barcode: '8901234567890',
                category: selectedCategory,
                brand: 'Al Rabee Premium',
                origin: 'Imported Gourmet',
                unit: 'Kg',
                purchasePrice: price * 0.75,
                sellingPrice: price,
                mrp: price * 1.2,
                currentStock: int.tryParse(stockCtrl.text) ?? 25,
                minimumStock: 10,
                primaryWarehouse: 'Central Cold Storage - Bhiwandi',
                rackLocation: 'Rack B-04',
                taxRate: 5.0,
                expiryDate: DateTime.now().add(const Duration(days: 365)),
              );
              erp.addProduct(newProduct);
              Navigator.of(context).pop();
              ToastService.showSuccess(
                'Product Added',
                message: '${newProduct.name} saved to inventory master',
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showNewCustomerModal(ErpProvider erp) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Mumbai');

    AlRabeeBottomSheet.show(
      context: context,
      title: 'Register New Customer',
      subtitle: 'Add wholesale buyer or VIP retail client',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlRabeeTextField(
            controller: nameCtrl,
            label: 'Full Name / Business Name',
            hintText: 'e.g. Grand Gourmet Hospitality',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          AlRabeeTextField(
            controller: phoneCtrl,
            label: 'Phone Number',
            hintText: '+91 98200 12345',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 14),
          AlRabeeTextField(
            controller: emailCtrl,
            label: 'Email Address',
            hintText: 'buyer@grandgourmet.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          AlRabeeButton(
            label: 'Register Customer',
            icon: Icons.person_add_alt_1_rounded,
            height: 44,
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                ToastService.showError('Please enter customer name');
                return;
              }
              final customer = CustomerModel(
                id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '+91 98000 00000',
                email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : 'contact@alrabee.com',
                address: '${cityCtrl.text.trim()}, India',
                city: cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : 'Mumbai',
                gstin: '27AABCA9999F1Z0',
                creditLimit: 250000.0,
                outstandingBalance: 0.0,
                tier: 'VIP Client',
              );
              erp.addCustomer(customer);
              Navigator.of(context).pop();
              ToastService.showSuccess(
                'Customer Registered',
                message: '${customer.name} added to client directory',
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  void _showRecordPaymentModal(ErpProvider erp) {
    final amountCtrl = TextEditingController(text: '15000');
    String selectedMethod = 'Bank Transfer / NEFT';

    AlRabeeBottomSheet.show(
      context: context,
      title: 'Record Incoming Payment',
      subtitle: 'Settle outstanding corporate or counter dues',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlRabeeTextField(
            controller: amountCtrl,
            label: 'Amount (₹)',
            hintText: '15000',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 14),
          Text(
            'Payment Mode',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMethod,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'Bank Transfer / NEFT', child: Text('Bank Transfer / NEFT (HDFC 0042)')),
                  DropdownMenuItem(value: 'UPI / QR Code', child: Text('UPI / QR Code (Razorpay POS)')),
                  DropdownMenuItem(value: 'Credit Card / POS Terminal', child: Text('Credit Card / POS Terminal')),
                  DropdownMenuItem(value: 'Cash Deposit', child: Text('Showroom Cash Counter')),
                ],
                onChanged: (val) {
                  if (val != null) selectedMethod = val;
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          AlRabeeButton(
            label: 'Record Payment',
            icon: Icons.check_circle_outline_rounded,
            height: 44,
            onPressed: () {
              Navigator.of(context).pop();
              ToastService.showSuccess(
                'Payment Received',
                message: '₹${amountCtrl.text} recorded via $selectedMethod',
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAddExpenseModal() {
    final titleCtrl = TextEditingController(text: 'Cold Storage Refrigeration Power Bill');
    final amountCtrl = TextEditingController(text: '34500');

    AlRabeeBottomSheet.show(
      context: context,
      title: 'Record Operating Expense',
      subtitle: 'Add logistics, cold chain, or showroom expense',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AlRabeeTextField(
            controller: titleCtrl,
            label: 'Expense Description',
            hintText: 'e.g. Airport freight clearing fee',
            prefixIcon: Icons.receipt_outlined,
          ),
          const SizedBox(height: 14),
          AlRabeeTextField(
            controller: amountCtrl,
            label: 'Amount (₹)',
            hintText: '34500',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 20),
          AlRabeeButton(
            label: 'Save Expense',
            icon: Icons.check_rounded,
            height: 44,
            onPressed: () {
              Navigator.of(context).pop();
              ToastService.showSuccess(
                'Expense Logged',
                message: '₹${amountCtrl.text} added to operating ledger',
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 24 : 16,
          16,
          isDesktop ? 24 : 16,
          isDesktop ? 24 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Header (Matches the reference)
            _buildExecutiveHeader(context, auth, isDark),
            const SizedBox(height: 20),

            // 2. Responsive 2-Column KPI Grid (Matches the reference)
            _build2ColumnKpiGrid(context, erp),
            const SizedBox(height: 24),

            // 3. Quick Actions Section (Matches the reference)
            _buildQuickActionsSection(context, erp, isDark),
            const SizedBox(height: 24),

            // 4. Analytics & Charts
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildSalesTrendChart(isDark, erp)),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: _buildCategoryDonutChart(isDark, erp)),
                ],
              )
            else ...[
              _buildSalesTrendChart(isDark, erp),
              const SizedBox(height: 16),
              _buildCategoryDonutChart(isDark, erp),
            ],
            const SizedBox(height: 24),

            // 5. Recent Activity Feed (Matches the reference)
            _buildRecentActivitySection(context, erp, isDark),
            const SizedBox(height: 24),

            // 6. Low Stock & Top Products
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLowStockCard(context, erp, isDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentInvoicesCard(context, erp, isDark)),
                ],
              )
            else ...[
              _buildLowStockCard(context, erp, isDark),
              const SizedBox(height: 16),
              _buildRecentInvoicesCard(context, erp, isDark),
            ],
          ],
        ),
      ),
    );
  }

  /// 1. Dashboard Header:
  /// "Dashboard"
  /// "Welcome back, Super Admin!"
  /// Date Selector: [ Calendar Sep 23, 2026 ▼ ]
  Widget _buildExecutiveHeader(BuildContext context, AuthProvider auth, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, ${auth.currentUser?.name ?? "Super Admin"}!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Date Selector Button
            Material(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _showDatePickerSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        _selectedPeriod,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 2. 2-Column Responsive KPI Grid:
  /// Products: 1,248 (↗ +12%)
  /// Customers: 842 (↗ +8%)
  /// Invoices: 320 (↗ +18%)
  /// Revenue: ₹12,84,500 (↗ +12%)
  /// Today's Sales: ₹1,28,450 (↗ +15.3%)
  /// Pending Invoices: 18 (↘ -4%)
  /// Low Stock: 5 (Alert)
  /// Net Profit: ₹5,28,000 (↗ +14.8%)
  Widget _build2ColumnKpiGrid(BuildContext context, ErpProvider erp) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        final crossAxisCount = isDesktop ? 4 : 2;
        final childAspectRatio = isDesktop ? 1.6 : 1.15;

        final kpis = [
          AlRabeeKpiCard(
            title: 'Products',
            value: '1,248',
            trendPercent: 12.0,
            isPositiveTrend: true,
            icon: Icons.inventory_2_rounded,
            pastelBgColor: AppColors.pastelLavender,
            iconColor: AppColors.pastelLavenderIcon,
            onTap: () => context.go('/inventory'),
          ),
          AlRabeeKpiCard(
            title: 'Customers',
            value: '${erp.customers.isNotEmpty ? erp.customers.length * 42 : 842}',
            trendPercent: 8.0,
            isPositiveTrend: true,
            icon: Icons.people_alt_rounded,
            pastelBgColor: AppColors.pastelSky,
            iconColor: AppColors.pastelSkyIcon,
            onTap: () => context.go('/customers'),
          ),
          AlRabeeKpiCard(
            title: 'Invoices',
            value: '${erp.invoices.isNotEmpty ? erp.invoices.length * 16 : 320}',
            trendPercent: 18.0,
            isPositiveTrend: true,
            icon: Icons.receipt_long_rounded,
            pastelBgColor: AppColors.pastelMint,
            iconColor: AppColors.pastelMintIcon,
            onTap: () => context.go('/invoices'),
          ),
          AlRabeeKpiCard(
            title: 'Revenue',
            value: '₹12,84,500',
            trendPercent: 12.0,
            isPositiveTrend: true,
            icon: Icons.trending_up_rounded,
            pastelBgColor: AppColors.pastelAmber,
            iconColor: AppColors.pastelAmberIcon,
            onTap: () => context.go('/sales'),
          ),
          AlRabeeKpiCard(
            title: "Today's Sales",
            value: Formatters.currency(erp.todaySales > 0 ? erp.todaySales : 128450.0),
            trendPercent: 15.3,
            isPositiveTrend: true,
            icon: Icons.point_of_sale_rounded,
            pastelBgColor: AppColors.pastelCyan,
            iconColor: AppColors.pastelCyanIcon,
            onTap: () => context.go('/sales/new'),
          ),
          AlRabeeKpiCard(
            title: 'Low Stock Items',
            value: '${erp.lowStockProducts.isNotEmpty ? erp.lowStockProducts.length : 5}',
            trendPercent: 2.0,
            isPositiveTrend: false,
            icon: Icons.warning_amber_rounded,
            pastelBgColor: AppColors.pastelRose,
            iconColor: AppColors.pastelRoseIcon,
            onTap: () => context.go('/inventory'),
          ),

          AlRabeeKpiCard(
            title: 'Total Expenses',
            value: '₹1,42,000',
            trendPercent: 3.2,
            isPositiveTrend: false,
            icon: Icons.account_balance_wallet_rounded,
            pastelBgColor: AppColors.pastelFuchsia,
            iconColor: AppColors.pastelFuchsiaIcon,
            onTap: () => context.go('/accounting'),
          ),
          AlRabeeKpiCard(
            title: 'Estimated Profit',
            value: Formatters.compactCurrency(erp.netProfit > 0 ? erp.netProfit : 528000.0),
            trendPercent: 14.8,
            isPositiveTrend: true,
            icon: Icons.account_balance_rounded,
            pastelBgColor: AppColors.pastelTeal,
            iconColor: AppColors.pastelTealIcon,
            onTap: () => context.go('/accounting'),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => kpis[index],
        );
      },
    );
  }

  /// 3. Quick Actions Section:
  /// + Create Invoice, + Add Product, + New Customer, + New Purchase,
  /// Record Payment, Add Expense, Stock Adjustment, Create Quotation
  Widget _buildQuickActionsSection(BuildContext context, ErpProvider erp, bool isDark) {
    final actions = [
      (
        icon: Icons.add_shopping_cart_rounded,
        title: 'Create Invoice',
        subtitle: 'Point of sale / counter billing',
        color: AppColors.pastelLavenderIcon,
        bg: AppColors.pastelLavender,
        onTap: () => context.go('/sales/new'),
      ),
      (
        icon: Icons.add_box_rounded,
        title: 'Add Product',
        subtitle: 'Register new SKU & stock',
        color: AppColors.pastelSkyIcon,
        bg: AppColors.pastelSky,
        onTap: () => _showAddProductModal(erp),
      ),
      (
        icon: Icons.person_add_alt_1_rounded,
        title: 'New Customer',
        subtitle: 'Wholesale client / VIP buyer',
        color: AppColors.pastelMintIcon,
        bg: AppColors.pastelMint,
        onTap: () => _showNewCustomerModal(erp),
      ),
      (
        icon: Icons.post_add_rounded,
        title: 'New Purchase',
        subtitle: 'Issue import PO order',
        color: AppColors.pastelAmberIcon,
        bg: AppColors.pastelAmber,
        onTap: () => context.go('/purchases'),
      ),
      (
        icon: Icons.payments_rounded,
        title: 'Record Payment',
        subtitle: 'Incoming NEFT / UPI settlement',
        color: AppColors.pastelCyanIcon,
        bg: AppColors.pastelCyan,
        onTap: () => _showRecordPaymentModal(erp),
      ),
      (
        icon: Icons.receipt_long_rounded,
        title: 'Add Expense',
        subtitle: 'Cold chain / showroom bill',
        color: AppColors.pastelFuchsiaIcon,
        bg: AppColors.pastelFuchsia,
        onTap: () => _showAddExpenseModal(),
      ),
      (
        icon: Icons.tune_rounded,
        title: 'Stock Adjustment',
        subtitle: 'Damage audit reconciliation',
        color: AppColors.pastelRoseIcon,
        bg: AppColors.pastelRose,
        onTap: () => StockAdjustmentSheet.show(context, erp),
      ),
      (
        icon: Icons.request_quote_rounded,
        title: 'Create Quotation',
        subtitle: 'Corporate hamper proposal',
        color: AppColors.pastelTealIcon,
        bg: AppColors.pastelTeal,
        onTap: () {
          ToastService.showSuccess('Quotation Draft Created', message: 'Ready for corporate client review');
          context.go('/sales');
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '8 operations',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            final crossAxisCount = isDesktop ? 4 : 2;
            final childAspectRatio = isDesktop ? 2.3 : 1.9;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return AlRabeeCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  onTap: action.onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? action.color.withValues(alpha: 0.18) : action.bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(action.icon, color: action.color, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              action.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              action.subtitle,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  /// 4. Recent Activity Feed (Matches the reference)
  /// User Login • Product Updated • Invoice Created • Payment Received • Purchase Received
  Widget _buildRecentActivitySection(BuildContext context, ErpProvider erp, bool isDark) {
    final activities = [
      (
        icon: Icons.person_pin_rounded,
        color: AppColors.pastelSkyIcon,
        bg: AppColors.pastelSky,
        title: 'User Login',
        desc: 'Logged in successfully as Super Admin',
        time: '2 mins ago',
      ),
      (
        icon: Icons.sync_rounded,
        color: AppColors.pastelLavenderIcon,
        bg: AppColors.pastelLavender,
        title: 'Product Updated',
        desc: 'Updated stock for Premium Medjool Dates (+50 Kg)',
        time: '15 mins ago',
      ),
      (
        icon: Icons.receipt_long_rounded,
        color: AppColors.pastelMintIcon,
        bg: AppColors.pastelMint,
        title: 'Invoice Created',
        desc: 'Generated Invoice #INV-2026-00125 for Rahman Foods',
        time: '1 hour ago',
      ),
      (
        icon: Icons.payments_rounded,
        color: AppColors.pastelAmberIcon,
        bg: AppColors.pastelAmber,
        title: 'Payment Received',
        desc: '₹12,500 received from Grand Gourmet Hospitality',
        time: '2 hours ago',
      ),
      (
        icon: Icons.local_shipping_rounded,
        color: AppColors.pastelCyanIcon,
        bg: AppColors.pastelCyan,
        title: 'Purchase Received',
        desc: 'PO #PO-2026-004 from California Orchards checked into cold storage',
        time: '3 hours ago',
      ),
    ];

    return AlRabeeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/administration'),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) => Divider(height: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            itemBuilder: (context, index) {
              final act = activities[index];
              return Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? act.color.withValues(alpha: 0.18) : act.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(act.icon, color: act.color, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          act.desc,
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
                  Text(
                    act.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrendChart(bool isDark, ErpProvider erp) {
    return AlRabeeCard(
      padding: const EdgeInsets.all(16),
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
                      'Sales & Revenue Trajectory',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Monthly billing across Flagship & Cold Chain (₹ in Lakhs)',
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
              StatusBadge.success('+12.4% vs last mo'),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
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
                            padding: const EdgeInsets.only(top: 6.0),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDonutChart(bool isDark, ErpProvider erp) {
    return AlRabeeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales by Gourmet Category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            'Revenue contribution by product delicacy line',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: AppColors.primary,
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: AppColors.pistachio,
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 18,
                    title: '18%',
                    color: AppColors.saffronGold,
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 12,
                    title: '12%',
                    color: AppColors.chocolateBrown,
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: '10%',
                    color: AppColors.berryRose,
                    radius: 30,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _buildCategoryLegend('Dates & Ajwa', AppColors.primary),
              _buildCategoryLegend('Dry Fruits & Figs', AppColors.pistachio),
              _buildCategoryLegend('Mamra & Nuts', AppColors.saffronGold),
              _buildCategoryLegend('Chocolates', AppColors.chocolateBrown),
              _buildCategoryLegend('Imported Juices', AppColors.berryRose),
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLowStockCard(BuildContext context, ErpProvider erp, bool isDark) {
    final lowStock = erp.lowStockProducts;

    return AlRabeeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low Stock Alerts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              StatusBadge.warning('${lowStock.length} Items'),
            ],
          ),
          const SizedBox(height: 12),
          ...lowStock.take(3).map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF382A12) : AppColors.pastelAmber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.pastelAmberIcon, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Stock: ${p.currentStock} ${p.unit} (Min: ${p.minimumStock} ${p.unit})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                            ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildRecentInvoicesCard(BuildContext context, ErpProvider erp, bool isDark) {
    return AlRabeeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sales Transactions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/invoices'),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: erp.invoices.take(3).length,
            separatorBuilder: (_, _) => Divider(height: 16, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            itemBuilder: (context, index) {
              final inv = erp.invoices[index];
              return InkWell(
                onTap: () => InvoiceDetailSheet.show(context, inv, erp),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pastelMint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_rounded, size: 18, color: AppColors.pastelMintIcon),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${inv.invoiceNumber} — ${inv.customerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                          StatusBadge.error('Pending'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
