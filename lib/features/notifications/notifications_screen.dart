import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/design_system/design_system.dart';
import '../../core/widgets/toast/toast_service.dart';
import '../../models/notification_model.dart';
import '../../providers/erp_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = erp.notifications.where((n) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Sales') return n.category == NotificationCategory.sales;
      if (_selectedCategory == 'Inventory') return n.category == NotificationCategory.inventory;
      if (_selectedCategory == 'Purchases') return n.category == NotificationCategory.purchases;
      if (_selectedCategory == 'Finance') return n.category == NotificationCategory.finance;
      if (_selectedCategory == 'System') return n.category == NotificationCategory.system;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Top Header & Category Pills
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                              'Notification Center',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${erp.unreadNotificationCount} unread alerts requiring attention',
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
                      if (erp.unreadNotificationCount > 0)
                        TextButton.icon(
                          onPressed: () {
                            erp.markAllNotificationsAsRead();
                            ToastService.showSuccess('All notifications marked as read');
                          },
                          icon: const Icon(Icons.done_all_rounded, size: 16),
                          label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All', erp.notifications.length),
                        _buildCategoryChip('Sales', erp.notifications.where((n) => n.category == NotificationCategory.sales).length),
                        _buildCategoryChip('Inventory', erp.notifications.where((n) => n.category == NotificationCategory.inventory).length),
                        _buildCategoryChip('Purchases', erp.notifications.where((n) => n.category == NotificationCategory.purchases).length),
                        _buildCategoryChip('Finance', erp.notifications.where((n) => n.category == NotificationCategory.finance).length),
                        _buildCategoryChip('System', erp.notifications.where((n) => n.category == NotificationCategory.system).length),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notifications List
          if (filteredList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AlRabeeEmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'No notifications',
                message: 'You are all caught up! No notifications in this category.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildNotificationItem(context, item, isDark, erp),
                    );
                  },
                  childCount: filteredList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, int count) {
    final isSelected = _selectedCategory == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = label),
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

  Widget _buildNotificationItem(BuildContext context, NotificationModel n, bool isDark, ErpProvider erp) {
    final (icon, iconColor, bg) = _getNotificationStyle(n.category);

    return AlRabeeCard(
      padding: const EdgeInsets.all(14),
      borderColor: n.isRead ? null : AppColors.primary.withValues(alpha: 0.35),
      color: n.isRead
          ? null
          : (isDark ? AppColors.primaryDark.withValues(alpha: 0.12) : const Color(0xFFF5F3FF)),
      onTap: () {
        if (!n.isRead) {
          erp.markNotificationAsRead(n.id);
        }
        if (n.routeTarget != null && n.routeTarget!.isNotEmpty) {
          context.go(n.routeTarget!);
        } else {
          ToastService.showInfo(n.title, message: n.message);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pastel Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Message & Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 13.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.timeAgo(n.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, Color) _getNotificationStyle(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.inventory:
        return (Icons.warning_amber_rounded, AppColors.pastelAmberIcon, AppColors.pastelAmber);
      case NotificationCategory.sales:
        return (Icons.receipt_long_rounded, AppColors.pastelMintIcon, AppColors.pastelMint);
      case NotificationCategory.purchases:
        return (Icons.local_shipping_rounded, AppColors.pastelCyanIcon, AppColors.pastelCyan);
      case NotificationCategory.finance:
        return (Icons.account_balance_wallet_rounded, AppColors.pastelLavenderIcon, AppColors.pastelLavender);
      case NotificationCategory.all:
      case NotificationCategory.tasks:
      case NotificationCategory.system:
        return (Icons.info_outline_rounded, AppColors.pastelSkyIcon, AppColors.pastelSky);
    }
  }
}

