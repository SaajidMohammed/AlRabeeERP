import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/customer_model.dart';
import '../../providers/erp_provider.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _selectedTier = 'All';

  void _showAddCustomerDialog(BuildContext context, [CustomerModel? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final companyCtrl = TextEditingController(text: existing?.company ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? 'Mumbai');
    final gstinCtrl = TextEditingController(text: existing?.gstin ?? '');
    String tier = existing?.tier ?? 'Retail';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Customer Profile' : 'Register New Customer'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Customer Full Name *'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: companyCtrl,
                          decoration: const InputDecoration(labelText: 'Company (Optional)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: tier,
                          decoration: const InputDecoration(labelText: 'Customer Tier'),
                          items: const [
                            DropdownMenuItem(value: 'Retail', child: Text('Retail')),
                            DropdownMenuItem(value: 'VIP Client', child: Text('VIP Client')),
                            DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                            DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => tier = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: const InputDecoration(labelText: 'Phone Number *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email Address'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Street Address'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: const InputDecoration(labelText: 'City'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: gstinCtrl,
                          decoration: const InputDecoration(labelText: 'GSTIN (For Invoicing)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                final customer = CustomerModel(
                  id: existing?.id ?? 'CUST-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  company: companyCtrl.text,
                  phone: phoneCtrl.text,
                  email: emailCtrl.text,
                  address: addressCtrl.text,
                  city: cityCtrl.text,
                  gstin: gstinCtrl.text,
                  tier: tier,
                  totalPurchases: existing?.totalPurchases ?? 0.0,
                  outstandingBalance: existing?.outstandingBalance ?? 0.0,
                  totalOrders: existing?.totalOrders ?? 0,
                  lastPurchaseDate: existing?.lastPurchaseDate,
                  activities: existing?.activities,
                );

                context.read<ErpProvider>().saveCustomer(customer, isNew: !isEditing);
                Navigator.of(ctx).pop();
              },
              child: Text(isEditing ? 'Save Changes' : 'Register Customer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerDetail(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          customer.name.substring(0, 1),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  customer.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge.gold(customer.tier),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${customer.phone} • ${customer.email} • ${customer.city}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: '360° Overview'),
                    Tab(text: 'Sales Invoices'),
                    Tab(text: 'Activities & Notes'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Overview
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricTile(
                                    'Total Lifetime Purchases',
                                    Formatters.currency(customer.totalPurchases),
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildMetricTile(
                                    'Outstanding Balance',
                                    Formatters.currency(customer.outstandingBalance),
                                    customer.outstandingBalance > 0 ? AppColors.error : AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildMetricTile(
                                    'Total Orders',
                                    '${customer.totalOrders}',
                                    AppColors.oceanBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text('Address & Tax Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('${customer.address}, ${customer.city}', style: Theme.of(context).textTheme.bodyMedium),
                            if (customer.gstin.isNotEmpty)
                              Text('GSTIN: ${customer.gstin}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),

                      // Invoices
                      Consumer<ErpProvider>(
                        builder: (context, erp, _) {
                          final customerInvoices = erp.invoices.where((i) => i.customerId == customer.id).toList();
                          if (customerInvoices.isEmpty) {
                            return const Center(child: Text('No invoice history for this customer.'));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: customerInvoices.length,
                            separatorBuilder: (_, _) => const Divider(height: 12),
                            itemBuilder: (context, idx) {
                              final inv = customerInvoices[idx];
                              return ListTile(
                                dense: true,
                                title: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(Formatters.dateTime(inv.invoiceDate)),
                                trailing: Text(
                                  Formatters.currency(inv.grandTotal),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Activities
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Activity Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            const Text('• Client visited flagship showroom for Ramadan hamper tasting.'),
                            const SizedBox(height: 6),
                            const Text('• Preferred delivery via refrigerated van on weekends.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    final filteredCustomers = _selectedTier == 'All'
        ? erp.customers
        : erp.customers.where((c) => c.tier == _selectedTier).toList();

    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                    'Customer Management',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage retail clients, corporate banquet accounts & VIP concierge profiles',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCustomerDialog(context),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('Add Customer'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: ErpDataTable<CustomerModel>(
              items: filteredCustomers,
              searchPlaceholder: 'Search by name, phone, company, or city...',
              searchMatcher: (customer, query) =>
                  customer.name.toLowerCase().contains(query) ||
                  customer.phone.contains(query) ||
                  customer.company.toLowerCase().contains(query) ||
                  customer.city.toLowerCase().contains(query),
              onRowTap: (customer) => _showCustomerDetail(context, customer),
              trailingHeaderActions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tier: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedTier,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Tiers')),
                      DropdownMenuItem(value: 'VIP Client', child: Text('VIP Client')),
                      DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                      DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
                      DropdownMenuItem(value: 'Retail', child: Text('Retail')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTier = val);
                    },
                  ),
                ],
              ),
              columns: [
                ErpTableColumn(
                  title: 'Customer Name',
                  cellBuilder: (c) => Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          c.name.substring(0, 1),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (c.company.isNotEmpty)
                            Text(c.company, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  comparator: (a, b) => a.name.compareTo(b.name),
                ),
                ErpTableColumn(
                  title: 'Phone & City',
                  cellBuilder: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(c.phone, style: const TextStyle(fontSize: 12)),
                      Text(c.city, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                ErpTableColumn(
                  title: 'Tier',
                  cellBuilder: (c) => StatusBadge.gold(c.tier),
                ),
                ErpTableColumn(
                  title: 'Total Purchases',
                  isNumeric: true,
                  cellBuilder: (c) => Text(
                    Formatters.currency(c.totalPurchases),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  comparator: (a, b) => a.totalPurchases.compareTo(b.totalPurchases),
                ),
                ErpTableColumn(
                  title: 'Outstanding',
                  isNumeric: true,
                  cellBuilder: (c) => Text(
                    Formatters.currency(c.outstandingBalance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: c.outstandingBalance > 0 ? AppColors.error : AppColors.success,
                    ),
                  ),
                  comparator: (a, b) => a.outstandingBalance.compareTo(b.outstandingBalance),
                ),
                ErpTableColumn(
                  title: 'Actions',
                  cellBuilder: (c) => Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit Profile',
                        onPressed: () => _showAddCustomerDialog(context, c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.point_of_sale_rounded, size: 18, color: AppColors.primary),
                        tooltip: 'New Sale for this Customer',
                        onPressed: () => context.go('/sales/new'),
                      ),
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
}
