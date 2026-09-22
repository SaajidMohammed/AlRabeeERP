import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/purchase_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/erp_provider.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  int _tabIndex = 0;

  void _showNewPoDialog(BuildContext context) {
    final erp = context.read<ErpProvider>();
    SupplierModel? selectedSupplier = erp.suppliers.first;
    final poNumber = 'PO-2026-${(100 + erp.purchaseOrders.length + 1).toString().padLeft(4, '0')}';
    final qtyCtrl = TextEditingController(text: '100');
    final priceCtrl = TextEditingController(text: '1650');
    String selectedProductId = erp.products.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Create Purchase Order ($poNumber)'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SupplierModel>(
                    initialValue: selectedSupplier,
                    decoration: const InputDecoration(labelText: 'Select Supplier *'),
                    items: erp.suppliers.map((s) {
                      return DropdownMenuItem(value: s, child: Text('${s.name} (${s.country})', maxLines: 1));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedSupplier = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProductId,
                    decoration: const InputDecoration(labelText: 'Product / Delicacy SKU *'),
                    items: erp.products.map((p) {
                      return DropdownMenuItem(value: p.id, child: Text('${p.name} (${p.unit})', maxLines: 1));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedProductId = val;
                          final prod = erp.getProductById(val);
                          if (prod != null) {
                            priceCtrl.text = prod.purchasePrice.toString();
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Order Quantity *'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cost Rate (₹) *'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final prod = erp.getProductById(selectedProductId);
                if (prod == null || selectedSupplier == null) return;
                final qty = int.tryParse(qtyCtrl.text) ?? 50;
                final price = double.tryParse(priceCtrl.text) ?? prod.purchasePrice;

                final po = PurchaseOrderModel(
                  id: 'PO-${DateTime.now().millisecondsSinceEpoch}',
                  poNumber: poNumber,
                  supplierId: selectedSupplier!.id,
                  supplierName: selectedSupplier!.name,
                  supplierCountry: selectedSupplier!.country,
                  orderDate: DateTime.now(),
                  expectedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
                  destinationWarehouse: 'Central Cold Chain Logistics Hub',
                  requestedBy: 'Procurement Officer',
                  status: PurchaseStatus.ordered,
                  items: [
                    PurchaseItem(
                      productId: prod.id,
                      productName: prod.name,
                      sku: prod.sku,
                      quantity: qty,
                      unitCost: price,
                    ),
                  ],
                );

                erp.createPurchaseOrder(po);
                Navigator.of(ctx).pop();
              },
              child: const Text('Submit Order'),
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
                    'Purchases & International Procurement',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Import consignments from Saudi Arabia, Iran, Turkey, Belgium & local producers',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showNewPoDialog(context),
                icon: const Icon(Icons.post_add_rounded, size: 18),
                label: const Text('Create Purchase Order'),
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
                label: Text('Purchase Orders (${erp.purchaseOrders.length})'),
                selected: _tabIndex == 0,
                onSelected: (_) => setState(() => _tabIndex = 0),
              ),
              ChoiceChip(
                label: Text('Suppliers & Importers (${erp.suppliers.length})'),
                selected: _tabIndex == 1,
                onSelected: (_) => setState(() => _tabIndex = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table Content
          SizedBox(
            height: 560,
            child: _tabIndex == 0
                ? ErpDataTable<PurchaseOrderModel>(
                    items: erp.purchaseOrders,
                    searchPlaceholder: 'Search PO #, supplier, origin...',
                    searchMatcher: (po, q) =>
                        po.poNumber.toLowerCase().contains(q) ||
                        po.supplierName.toLowerCase().contains(q) ||
                        po.supplierCountry.toLowerCase().contains(q),
                    columns: [
                      ErpTableColumn(
                        title: 'PO Number & Date',
                        cellBuilder: (po) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(po.poNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(Formatters.date(po.orderDate), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Supplier & Country',
                        cellBuilder: (po) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(po.supplierName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(po.supplierCountry, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Destination',
                        cellBuilder: (po) => Text(po.destinationWarehouse, style: const TextStyle(fontSize: 12)),
                      ),
                      ErpTableColumn(
                        title: 'Order Value',
                        isNumeric: true,
                        cellBuilder: (po) => Text(
                          Formatters.currency(po.grandTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        comparator: (a, b) => a.grandTotal.compareTo(b.grandTotal),
                      ),
                      ErpTableColumn(
                        title: 'Status',
                        cellBuilder: (po) {
                          if (po.status == PurchaseStatus.completed) return StatusBadge.success('Completed');
                          if (po.status == PurchaseStatus.ordered) return StatusBadge.info('Ordered / Transit');
                          return StatusBadge.warning(po.status.label);
                        },
                      ),
                      ErpTableColumn(
                        title: 'Actions',
                        cellBuilder: (po) => po.status == PurchaseStatus.ordered
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text('Receive Goods', style: TextStyle(fontSize: 11)),
                                onPressed: () => erp.receiveGoods(po.id, 'Inventory Inspector'),
                              )
                            : StatusBadge.success('Stock Synced'),
                      ),
                    ],
                  )
                : ErpDataTable<SupplierModel>(
                    items: erp.suppliers,
                    searchPlaceholder: 'Search supplier name, country, specialty...',
                    searchMatcher: (s, q) =>
                        s.name.toLowerCase().contains(q) ||
                        s.country.toLowerCase().contains(q) ||
                        s.categorySpecialty.toLowerCase().contains(q),
                    columns: [
                      ErpTableColumn(
                        title: 'Supplier Name',
                        cellBuilder: (s) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${s.contactPerson} • ${s.country}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Specialty Category',
                        cellBuilder: (s) => StatusBadge.gold(s.categorySpecialty),
                      ),
                      ErpTableColumn(
                        title: 'Total Purchased',
                        isNumeric: true,
                        cellBuilder: (s) => Text(Formatters.currency(s.totalPurchased), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ErpTableColumn(
                        title: 'Outstanding Payable',
                        isNumeric: true,
                        cellBuilder: (s) => Text(
                          Formatters.currency(s.outstandingPayable),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: s.outstandingPayable > 0 ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Orders',
                        cellBuilder: (s) => Text('${s.totalOrders} Orders'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
