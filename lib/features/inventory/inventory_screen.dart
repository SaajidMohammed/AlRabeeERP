import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/badges/status_badge.dart';
import '../../core/widgets/cards/section_card.dart';
import '../../core/widgets/table/erp_data_table.dart';
import '../../models/product_model.dart';
import '../../providers/erp_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    'Inventory & Warehousing',
                    style: (isDesktop
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Multi-hub cold storage tracking, live shelf quantities & stock audit ledger',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Warehouse Capacity Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final cards = erp.warehouses.map((wh) {
                final usagePercent = (wh.currentUsage / wh.totalCapacity) * 100;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              wh.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (wh.isColdStorage)
                            const Icon(Icons.ac_unit_rounded, size: 16, color: AppColors.oceanBlue),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manager: ${wh.manager} • ${wh.code}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: wh.currentUsage / wh.totalCapacity,
                        backgroundColor: isDark ? Colors.black26 : Colors.grey.shade200,
                        color: usagePercent > 85 ? AppColors.warning : AppColors.primary,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${wh.currentUsage} / ${wh.totalCapacity} kg', style: const TextStyle(fontSize: 11)),
                          Text('${usagePercent.toStringAsFixed(0)}% Utilized',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList();

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
                children: cards
                    .map((c) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: c,
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Tabs
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text('Live Stock Master (${erp.products.length})'),
                selected: _tabIndex == 0,
                onSelected: (_) => setState(() => _tabIndex = 0),
              ),
              ChoiceChip(
                label: Text('Stock Movements (${erp.stockMovements.length})'),
                selected: _tabIndex == 1,
                onSelected: (_) => setState(() => _tabIndex = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content
          SizedBox(
            height: 560,
            child: _tabIndex == 0
                ? ErpDataTable<ProductModel>(
                    items: erp.products,
                    searchPlaceholder: 'Search inventory SKU, warehouse, category...',
                    searchMatcher: (p, q) =>
                        p.name.toLowerCase().contains(q) ||
                        p.sku.toLowerCase().contains(q) ||
                        p.primaryWarehouse.toLowerCase().contains(q),
                    columns: [
                      ErpTableColumn(
                        title: 'Product & SKU',
                        cellBuilder: (p) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${p.sku} • ${p.category}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      ErpTableColumn(
                        title: 'Primary Warehouse',
                        cellBuilder: (p) => Text(p.primaryWarehouse, style: const TextStyle(fontSize: 12)),
                      ),
                      ErpTableColumn(
                        title: 'Shelf Rack',
                        cellBuilder: (p) => Text(p.rackLocation, style: const TextStyle(fontSize: 12)),
                      ),
                      ErpTableColumn(
                        title: 'Available Stock',
                        isNumeric: true,
                        cellBuilder: (p) => Text('${p.currentStock} ${p.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        comparator: (a, b) => a.currentStock.compareTo(b.currentStock),
                      ),
                      ErpTableColumn(
                        title: 'Valuation',
                        isNumeric: true,
                        cellBuilder: (p) => Text(Formatters.currency(p.totalStockValue), style: const TextStyle(fontWeight: FontWeight.bold)),
                        comparator: (a, b) => a.totalStockValue.compareTo(b.totalStockValue),
                      ),
                      ErpTableColumn(
                        title: 'Stock Health',
                        cellBuilder: (p) {
                          if (p.stockStatus == StockStatus.healthy) return StatusBadge.success('Optimal');
                          if (p.stockStatus == StockStatus.lowStock) return StatusBadge.warning('Low Stock');
                          return StatusBadge.error('Critical Zero');
                        },
                      ),
                    ],
                  )
                : SectionCard(
                    isExpanded: true,
                    title: 'Real-Time Stock Movement Audit Log',
                    subtitle: 'Automatic recording of purchases (+), retail sales (-), transfers, and damage write-offs',
                    child: erp.stockMovements.isEmpty
                        ? const Center(child: Text('No stock movements recorded yet.'))
                        : ListView.separated(
                            itemCount: erp.stockMovements.length,
                            separatorBuilder: (_, _) => const Divider(height: 16),
                            itemBuilder: (context, idx) {
                              final mov = erp.stockMovements[idx];
                              final isPositive = mov.type == StockMovementType.purchase || mov.type == StockMovementType.transferIn;

                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.berryRose.withValues(alpha: 0.1),
                                      borderRadius: AppTokens.borderRadiusMd,
                                    ),
                                    child: Icon(
                                      isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: isPositive ? AppColors.success : AppColors.berryRose,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${mov.type.label}: ${mov.productName}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          'Ref: ${mov.reference} • ${mov.warehouse} • Performed by ${mov.performedBy}',
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
                                          color: isPositive ? AppColors.success : AppColors.berryRose,
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
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
