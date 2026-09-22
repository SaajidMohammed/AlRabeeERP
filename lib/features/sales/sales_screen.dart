import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/sales_model.dart';
import '../../providers/erp_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  int _tabIndex = 0;

  void _showInvoiceDialog(BuildContext context, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Printable Invoice Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppTokens.borderRadiusSm,
                              ),
                              child: const Center(
                                child: Text('الربيع', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('AL RABEE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Premium Imported Dates & Gourmet Delicacies', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const Text('Flagship Showroom, Bandra West, Mumbai • GSTIN: 27AABCA1234F1Z1', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TAX INVOICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(Formatters.dateTime(invoice.invoiceDate), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Bill To
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('BILLED TO:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(invoice.customerPhone, style: const TextStyle(fontSize: 12)),
                        if (invoice.customerAddress.isNotEmpty)
                          Text(invoice.customerAddress, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('PAYMENT STATUS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        if (invoice.paymentStatus == PaymentStatus.paid)
                          StatusBadge.success('PAID IN FULL')
                        else if (invoice.paymentStatus == PaymentStatus.partial)
                          StatusBadge.warning('PARTIALLY PAID')
                        else
                          StatusBadge.error('UNPAID'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Items Table
                Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    bottom: const BorderSide(color: Colors.grey),
                  ),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('ITEM / SKU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('QTY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('RATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('TOTAL', textAlign: TextAlign.end, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    ...invoice.items.map((item) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text(item.sku, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text('${item.quantity}')),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(Formatters.currency(item.unitPrice))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(Formatters.currency(item.total), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Totals summary
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                            Text(Formatters.currency(invoice.subtotal)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (GST):', style: TextStyle(fontSize: 12)),
                            Text(Formatters.currency(invoice.totalTax)),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              Formatters.currency(invoice.grandTotal),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount Paid:', style: TextStyle(fontSize: 12)),
                            Text(Formatters.currency(invoice.amountPaid)),
                          ],
                        ),
                        if (invoice.balanceDue > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Balance Due:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                              Text(Formatters.currency(invoice.balanceDue), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: const Text('Print Tax Invoice'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Sending invoice to thermal/receipt printer...')),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
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
                    'Sales & Invoices',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage counter sales, corporate invoicing, payments & quotations',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/sales/new'),
                icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                label: const Text('POS / New Sale'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('Tax Invoices (${erp.invoices.length})'),
                selected: _tabIndex == 0,
                onSelected: (_) => setState(() => _tabIndex = 0),
              ),
              ChoiceChip(
                label: Text('Quotations (${erp.quotations.length})'),
                selected: _tabIndex == 1,
                onSelected: (_) => setState(() => _tabIndex = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content Table
          SizedBox(
            height: 560,
            child: _tabIndex == 0
                ? ErpDataTable<InvoiceModel>(
                    items: erp.invoices,
                    searchPlaceholder: 'Search invoice #, customer name, phone...',
                    searchMatcher: (inv, q) =>
                        inv.invoiceNumber.toLowerCase().contains(q) ||
                        inv.customerName.toLowerCase().contains(q) ||
                        inv.customerPhone.contains(q),
                    onRowTap: (inv) => _showInvoiceDialog(context, inv),
                    columns: [
                      ErpTableColumn(
                        title: 'Invoice Details',
                        cellBuilder: (inv) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(Formatters.dateTime(inv.invoiceDate), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        comparator: (a, b) => a.invoiceDate.compareTo(b.invoiceDate),
                      ),
                      ErpTableColumn(
                        title: 'Customer',
                        cellBuilder: (inv) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(inv.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(inv.customerPhone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Items',
                        cellBuilder: (inv) => Text('${inv.items.length} items (${inv.items.fold(0, (s, i) => s + i.quantity)} units)'),
                      ),
                      ErpTableColumn(
                        title: 'Grand Total',
                        isNumeric: true,
                        cellBuilder: (inv) => Text(
                          Formatters.currency(inv.grandTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        comparator: (a, b) => a.grandTotal.compareTo(b.grandTotal),
                      ),
                      ErpTableColumn(
                        title: 'Payment Status',
                        cellBuilder: (inv) {
                          if (inv.paymentStatus == PaymentStatus.paid) return StatusBadge.success('Paid');
                          if (inv.paymentStatus == PaymentStatus.partial) return StatusBadge.warning('Partial');
                          return StatusBadge.error('Unpaid');
                        },
                      ),
                      ErpTableColumn(
                        title: 'Action',
                        cellBuilder: (inv) => IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          tooltip: 'View Printable Invoice',
                          onPressed: () => _showInvoiceDialog(context, inv),
                        ),
                      ),
                    ],
                  )
                : ErpDataTable<QuotationModel>(
                    items: erp.quotations,
                    searchPlaceholder: 'Search quotation #, customer...',
                    searchMatcher: (qtn, q) =>
                        qtn.quotationNumber.toLowerCase().contains(q) ||
                        qtn.customerName.toLowerCase().contains(q),
                    columns: [
                      ErpTableColumn(
                        title: 'Quotation #',
                        cellBuilder: (q) => Text(q.quotationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ErpTableColumn(
                        title: 'Customer',
                        cellBuilder: (q) => Text(q.customerName),
                      ),
                      ErpTableColumn(
                        title: 'Valid Until',
                        cellBuilder: (q) => Text(Formatters.date(q.validUntil)),
                      ),
                      ErpTableColumn(
                        title: 'Total Value',
                        isNumeric: true,
                        cellBuilder: (q) => Text(Formatters.currency(q.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ErpTableColumn(
                        title: 'Status',
                        cellBuilder: (q) => StatusBadge.gold(q.status),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
