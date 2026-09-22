import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../models/customer_model.dart';
import '../../models/product_model.dart';
import '../../models/sales_model.dart';
import '../../providers/erp_provider.dart';

class PosNewSaleScreen extends StatefulWidget {
  const PosNewSaleScreen({super.key});

  @override
  State<PosNewSaleScreen> createState() => _PosNewSaleScreenState();
}

class _PosNewSaleScreenState extends State<PosNewSaleScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  CustomerModel? _selectedCustomer;
  final List<InvoiceItem> _cartItems = [];
  String _paymentMethod = 'UPI / GPay';
  final double _discountPercent = 0.0;

  @override
  void initState() {
    super.initState();
    final erp = context.read<ErpProvider>();
    if (erp.customers.isNotEmpty) {
      _selectedCustomer = erp.customers.first;
    }
  }

  void _addToCart(ProductModel product) {
    if (product.currentStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add ${product.name} — Item is Out of Stock!')),
      );
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      if (existing.quantity >= product.currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot exceed available stock of ${product.currentStock} ${product.unit}')),
        );
        return;
      }
      setState(() {
        _cartItems[existingIndex] = InvoiceItem(
          productId: existing.productId,
          productName: existing.productName,
          sku: existing.sku,
          quantity: existing.quantity + 1,
          unitPrice: existing.unitPrice,
          taxPercent: existing.taxPercent,
        );
      });
    } else {
      setState(() {
        _cartItems.add(
          InvoiceItem(
            productId: product.id,
            productName: product.name,
            sku: product.sku,
            quantity: 1,
            unitPrice: product.sellingPrice,
            taxPercent: product.taxRate,
          ),
        );
      });
    }
  }

  void _updateQuantity(int index, int delta) {
    final item = _cartItems[index];
    final erp = context.read<ErpProvider>();
    final product = erp.getProductById(item.productId);
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      setState(() => _cartItems.removeAt(index));
    } else if (product != null && newQty > product.currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max available stock is ${product.currentStock}')),
      );
    } else {
      setState(() {
        _cartItems[index] = InvoiceItem(
          productId: item.productId,
          productName: item.productName,
          sku: item.sku,
          quantity: newQty,
          unitPrice: item.unitPrice,
          taxPercent: item.taxPercent,
        );
      });
    }
  }

  double get _subtotal => _cartItems.fold(0.0, (s, i) => s + i.lineSubtotal);
  double get _discountAmount => _subtotal * (_discountPercent / 100);
  double get _totalTax => _cartItems.fold(0.0, (s, i) => s + (i.taxableAmount * (i.taxPercent / 100)));
  double get _grandTotal => _subtotal - _discountAmount + _totalTax;

  void _completeSale() {
    if (_cartItems.isEmpty) return;
    if (_selectedCustomer == null) return;

    final erp = context.read<ErpProvider>();
    final invoiceNumber = 'INV-2026-${(100 + erp.invoices.length + 1).toString().padLeft(5, '0')}';

    final invoice = InvoiceModel(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      customerPhone: _selectedCustomer!.phone,
      customerEmail: _selectedCustomer!.email,
      customerAddress: _selectedCustomer!.address,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      items: List.from(_cartItems),
      discountAmount: _discountAmount,
      amountPaid: _grandTotal,
      paymentStatus: PaymentStatus.paid,
      salesStatus: SalesStatus.completed,
      salesPerson: 'Sales Executive',
      paymentMethod: _paymentMethod,
    );

    erp.createInvoice(invoice);
    context.go('/sales');
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var products = erp.products;
    if (_selectedCategory != 'All') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.sku.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/sales'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Point-of-Sale / Counter Billing',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Al Rabee Flagship Boutique Counter • Fast Barcode & SKU Dispatch',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              StatusBadge.success('POS System Online'),
            ],
          ),
          const SizedBox(height: 16),

          // Main Screen: Left Catalog & Right Cart
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Product Catalog Grid
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      // Search & Category Chips
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search or scan barcode (e.g. Ajwa, Mamra, Belgian)...',
                                prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: 20),
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          'All',
                          'Dates',
                          'Nuts',
                          'Dry Fruits',
                          'Chocolates',
                          'Juices',
                          'Imported Fruits',
                          'Packaged Delicacies',
                        ].map((cat) {
                          final isSel = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Grid of Products
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 4 : 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            final isOutOfStock = p.currentStock <= 0;

                            return InkWell(
                              onTap: isOutOfStock ? null : () => _addToCart(p),
                              borderRadius: AppTokens.borderRadiusLg,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : Colors.white,
                                  borderRadius: AppTokens.borderRadiusLg,
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                  boxShadow: isDark ? [] : AppTokens.shadowSm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                                          borderRadius: AppTokens.borderRadiusMd,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.inventory_2_rounded,
                                            size: 32,
                                            color: isOutOfStock ? Colors.grey : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: isOutOfStock ? Colors.grey : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Formatters.currency(p.sellingPrice),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: isOutOfStock ? Colors.grey : AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          '${p.currentStock} ${p.unit}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: isOutOfStock ? AppColors.error : AppColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right: Active Order Cart & Billing Panel
                Container(
                  width: isDesktop ? 380 : 320,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: AppTokens.borderRadiusLg,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark ? [] : AppTokens.shadowMd,
                  ),
                  child: Column(
                    children: [
                      // Customer Picker
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: DropdownButtonFormField<CustomerModel>(
                          initialValue: _selectedCustomer,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Customer Account',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          items: erp.customers.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text('${c.name} (${c.tier})', maxLines: 1),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCustomer = val);
                          },
                        ),
                      ),
                      Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

                      // Cart Items
                      Expanded(
                        child: _cartItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey.withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  const Text('Cart is empty', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Click items on the left to add', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _cartItems.length,
                              separatorBuilder: (_, _) => const Divider(height: 12),
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), maxLines: 1),
                                          Text('${Formatters.currency(item.unitPrice)} each', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                                          onPressed: () => _updateQuantity(index, -1),
                                        ),
                                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 18),
                                          onPressed: () => _updateQuantity(index, 1),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 65,
                                      child: Text(
                                        Formatters.currency(item.total),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      ),

                      // Totals & Checkout
                      Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:', style: TextStyle(fontSize: 12.5)),
                                Text(Formatters.currency(_subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('GST Tax:', style: TextStyle(fontSize: 12.5)),
                                Text(Formatters.currency(_totalTax), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Grand Total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text(
                                  Formatters.currency(_grandTotal),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Payment mode
                            DropdownButtonFormField<String>(
                              initialValue: _paymentMethod,
                              isDense: true,
                              decoration: const InputDecoration(labelText: 'Payment Method'),
                              items: const [
                                DropdownMenuItem(value: 'UPI / GPay', child: Text('UPI / GPay / QR Scanner')),
                                DropdownMenuItem(value: 'Credit Card', child: Text('Credit / Debit Card POS')),
                                DropdownMenuItem(value: 'Cash', child: Text('Cash Drawer')),
                                DropdownMenuItem(value: 'Corporate Credit', child: Text('Corporate Credit (30 Days)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _paymentMethod = val);
                              },
                            ),
                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: AppTokens.buttonHeightLg,
                              child: ElevatedButton.icon(
                                onPressed: _cartItems.isEmpty ? null : _completeSale,
                                icon: const Icon(Icons.check_circle_rounded, size: 20),
                                label: const Text('Complete Sale & Print Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
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
