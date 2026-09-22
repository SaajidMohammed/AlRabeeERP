class AuditLogModel {
  final String id;
  final String user;
  final String role;
  final String action; // 'CREATE_INVOICE', 'ADJUST_STOCK', 'APPROVE_PO', 'LOGIN_SUCCESS', 'UPDATE_ROLE'
  final String module;
  final String details;
  final String ipAddress;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.user,
    required this.role,
    required this.action,
    required this.module,
    required this.details,
    this.ipAddress = '192.168.1.45',
    required this.timestamp,
  });
}
