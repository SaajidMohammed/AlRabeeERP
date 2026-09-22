enum NotificationCategory {
  all('All'),
  sales('Sales'),
  inventory('Inventory'),
  purchases('Purchases'),
  finance('Finance'),
  tasks('Tasks'),
  system('System');

  final String label;
  const NotificationCategory(this.label);
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? routeTarget; // Link to specific invoice, PO, or product

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.routeTarget,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      category: category,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      routeTarget: routeTarget,
    );
  }
}
