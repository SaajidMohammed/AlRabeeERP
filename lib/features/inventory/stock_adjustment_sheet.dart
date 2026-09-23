import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';
import '../../models/product_model.dart';
import '../../providers/erp_provider.dart';

class StockAdjustmentSheet extends StatefulWidget {
  final ProductModel? preselectedProduct;
  final ErpProvider erp;

  const StockAdjustmentSheet({
    super.key,
    this.preselectedProduct,
    required this.erp,
  });

  static void show(BuildContext context, ErpProvider erp, {ProductModel? product}) {
    AlRabeeBottomSheet.show(
      context: context,
      title: 'Stock Adjustment',
      subtitle: 'Record stock count reconciliation or damages',
      child: StockAdjustmentSheet(preselectedProduct: product, erp: erp),
    );
  }

  @override
  State<StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<StockAdjustmentSheet> {
  late ProductModel _selectedProduct;
  String _adjustmentType = 'Increase'; // Increase or Decrease
  final TextEditingController _quantityController = TextEditingController(text: '10');
  final TextEditingController _reasonController = TextEditingController(text: 'Physical audit discrepancy / stock count');
  String _selectedReason = 'Audit Reconciliation';

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct ?? widget.erp.products.first;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      ToastService.showError('Invalid Quantity', message: 'Please enter a valid adjustment quantity.');
      return;
    }

    final adjustmentAmount = _adjustmentType == 'Increase' ? qty : -qty;
    final newStock = (_selectedProduct.currentStock + adjustmentAmount).clamp(0, 999999);
    widget.erp.adjustStock(
      _selectedProduct.id,
      newStock,
      _selectedReason,
      _selectedProduct.primaryWarehouse,
      'Super Admin',
    );

    Navigator.of(context).pop();

    ToastService.showSuccess(
      'Stock Adjusted Successfully',
      message: '${_selectedProduct.name}: ${_adjustmentType == "Increase" ? "+$qty" : "-$qty"} ${_selectedProduct.unit}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Product Selector Dropdown
        Text(
          'Target Product',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProduct.id,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              items: widget.erp.products.map((p) {
                return DropdownMenuItem(
                  value: p.id,
                  child: Row(
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${p.currentStock} ${p.unit})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() {
                    _selectedProduct = widget.erp.products.firstWhere((p) => p.id == id);
                  });
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Current Stock Info Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.primaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Available Stock:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${_selectedProduct.currentStock} ${_selectedProduct.unit}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Adjustment Type Toggle
        Text(
          'Adjustment Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: 'Increase (+)',
                icon: Icons.add_circle_outline_rounded,
                isSelected: _adjustmentType == 'Increase',
                selectedColor: AppColors.success,
                onTap: () => setState(() => _adjustmentType = 'Increase'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                label: 'Decrease (-)',
                icon: Icons.remove_circle_outline_rounded,
                isSelected: _adjustmentType == 'Decrease',
                selectedColor: AppColors.error,
                onTap: () => setState(() => _adjustmentType = 'Decrease'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Quantity Input
        AlRabeeTextField(
          controller: _quantityController,
          label: 'Adjustment Quantity (${_selectedProduct.unit})',
          hintText: 'e.g. 10',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.format_list_numbered_rounded,
        ),

        const SizedBox(height: 16),

        // Reason Dropdown
        Text(
          'Reason for Adjustment',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.2,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedReason,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              items: const [
                DropdownMenuItem(value: 'Audit Reconciliation', child: Text('Audit Reconciliation / Physical Count')),
                DropdownMenuItem(value: 'Damaged in Cold Storage', child: Text('Damaged in Cold Storage')),
                DropdownMenuItem(value: 'Expired Stock Written Off', child: Text('Expired Stock Written Off')),
                DropdownMenuItem(value: 'Supplier Return', child: Text('Supplier Return / Quality Rejection')),
                DropdownMenuItem(value: 'Sample / Promotional Tasting', child: Text('Sample / Promotional Tasting')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedReason = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Save Button
        AlRabeeButton(
          label: 'Save Stock Adjustment',
          icon: Icons.check_circle_outline_rounded,
          isFullWidth: true,
          height: 46,
          onPressed: _handleSave,
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? selectedColor.withValues(alpha: isDark ? 0.2 : 0.1)
          : (isDark ? AppColors.surfaceDark : Colors.white),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? selectedColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? selectedColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
