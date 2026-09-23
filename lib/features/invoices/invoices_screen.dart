import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../models/sales_model.dart';
import '../../providers/erp_provider.dart';
import 'invoice_detail_sheet.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final query = _searchController.text.toLowerCase();
    final filteredInvoices = erp.invoices.where((inv) {
      final matchesQuery = query.isEmpty ||
          inv.invoiceNumber.toLowerCase().contains(query) ||
          inv.customerName.toLowerCase().contains(query) ||
          inv.customerPhone.contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'Paid') return inv.paymentStatus == PaymentStatus.paid;
      if (_selectedFilter == 'Partial') return inv.paymentStatus == PaymentStatus.partial;
      if (_selectedFilter == 'Pending') return inv.paymentStatus == PaymentStatus.unpaid;
      if (_selectedFilter == 'Overdue') return inv.paymentStatus == PaymentStatus.overdue;
      if (_selectedFilter == 'Refunded') return inv.paymentStatus == PaymentStatus.refunded;

      return true;
    }).toList();


    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header & Search section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              'Invoices & Billing',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${erp.invoices.length} total invoices issued',
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
                      const SizedBox(width: 8),
                      AlRabeeButton(
                        label: 'New Invoice',
                        icon: Icons.add_rounded,
                        height: 38,
                        onPressed: () => context.go('/sales/new'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  AlRabeeSearchBar(
                    controller: _searchController,
                    hintText: 'Search by invoice #, customer name...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', erp.invoices.length),
                        _buildFilterChip('Paid', erp.invoices.where((i) => i.paymentStatus == PaymentStatus.paid).length),
                        _buildFilterChip('Partial', erp.invoices.where((i) => i.paymentStatus == PaymentStatus.partial).length),
                        _buildFilterChip('Pending', erp.invoices.where((i) => i.paymentStatus == PaymentStatus.unpaid).length),
                        _buildFilterChip('Overdue', erp.invoices.where((i) => i.paymentStatus == PaymentStatus.overdue).length),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Invoices List
          if (filteredInvoices.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AlRabeeEmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No invoices found',
                message: 'No invoices match your current search criteria or filter.',
                actionLabel: 'Create New Invoice',
                onAction: () => context.go('/sales/new'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final inv = filteredInvoices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildInvoiceCard(context, inv, isDark, erp),
                    );
                  },
                  childCount: filteredInvoices.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        selectedColor: AppColors.primary,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel inv, bool isDark, ErpProvider erp) {
    return AlRabeeCard(
      padding: const EdgeInsets.all(14),
      onTap: () => InvoiceDetailSheet.show(context, inv, erp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.pastelLavender,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_rounded,
                      size: 18,
                      color: AppColors.pastelLavenderIcon,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.invoiceNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        Formatters.date(inv.invoiceDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusBadge(inv.paymentStatus),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inv.customerName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${inv.items.length} items (${inv.items.fold(0, (s, i) => s + i.quantity)} units)',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(inv.grandTotal),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (inv.balanceDue > 0)
                    Text(
                      'Due: ${Formatters.currency(inv.balanceDue)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    )
                  else
                    const Text(
                      'Paid in full',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return StatusBadge.success('PAID');
      case PaymentStatus.partial:
        return StatusBadge.warning('PARTIAL');
      case PaymentStatus.unpaid:
        return StatusBadge.error('PENDING');
      case PaymentStatus.overdue:
        return StatusBadge.error('OVERDUE');
      case PaymentStatus.refunded:
        return StatusBadge.neutral('REFUNDED');
    }
  }
}

