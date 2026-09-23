import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(ProductModel product) {
    if (product.currentStock <= 0) {
      ToastService.showError('Out of Stock', message: 'Cannot add ${product.name} — 0 available');
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      if (existing.quantity >= product.currentStock) {
        ToastService.showWarning('Max Stock Reached', message: 'Only ${product.currentStock} ${product.unit} available');
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
      ToastService.showSuccess('Cart Updated', message: '${product.name} (x${existing.quantity + 1})');
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
      ToastService.showSuccess('Added to Cart', message: '${product.name} added to current sale');
    }
  }

  void _updateQuantity(int index, int delta) {
    final item = _cartItems[index];
    final erp = context.read<ErpProvider>();
    final product = erp.getProductById(item.productId);
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      setState(() => _cartItems.removeAt(index));
      ToastService.showInfo('Item removed from cart');
    } else if (product != null && newQty > product.currentStock) {
      ToastService.showWarning('Max Stock Reached', message: 'Only ${product.currentStock} ${product.unit} available');
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
    if (_cartItems.isEmpty) {
      ToastService.showWarning('Empty Cart', message: 'Please add at least one product to the cart');
      return;
    }
    if (_selectedCustomer == null) {
      ToastService.showWarning('No Customer Selected', message: 'Please select a customer account');
      return;
    }

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
    ToastService.showSuccess('Sale Completed & Paid', message: 'Invoice $invoiceNumber generated successfully');
    context.go('/invoices');
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 20 : 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 22),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              context.pop();
                            } else {
                              context.go('/invoices');
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POS Counter Billing',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 17,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  letterSpacing: -0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Al Rabee Flagship Boutique Counter • Fast SKU Dispatch',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isDesktop)
                    StatusBadge.success('POS System Online')
                  else if (_cartItems.isNotEmpty)
                    Badge(
                      label: Text('${_cartItems.length}'),
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                        onPressed: () => _showMobileCartSheet(context, isDark, erp),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Main Body (Desktop: Side-by-side | Mobile: Full catalog + Bottom Bar)
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: Product Catalog Grid
                          Expanded(
                            flex: 7,
                            child: _buildCatalogSection(products, isDark, isDesktop),
                          ),
                          const SizedBox(width: 16),

                          // Right: Active Cart Panel
                          Container(
                            width: 380,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                              boxShadow: isDark ? [] : AppTokens.shadowMd,
                            ),
                            child: _buildCartPanelContent(isDark, erp),
                          ),
                        ],
                      )
                    : _buildCatalogSection(products, isDark, isDesktop),
              ),

              // 3. Mobile Floating Bottom Bar
              if (!isDesktop && _cartItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => _showMobileCartSheet(context, isDark, erp),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_cartItems.length} items in cart',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      Formatters.currency(_grandTotal),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Row(
                              children: [
                                Text(
                                  'View & Checkout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogSection(List<ProductModel> products, bool isDark, bool isDesktop) {
    const categories = [
      'All',
      'Dates',
      'Nuts',
      'Dry Fruits',
      'Chocolates',
      'Juices',
      'Imported Fruits',
      'Packaged Delicacies',
    ];

    return Column(
      children: [
        // Search Bar
        AlRabeeSearchBar(
          controller: _searchController,
          hintText: 'Search SKU or product name (e.g. Ajwa, Mamra)...',
          onChanged: (val) => setState(() => _searchQuery = val),
          onClear: () => setState(() => _searchQuery = ''),
        ),
        const SizedBox(height: 10),

        // Categories Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSel,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    color: isSel ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Grid of Products
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: AlRabeeEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No products found',
                    message: 'No items match "$_searchQuery" in category "$_selectedCategory"',
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isDesktop ? 1.05 : 0.88,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final isOutOfStock = p.currentStock <= 0;

                    return AlRabeeCard(
                      padding: const EdgeInsets.all(10),
                      onTap: isOutOfStock ? null : () => _addToCart(p),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.inventory_2_rounded,
                                  size: 28,
                                  color: isOutOfStock ? Colors.grey : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isOutOfStock ? Colors.grey : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Formatters.currency(p.sellingPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: isOutOfStock ? Colors.grey : AppColors.primary,
                                ),
                              ),
                              Text(
                                '${p.currentStock} ${p.unit}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isOutOfStock ? AppColors.error : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCartPanelContent(bool isDark, ErpProvider erp) {
    return Column(
      children: [
        // Customer Picker
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<CustomerModel>(
            initialValue: _selectedCustomer,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Customer Account',
              prefixIcon: Icon(Icons.person_outline, size: 18),
              isDense: true,
            ),
            items: erp.customers.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text('${c.name} (${c.tier})', maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      Icon(Icons.shopping_cart_outlined, size: 36, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 6),
                      const Text('Cart is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Text('Tap items from catalog to add', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: _cartItems.length,
                  separatorBuilder: (_, _) => const Divider(height: 10),
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${Formatters.currency(item.unitPrice)} each',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _updateQuantity(index, -1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _updateQuantity(index, 1),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 60,
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                  Text(Formatters.currency(_subtotal), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GST Tax:', style: TextStyle(fontSize: 12)),
                  Text(Formatters.currency(_totalTax), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                ],
              ),
              const Divider(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    Formatters.currency(_grandTotal),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Payment mode dropdown
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                isDense: true,
                decoration: const InputDecoration(labelText: 'Payment Method', isDense: true),
                items: const [
                  DropdownMenuItem(value: 'UPI / GPay', child: Text('UPI / GPay / QR Scanner', maxLines: 1)),
                  DropdownMenuItem(value: 'Credit Card', child: Text('Credit / Debit Card POS', maxLines: 1)),
                  DropdownMenuItem(value: 'Cash', child: Text('Showroom Cash Counter', maxLines: 1)),
                  DropdownMenuItem(value: 'Corporate Credit', child: Text('Corporate Credit (30 Days)', maxLines: 1)),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
              const SizedBox(height: 10),

              AlRabeeButton(
                label: 'Complete Sale & Print Bill',
                icon: Icons.check_circle_rounded,
                isFullWidth: true,
                height: 40,
                onPressed: _cartItems.isEmpty ? null : _completeSale,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMobileCartSheet(BuildContext context, bool isDark, ErpProvider erp) {
    AlRabeeBottomSheet.show(
      context: context,
      title: 'Current POS Cart',
      subtitle: '${_cartItems.length} items • Total ${Formatters.currency(_grandTotal)}',
      child: StatefulBuilder(
        builder: (ctx, setSheetState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: _buildCartPanelContent(isDark, erp),
          );
        },
      ),
    );
  }
}
