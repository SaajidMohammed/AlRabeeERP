import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/stat_card.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/accounting_model.dart';
import '../../providers/erp_provider.dart';

class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  void _showAddExpenseDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '15000');
    final partyCtrl = TextEditingController();
    String category = ExpenseCategory.coldChainStorage.label;
    String account = 'HDFC Flagship Current A/C';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Business Expense / Payment'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Expense Description *'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Expense Category'),
                    items: ExpenseCategory.values.map((c) {
                      return DropdownMenuItem(value: c.label, child: Text(c.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Amount (₹) *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: account,
                          decoration: const InputDecoration(labelText: 'Payment Account'),
                          items: const [
                            DropdownMenuItem(value: 'HDFC Flagship Current A/C', child: Text('HDFC Current A/C')),
                            DropdownMenuItem(value: 'ICICI Export-Import A/C', child: Text('ICICI Export A/C')),
                            DropdownMenuItem(value: 'Cash Drawer Flagship', child: Text('Cash Drawer')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => account = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: partyCtrl,
                    decoration: const InputDecoration(labelText: 'Paid To / Vendor Name'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;
                final amount = double.tryParse(amountCtrl.text) ?? 1000.0;
                final txn = TransactionRecord(
                  id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
                  referenceNumber: 'TXN-2026-${DateTime.now().minute}${DateTime.now().second}',
                  type: TransactionType.expense,
                  category: category,
                  title: titleCtrl.text,
                  amount: amount,
                  paymentAccount: account,
                  partyName: partyCtrl.text.isNotEmpty ? partyCtrl.text : 'Vendor',
                  date: DateTime.now(),
                );

                context.read<ErpProvider>().addTransaction(txn);
                Navigator.of(ctx).pop();
              },
              child: const Text('Save Expense'),
            ),
          ],
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
                    'Finance & Accounting',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Track showroom revenue, import customs, cold storage overheads, receivables & payables',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddExpenseDialog(context),
                icon: const Icon(Icons.add_card_rounded, size: 18),
                label: const Text('Record Expense'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Finance KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final cards = [
                StatCard(
                  title: 'Total Receivables',
                  value: Formatters.compactCurrency(erp.totalReceivables),
                  subtitle: 'from corporate VIPs',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.success,
                ),
                StatCard(
                  title: 'Total Payables',
                  value: Formatters.compactCurrency(erp.totalPayables),
                  subtitle: 'supplier import bills',
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.berryRose,
                ),
                StatCard(
                  title: 'Net Profit Margin',
                  value: Formatters.compactCurrency(erp.netProfit),
                  subtitle: 'est. 62% markup',
                  icon: Icons.pie_chart_rounded,
                  iconColor: AppColors.saffronGold,
                ),
              ];

              if (isMobile) {
                return Column(
                  children: cards
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: c,
                          ))
                      .toList(),
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[2]),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Transactions Table
          SizedBox(
            height: 560,
            child: ErpDataTable<TransactionRecord>(
              items: erp.transactions,
              searchPlaceholder: 'Search transaction #, party, title, or category...',
              searchMatcher: (t, q) =>
                  t.referenceNumber.toLowerCase().contains(q) ||
                  t.title.toLowerCase().contains(q) ||
                  t.partyName.toLowerCase().contains(q) ||
                  t.category.toLowerCase().contains(q),
              columns: [
                ErpTableColumn(
                  title: 'Reference & Date',
                  cellBuilder: (t) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.referenceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(Formatters.dateTime(t.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                ErpTableColumn(
                  title: 'Description',
                  cellBuilder: (t) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${t.category} • ${t.partyName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                ErpTableColumn(
                  title: 'Account',
                  cellBuilder: (t) => Text(t.paymentAccount, style: const TextStyle(fontSize: 12)),
                ),
                ErpTableColumn(
                  title: 'Amount',
                  isNumeric: true,
                  cellBuilder: (t) {
                    final isPositive = t.type.multiplier > 0;
                    return Text(
                      '${isPositive ? "+" : "-"}${Formatters.currency(t.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isPositive ? AppColors.success : AppColors.berryRose,
                      ),
                    );
                  },
                  comparator: (a, b) => a.amount.compareTo(b.amount),
                ),
                ErpTableColumn(
                  title: 'Status',
                  cellBuilder: (t) => StatusBadge.success(t.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
