import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../models/product_model.dart';

import '../../providers/erp_provider.dart';
import 'stock_adjustment_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  int _tabIndex = 0; // 0: Inventory Cards, 1: Movement Audit

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    final query = _searchController.text.toLowerCase();
    final filteredProducts = erp.products.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.primaryWarehouse.toLowerCase().contains(query);

      if (!matchesQuery) return false;

      if (_selectedFilter == 'Low Stock') return p.stockStatus == StockStatus.lowStock;
      if (_selectedFilter == 'Out of Stock') return p.currentStock <= 0;
      if (_selectedFilter == 'Healthy') return p.stockStatus == StockStatus.healthy;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Header & Quick Controls
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isDesktop ? 24 : 16, 16, isDesktop ? 24 : 16, 8),
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
                              'Inventory & Stock',
                              style: TextStyle(
                                fontSize: isDesktop ? 24 : 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Valuation: ${Formatters.currency(erp.totalInventoryValue)} across 3 cold hubs',
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
                        label: 'Adjust Stock',
                        icon: Icons.tune_rounded,
                        height: 38,
                        onPressed: () => StockAdjustmentSheet.show(context, erp),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  AlRabeeSearchBar(
                    controller: _searchController,
                    hintText: 'Search products by SKU, name, origin...',
                    onChanged: (_) => setState(() {}),
                    onClear: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips & View Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', erp.products.length),
                              _buildFilterChip('Healthy', erp.products.where((p) => p.stockStatus == StockStatus.healthy).length),
                              _buildFilterChip('Low Stock', erp.lowStockProducts.length),
                              _buildFilterChip('Out of Stock', erp.products.where((p) => p.currentStock <= 0).length),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tab Switcher (Catalog vs Movements)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.cardHoverLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTabIcon(0, Icons.grid_view_rounded, 'Products'),
                            _buildTabIcon(1, Icons.history_rounded, 'Movements'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_tabIndex == 0) ...[
            if (filteredProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AlRabeeEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No products found',
                  message: 'Try changing your search keywords or filter.',
                  actionLabel: 'Reset Filters',
                  onAction: () {
                    setState(() {
                      _searchController.clear();
                      _selectedFilter = 'All';
                    });
                  },
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filteredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildProductCard(context, product, isDark, erp),
                      );
                    },
                    childCount: filteredProducts.length,
                  ),
                ),
              ),
          ] else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final mov = erp.stockMovements[index];
                    final isPositive = mov.type == StockMovementType.purchase || mov.type == StockMovementType.transferIn;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AlRabeeCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isPositive ? AppColors.pastelMint : AppColors.pastelRose,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                size: 18,
                                color: isPositive ? AppColors.successText : AppColors.errorText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${mov.type.label}: ${mov.productName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    'Ref: ${mov.reference} • ${mov.warehouse}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isPositive ? "+" : "-"}${mov.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                                Text(
                                  Formatters.timeAgo(mov.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: erp.stockMovements.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabIcon(int index, IconData icon, String tooltip) {
    final isSelected = _tabIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
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

  Widget _buildProductCard(BuildContext context, ProductModel p, bool isDark, ErpProvider erp) {
    final isLow = p.stockStatus == StockStatus.lowStock || p.currentStock <= p.minimumStock;
    final isOut = p.currentStock <= 0;

    return AlRabeeCard(
      padding: const EdgeInsets.all(14),
      onTap: () => StockAdjustmentSheet.show(context, erp, product: p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Icon / Pastel Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLow
                      ? AppColors.pastelAmber
                      : (isOut ? AppColors.pastelRose : AppColors.pastelMint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isLow
                        ? Icons.warning_amber_rounded
                        : (isOut ? Icons.block_rounded : Icons.inventory_2_rounded),
                    color: isLow
                        ? AppColors.pastelAmberIcon
                        : (isOut ? AppColors.pastelRoseIcon : AppColors.pastelMintIcon),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, SKU, Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${p.sku} • ${p.category}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      'Rack: ${p.rackLocation} • ${p.primaryWarehouse}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${Formatters.currency(p.sellingPrice)} / ${p.unit}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isOut)
                    StatusBadge.error('Out of Stock')
                  else if (isLow)
                    StatusBadge.warning('Low Stock')
                  else
                    StatusBadge.success('Healthy'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Stock Level Bar & Quick Adjust CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Stock: ',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '${p.currentStock} ${p.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isLow ? AppColors.warning : (isOut ? AppColors.error : AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(Min: ${p.minimumStock} ${p.unit})',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => StockAdjustmentSheet.show(context, erp, product: p),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Adjust',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

