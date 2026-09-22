import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../utils/formatters.dart';
import '../../../models/notification_model.dart';
import '../../../providers/erp_provider.dart';
import '../badges/status_badge.dart';
import '../feedback/empty_state.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  NotificationCategory _selectedCategory = NotificationCategory.all;

  @override
  Widget build(BuildContext context) {
    final erp = context.watch<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredNotifications = _selectedCategory == NotificationCategory.all
        ? erp.notifications
        : erp.notifications.where((n) => n.category == _selectedCategory).toList();

    return Drawer(
      width: 400,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined, size: 22, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (erp.unreadNotificationCount > 0) ...[
                        const SizedBox(width: 8),
                        StatusBadge.gold('${erp.unreadNotificationCount} New'),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

            // Category Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: NotificationCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.onPrimaryContainer : null,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: erp.markAllNotificationsAsRead,
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: erp.clearNotifications,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear all', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

            // Notification List
            Expanded(
              child: filteredNotifications.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No notifications',
                      description: 'You\'re all caught up! There are no unread alerts.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filteredNotifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = filteredNotifications[index];
                        return _NotificationCard(notification: notif);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  IconData _getIcon() {
    switch (notification.category) {
      case NotificationCategory.sales:
        return Icons.shopping_bag_outlined;
      case NotificationCategory.inventory:
        return Icons.inventory_2_outlined;
      case NotificationCategory.purchases:
        return Icons.local_shipping_outlined;
      case NotificationCategory.finance:
        return Icons.account_balance_wallet_outlined;
      case NotificationCategory.tasks:
        return Icons.task_alt_outlined;
      case NotificationCategory.system:
      case NotificationCategory.all:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColor() {
    switch (notification.category) {
      case NotificationCategory.sales:
        return AppColors.success;
      case NotificationCategory.inventory:
        return AppColors.warning;
      case NotificationCategory.purchases:
        return AppColors.oceanBlue;
      case NotificationCategory.finance:
        return AppColors.saffronGold;
      case NotificationCategory.tasks:
        return AppColors.pistachio;
      case NotificationCategory.system:
      case NotificationCategory.all:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final erp = context.read<ErpProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor();

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? AppColors.cardDark : AppColors.cardLight)
            : (isDark ? const Color(0xFF1B2E24) : const Color(0xFFF0FDF4)),
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(
          color: notification.isRead
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : color.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: AppTokens.borderRadiusMd,
          ),
          child: Icon(_getIcon(), size: 20, color: color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.timeAgo(notification.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
                if (!notification.isRead)
                  InkWell(
                    onTap: () => erp.markNotificationAsRead(notification.id),
                    child: Text(
                      'Mark as read',
                      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
