import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';

import '../../models/sales_model.dart';
import '../../providers/erp_provider.dart';

class InvoiceDetailSheet extends StatelessWidget {
  final InvoiceModel invoice;
  final ErpProvider erp;

  const InvoiceDetailSheet({
    super.key,
    required this.invoice,
    required this.erp,
  });

  static void show(BuildContext context, InvoiceModel invoice, ErpProvider erp) {
    AlRabeeBottomSheet.show(
      context: context,
      title: invoice.invoiceNumber,
      subtitle: 'Tax Invoice • ${Formatters.date(invoice.invoiceDate)}',
      child: InvoiceDetailSheet(invoice: invoice, erp: erp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currency(invoice.grandTotal),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildPaymentBadge(invoice.paymentStatus),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Customer Info Card
        AlRabeeCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.pastelSky,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppColors.pastelSkyIcon),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          invoice.customerPhone.isNotEmpty ? invoice.customerPhone : 'No contact provided',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (invoice.customerAddress.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        invoice.customerAddress,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Itemized Product List
        Text(
          'Purchased Items (${invoice.items.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 10),

        ...invoice.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.pastelLavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.pastelLavenderIcon),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        '${item.quantity} units × ${Formatters.currency(item.unitPrice)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.currency(item.total),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),

        // Calculation Breakdown
        AlRabeeCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', Formatters.currency(invoice.subtotal), isDark),
              const SizedBox(height: 6),
              if (invoice.discountAmount > 0) ...[
                _buildSummaryRow('Discount', '- ${Formatters.currency(invoice.discountAmount)}', isDark, isGreen: true),
                const SizedBox(height: 6),
              ],
              _buildSummaryRow('Tax (GST 18%)', Formatters.currency(invoice.totalTax), isDark),
              const Divider(height: 16),
              _buildSummaryRow('Grand Total', Formatters.currency(invoice.grandTotal), isDark, isBold: true),
              const SizedBox(height: 6),
              _buildSummaryRow('Paid Amount', Formatters.currency(invoice.amountPaid), isDark),
              if (invoice.balanceDue > 0) ...[
                const SizedBox(height: 6),
                _buildSummaryRow('Balance Due', Formatters.currency(invoice.balanceDue), isDark, isRed: true, isBold: true),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Buttons Row (Print, Share, Download, Record Payment)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 38),
              ),
              icon: const Icon(Icons.payment_rounded, size: 16),
              label: const Text('Record Payment'),
              onPressed: () {
                Navigator.of(context).pop();
                ToastService.showSuccess(
                  'Payment Recorded',
                  message: '₹${invoice.balanceDue > 0 ? invoice.balanceDue.toStringAsFixed(0) : "0"} updated for ${invoice.invoiceNumber}',
                );
              },
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 38),
              ),
              icon: const Icon(Icons.print_rounded, size: 16),
              label: const Text('Print'),
              onPressed: () {
                ToastService.showInfo('Printing Invoice', message: 'Sending ${invoice.invoiceNumber} to printer...');
              },
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 38),
              ),
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share'),
              onPressed: () {
                ToastService.showSuccess('Share Link Generated', message: 'Invoice link copied to clipboard.');
              },
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 38),
              ),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download PDF'),
              onPressed: () {
                ToastService.showSuccess('PDF Downloaded', message: '${invoice.invoiceNumber}.pdf saved to downloads');
              },
            ),
          ],
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPaymentBadge(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return StatusBadge.success('PAID');
      case PaymentStatus.partial:
        return StatusBadge.warning('PARTIALLY PAID');
      case PaymentStatus.unpaid:
        return StatusBadge.error('PENDING');
      case PaymentStatus.overdue:
        return StatusBadge.error('OVERDUE');
      case PaymentStatus.refunded:
        return StatusBadge.neutral('REFUNDED');
    }
  }


  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isBold = false, bool isGreen = false, bool isRed = false}) {
    Color textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    if (isGreen) textColor = AppColors.success;
    if (isRed) textColor = AppColors.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 12.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
