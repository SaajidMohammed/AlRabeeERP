import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/product_model.dart';
import '../../providers/erp_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';
  String _selectedStockStatus = 'All';

  void _showAddEditProductDialog(BuildContext context, [ProductModel? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final skuCtrl = TextEditingController(text: existing?.sku ?? 'ALR-');
    final barcodeCtrl = TextEditingController(text: existing?.barcode ?? '890123400');
    final brandCtrl = TextEditingController(text: existing?.brand ?? 'Al Rabee Select');
    final originCtrl = TextEditingController(text: existing?.origin ?? 'Saudi Arabia');
    final purchasePriceCtrl = TextEditingController(text: existing?.purchasePrice.toString() ?? '500');
    final sellingPriceCtrl = TextEditingController(text: existing?.sellingPrice.toString() ?? '850');
    final mrpCtrl = TextEditingController(text: existing?.mrp.toString() ?? '950');
    final stockCtrl = TextEditingController(text: existing?.currentStock.toString() ?? '50');
    final minStockCtrl = TextEditingController(text: existing?.minimumStock.toString() ?? '15');
    String category = existing?.category ?? 'Dates';
    String unit = existing?.unit ?? 'kg';
    String warehouse = existing?.primaryWarehouse ?? 'Main Flagship Showroom & Storage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Product SKU' : 'Add New Delicacy Product'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Product Full Name *'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const [
                            DropdownMenuItem(value: 'Dates', child: Text('Dates')),
                            DropdownMenuItem(value: 'Nuts', child: Text('Nuts')),
                            DropdownMenuItem(value: 'Dry Fruits', child: Text('Dry Fruits')),
                            DropdownMenuItem(value: 'Chocolates', child: Text('Chocolates')),
                            DropdownMenuItem(value: 'Juices', child: Text('Juices')),
                            DropdownMenuItem(value: 'Imported Fruits', child: Text('Imported Fruits')),
                            DropdownMenuItem(value: 'Packaged Delicacies', child: Text('Packaged Delicacies')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => category = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: unit,
                          decoration: const InputDecoration(labelText: 'Unit of Measure'),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg (Kilogram)')),
                            DropdownMenuItem(value: 'box', child: Text('box (Gift Box)')),
                            DropdownMenuItem(value: 'bottle', child: Text('bottle')),
                            DropdownMenuItem(value: 'pack', child: Text('pack')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => unit = val);
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
                          controller: skuCtrl,
                          decoration: const InputDecoration(labelText: 'SKU Code *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: barcodeCtrl,
                          decoration: const InputDecoration(labelText: 'Barcode Number'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: brandCtrl,
                          decoration: const InputDecoration(labelText: 'Brand / Reserve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: originCtrl,
                          decoration: const InputDecoration(labelText: 'Country of Origin'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: purchasePriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cost Price (₹) *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: sellingPriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Selling Price (₹) *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: mrpCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'MRP (₹)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Initial Stock Count'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minStockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min Reorder Threshold'),
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
                if (nameCtrl.text.isEmpty || skuCtrl.text.isEmpty) return;
                final product = ProductModel(
                  id: existing?.id ?? 'PRD-${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text,
                  sku: skuCtrl.text,
                  barcode: barcodeCtrl.text,
                  category: category,
                  brand: brandCtrl.text,
                  origin: originCtrl.text,
                  unit: unit,
                  purchasePrice: double.tryParse(purchasePriceCtrl.text) ?? 500.0,
                  sellingPrice: double.tryParse(sellingPriceCtrl.text) ?? 850.0,
                  mrp: double.tryParse(mrpCtrl.text) ?? 950.0,
                  currentStock: int.tryParse(stockCtrl.text) ?? 50,
                  minimumStock: int.tryParse(minStockCtrl.text) ?? 15,
                  primaryWarehouse: warehouse,
                  rackLocation: 'Aisle 1 - Section A',
                  expiryDate: existing?.expiryDate ?? DateTime.now().add(const Duration(days: 300)),
                );

                context.read<ErpProvider>().saveProduct(product, isNew: !isEditing);
                Navigator.of(ctx).pop();
              },
              child: Text(isEditing ? 'Save Changes' : 'Add to Catalog'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustStockDialog(BuildContext context, ProductModel product) {
    final qtyCtrl = TextEditingController(text: product.currentStock.toString());
    final reasonCtrl = TextEditingController(text: 'Physical shelf count audit');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adjust Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current recorded stock: ${product.currentStock} ${product.unit}'),
            const SizedBox(height: 14),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'New Actual Stock Count *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason for Adjustment'),
            ),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(qtyCtrl.text);
              if (newQty != null) {
                context.read<ErpProvider>().adjustStock(
                      product.id,
                      newQty,
                      reasonCtrl.text,
                      product.primaryWarehouse,
                      'Admin',
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();

    var filtered = erp.products;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }
    if (_selectedStockStatus != 'All') {
      if (_selectedStockStatus == 'Healthy') {
        filtered = filtered.where((p) => p.stockStatus == StockStatus.healthy).toList();
      } else if (_selectedStockStatus == 'Low Stock') {
        filtered = filtered.where((p) => p.stockStatus == StockStatus.lowStock).toList();
      } else if (_selectedStockStatus == 'Out of Stock') {
        filtered = filtered.where((p) => p.stockStatus == StockStatus.outOfStock).toList();
      }
    }

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
                    'Products & Master Catalog',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage inventory SKUs, batch pricing, origins & stock thresholds',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditProductDialog(context),
                icon: const Icon(Icons.add_box_rounded, size: 18),
                label: const Text('Add Product SKU'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: ErpDataTable<ProductModel>(
              items: filtered,
              searchPlaceholder: 'Search product name, SKU, brand, or origin...',
              searchMatcher: (p, query) =>
                  p.name.toLowerCase().contains(query) ||
                  p.sku.toLowerCase().contains(query) ||
                  p.brand.toLowerCase().contains(query) ||
                  p.origin.toLowerCase().contains(query),
              trailingHeaderActions: Wrap(
                spacing: 12,
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Categories')),
                      DropdownMenuItem(value: 'Dates', child: Text('Dates')),
                      DropdownMenuItem(value: 'Nuts', child: Text('Nuts')),
                      DropdownMenuItem(value: 'Dry Fruits', child: Text('Dry Fruits')),
                      DropdownMenuItem(value: 'Chocolates', child: Text('Chocolates')),
                      DropdownMenuItem(value: 'Juices', child: Text('Juices')),
                      DropdownMenuItem(value: 'Imported Fruits', child: Text('Imported Fruits')),
                      DropdownMenuItem(value: 'Packaged Delicacies', child: Text('Packaged Delicacies')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedStockStatus,
                    isDense: true,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Stock Status')),
                      DropdownMenuItem(value: 'Healthy', child: Text('Healthy')),
                      DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock Alert')),
                      DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStockStatus = val);
                    },
                  ),
                ],
              ),
              columns: [
                ErpTableColumn(
                  title: 'Product Details',
                  cellBuilder: (p) => Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusSm,
                        ),
                        child: const Icon(Icons.inventory_2_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${p.sku} • ${p.brand} • ${p.origin}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  comparator: (a, b) => a.name.compareTo(b.name),
                ),
                ErpTableColumn(
                  title: 'Category',
                  cellBuilder: (p) => StatusBadge.neutral(p.category),
                ),
                ErpTableColumn(
                  title: 'Selling Price',
                  isNumeric: true,
                  cellBuilder: (p) => Text(
                    '${Formatters.currency(p.sellingPrice)} / ${p.unit}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  comparator: (a, b) => a.sellingPrice.compareTo(b.sellingPrice),
                ),
                ErpTableColumn(
                  title: 'Stock Level',
                  cellBuilder: (p) => Row(
                    children: [
                      Text(
                        '${p.currentStock} ${p.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (p.stockStatus == StockStatus.healthy)
                        StatusBadge.success('Healthy')
                      else if (p.stockStatus == StockStatus.lowStock)
                        StatusBadge.warning('Low Stock')
                      else
                        StatusBadge.error('Out of Stock'),
                    ],
                  ),
                  comparator: (a, b) => a.currentStock.compareTo(b.currentStock),
                ),
                ErpTableColumn(
                  title: 'Actions',
                  cellBuilder: (p) => Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                        tooltip: 'Adjust Stock Count',
                        onPressed: () => _showAdjustStockDialog(context, p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        tooltip: 'Edit SKU',
                        onPressed: () => _showAddEditProductDialog(context, p),
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
