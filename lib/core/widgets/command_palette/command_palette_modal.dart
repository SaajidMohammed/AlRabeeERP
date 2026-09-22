import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../../providers/command_palette_provider.dart';
import '../../../providers/erp_provider.dart';

class CommandPaletteModal extends StatefulWidget {
  const CommandPaletteModal({super.key});

  @override
  State<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends State<CommandPaletteModal> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<CommandPaletteProvider>();
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = palette.query.toLowerCase().trim();

    if (!palette.isOpen) return const SizedBox.shrink();

    // Search matches
    final List<CommandResultItem> results = [];

    // Navigation & Quick Actions
    final navigationActions = [
      CommandResultItem(
        title: 'Executive Dashboard',
        subtitle: 'Overview KPIs, charts & transactions',
        icon: Icons.dashboard_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/dashboard',
      ),
      CommandResultItem(
        title: 'POS / New Sale',
        subtitle: 'Quick billing & checkout counter',
        icon: Icons.point_of_sale_rounded,
        type: CommandResultType.action,
        routeOrId: '/sales/new',
      ),
      CommandResultItem(
        title: 'CRM & Lead Pipeline',
        subtitle: 'Kanban board & client follow-ups',
        icon: Icons.view_kanban_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/crm',
      ),
      CommandResultItem(
        title: 'Product Catalog',
        subtitle: 'Inventory stock & SKU master',
        icon: Icons.inventory_2_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/products',
      ),
      CommandResultItem(
        title: 'Customer Directory',
        subtitle: 'Customer ledger & 360 profiles',
        icon: Icons.people_outline_rounded,
        type: CommandResultType.navigation,
        routeOrId: '/customers',
      ),
      CommandResultItem(
        title: 'Purchase Orders',
        subtitle: 'Procurement & goods receipt',
        icon: Icons.shopping_bag_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/purchases',
      ),
      CommandResultItem(
        title: 'Finance & Accounting',
        subtitle: 'Ledgers, receivables & payables',
        icon: Icons.account_balance_wallet_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/accounting',
      ),
      CommandResultItem(
        title: 'HR & Attendance',
        subtitle: 'Employees, leave & payroll',
        icon: Icons.badge_outlined,
        type: CommandResultType.navigation,
        routeOrId: '/hr',
      ),
    ];

    if (query.isEmpty) {
      results.addAll(navigationActions);
    } else {
      // Filter actions
      for (var action in navigationActions) {
        if (action.title.toLowerCase().contains(query) || action.subtitle.toLowerCase().contains(query)) {
          results.add(action);
        }
      }

      // Filter products
      for (var p in erp.products) {
        if (p.name.toLowerCase().contains(query) || p.sku.toLowerCase().contains(query) || p.category.toLowerCase().contains(query)) {
          results.add(CommandResultItem(
            title: p.name,
            subtitle: '${p.sku} • Stock: ${p.currentStock} ${p.unit} • ₹${p.sellingPrice.toStringAsFixed(0)}',
            icon: Icons.inventory_2_rounded,
            type: CommandResultType.product,
            routeOrId: '/products',
          ));
        }
      }

      // Filter customers
      for (var c in erp.customers) {
        if (c.name.toLowerCase().contains(query) || c.phone.contains(query) || c.company.toLowerCase().contains(query)) {
          results.add(CommandResultItem(
            title: c.name,
            subtitle: '${c.phone} • ${c.tier} • Purchases: ₹${c.totalPurchases.toStringAsFixed(0)}',
            icon: Icons.person_outline_rounded,
            type: CommandResultType.customer,
            routeOrId: '/customers',
          ));
        }
      }

      // Filter Invoices
      for (var inv in erp.invoices) {
        if (inv.invoiceNumber.toLowerCase().contains(query) || inv.customerName.toLowerCase().contains(query)) {
          results.add(CommandResultItem(
            title: '${inv.invoiceNumber} — ${inv.customerName}',
            subtitle: '₹${inv.grandTotal.toStringAsFixed(0)} • ${inv.paymentStatus.label}',
            icon: Icons.receipt_long_rounded,
            type: CommandResultType.invoice,
            routeOrId: '/sales',
          ));
        }
      }
    }

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () => palette.close(),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),

        // Palette Dialog
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 600,
            margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: AppTokens.borderRadiusLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: AppTokens.shadowLg,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Type to search products, customers, invoices, or shortcuts...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) => palette.setQuery(val),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardHoverLight,
                            borderRadius: AppTokens.borderRadiusSm,
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Text(
                            'ESC',
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
                  Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

                  // Results List
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 380),
                    child: results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No matching results found for "${palette.query}"',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: results.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 2),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                    borderRadius: AppTokens.borderRadiusSm,
                                  ),
                                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                                ),
                                title: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                subtitle: Text(
                                  item.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                                onTap: () {
                                  palette.close();
                                  if (item.onExecute != null) {
                                    item.onExecute!();
                                  } else {
                                    context.go(item.routeOrId);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
