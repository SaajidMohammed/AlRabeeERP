enum UserRole {
  superAdmin('Super Admin', 'Full unrestricted access to all modules and configurations'),
  manager('Store Manager', 'Operational oversight, reporting, approvals, and team management'),
  salesStaff('Sales Staff', 'Quotations, sales orders, POS billing, and customer relations'),
  inventoryManager('Inventory Manager', 'Stock movements, warehouses, purchases receipt, and adjustments'),
  accountant('Accountant', 'Financial ledgers, receivables, payables, expenses, and taxes'),
  hrManager('HR Manager', 'Employee attendance, leave approvals, payroll, and staff records');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}

class UserPermission {
  final String module;
  final bool view;
  final bool create;
  final bool edit;
  final bool delete;
  final bool approve;
  final bool export;

  const UserPermission({
    required this.module,
    this.view = true,
    this.create = false,
    this.edit = false,
    this.delete = false,
    this.approve = false,
    this.export = false,
  });
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String avatarUrl;
  final String department;
  final bool isActive;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    required this.department,
    this.isActive = true,
    DateTime? lastLogin,
  }) : lastLogin = lastLogin ?? DateTime.now();

  static List<UserPermission> getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return const [
          UserPermission(module: 'Dashboard', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'CRM & Leads', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Customers', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Products', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Sales', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Purchases', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Inventory', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Accounting', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'HR & Payroll', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Projects', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Reports', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Administration', view: true, create: true, edit: true, delete: true, approve: true, export: true),
        ];
      case UserRole.manager:
        return const [
          UserPermission(module: 'Dashboard', view: true, export: true),
          UserPermission(module: 'CRM & Leads', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'Customers', view: true, create: true, edit: true, export: true),
          UserPermission(module: 'Products', view: true, create: true, edit: true, export: true),
          UserPermission(module: 'Sales', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'Purchases', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'Inventory', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'Accounting', view: true, create: true, export: true),
          UserPermission(module: 'HR & Payroll', view: true, approve: true, export: true),
          UserPermission(module: 'Projects', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'Reports', view: true, export: true),
          UserPermission(module: 'Administration', view: false),
        ];
      case UserRole.salesStaff:
        return const [
          UserPermission(module: 'Dashboard', view: true),
          UserPermission(module: 'CRM & Leads', view: true, create: true, edit: true),
          UserPermission(module: 'Customers', view: true, create: true, edit: true),
          UserPermission(module: 'Products', view: true),
          UserPermission(module: 'Sales', view: true, create: true, edit: true, export: true),
          UserPermission(module: 'Purchases', view: false),
          UserPermission(module: 'Inventory', view: true),
          UserPermission(module: 'Accounting', view: false),
          UserPermission(module: 'HR & Payroll', view: false),
          UserPermission(module: 'Projects', view: true),
          UserPermission(module: 'Reports', view: true, export: false),
          UserPermission(module: 'Administration', view: false),
        ];
      case UserRole.inventoryManager:
        return const [
          UserPermission(module: 'Dashboard', view: true),
          UserPermission(module: 'CRM & Leads', view: false),
          UserPermission(module: 'Customers', view: false),
          UserPermission(module: 'Products', view: true, create: true, edit: true, export: true),
          UserPermission(module: 'Sales', view: true),
          UserPermission(module: 'Purchases', view: true, create: true, edit: true, approve: true),
          UserPermission(module: 'Inventory', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Accounting', view: false),
          UserPermission(module: 'HR & Payroll', view: false),
          UserPermission(module: 'Projects', view: true),
          UserPermission(module: 'Reports', view: true, export: true),
          UserPermission(module: 'Administration', view: false),
        ];
      case UserRole.accountant:
        return const [
          UserPermission(module: 'Dashboard', view: true),
          UserPermission(module: 'CRM & Leads', view: false),
          UserPermission(module: 'Customers', view: true),
          UserPermission(module: 'Products', view: true),
          UserPermission(module: 'Sales', view: true, export: true),
          UserPermission(module: 'Purchases', view: true, export: true),
          UserPermission(module: 'Inventory', view: true),
          UserPermission(module: 'Accounting', view: true, create: true, edit: true, approve: true, export: true),
          UserPermission(module: 'HR & Payroll', view: true, edit: true, export: true),
          UserPermission(module: 'Projects', view: false),
          UserPermission(module: 'Reports', view: true, export: true),
          UserPermission(module: 'Administration', view: false),
        ];
      case UserRole.hrManager:
        return const [
          UserPermission(module: 'Dashboard', view: true),
          UserPermission(module: 'CRM & Leads', view: false),
          UserPermission(module: 'Customers', view: false),
          UserPermission(module: 'Products', view: false),
          UserPermission(module: 'Sales', view: false),
          UserPermission(module: 'Purchases', view: false),
          UserPermission(module: 'Inventory', view: false),
          UserPermission(module: 'Accounting', view: false),
          UserPermission(module: 'HR & Payroll', view: true, create: true, edit: true, delete: true, approve: true, export: true),
          UserPermission(module: 'Projects', view: true),
          UserPermission(module: 'Reports', view: true, export: true),
          UserPermission(module: 'Administration', view: false),
        ];
    }
  }
}
