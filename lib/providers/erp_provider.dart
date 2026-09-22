import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/product_model.dart';
import '../models/lead_model.dart';
import '../models/sales_model.dart';
import '../models/purchase_model.dart';
import '../models/accounting_model.dart';
import '../models/hr_model.dart';
import '../models/project_model.dart';
import '../models/notification_model.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';
import '../repositories/mock/mock_erp_database.dart';
import '../core/widgets/toast/toast_service.dart';

class ErpProvider extends ChangeNotifier {
  final MockErpDatabase _db = MockErpDatabase();
  final ToastService _toast = ToastService();

  String _selectedBranch = 'Main Flagship Showroom - Mumbai';
  String get selectedBranch => _selectedBranch;

  void setBranch(String branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  // --- GETTERS ---
  List<ProductModel> get products => _db.getProducts();
  ProductModel? getProductById(String id) => _db.getProductById(id);
  List<StockMovement> get stockMovements => _db.getStockMovements();
  List<WarehouseModel> get warehouses => _db.getWarehouses();
  List<CustomerModel> get customers => _db.getCustomers();
  List<SupplierModel> get suppliers => _db.getSuppliers();
  List<LeadModel> get leads => _db.getLeads();
  List<InvoiceModel> get invoices => _db.getInvoices();
  List<QuotationModel> get quotations => _db.getQuotations();
  List<PurchaseOrderModel> get purchaseOrders => _db.getPurchaseOrders();
  List<TransactionRecord> get transactions => _db.getTransactions();
  List<EmployeeModel> get employees => _db.getEmployees();
  List<AttendanceRecord> get attendance => _db.getAttendance();
  List<LeaveRequest> get leaveRequests => _db.getLeaveRequests();
  List<ProjectModel> get projects => _db.getProjects();
  List<NotificationModel> get notifications => _db.getNotifications();
  List<UserModel> get users => _db.getUsers();
  List<AuditLogModel> get auditLogs => _db.getAuditLogs();

  int get unreadNotificationCount =>
      _db.getNotifications().where((n) => !n.isRead).length;

  // --- DASHBOARD KPI CALCULATIONS ---
  double get todaySales {
    final now = DateTime.now();
    return invoices
        .where((inv) =>
            inv.invoiceDate.year == now.year &&
            inv.invoiceDate.month == now.month &&
            inv.invoiceDate.day == now.day)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get monthlyRevenue {
    final now = DateTime.now();
    return invoices
        .where((inv) =>
            inv.invoiceDate.year == now.year &&
            inv.invoiceDate.month == now.month)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get monthlyPurchases {
    final now = DateTime.now();
    return purchaseOrders
        .where((po) =>
            po.orderDate.year == now.year && po.orderDate.month == now.month)
        .fold(0.0, (sum, po) => sum + po.grandTotal);
  }

  double get netProfit => (monthlyRevenue - monthlyPurchases) * 0.72; // Estimated net margin

  double get totalReceivables =>
      customers.fold(0.0, (sum, c) => sum + c.outstandingBalance);

  double get totalPayables =>
      suppliers.fold(0.0, (sum, s) => sum + s.outstandingPayable);

  double get totalInventoryValue =>
      products.fold(0.0, (sum, p) => sum + p.totalStockValue);

  List<ProductModel> get lowStockProducts =>
      products.where((p) => p.stockStatus != StockStatus.healthy).toList();

  Map<String, double> get salesByCategory {
    final map = <String, double>{};
    for (var inv in invoices) {
      for (var item in inv.items) {
        final product = _db.getProductById(item.productId);
        final category = product?.category ?? 'Other';
        map[category] = (map[category] ?? 0.0) + item.total;
      }
    }
    return map;
  }

  // --- ACTIONS WITH AUTOMATED TOASTS & STATE SYNC ---

  // Sales
  void createInvoice(InvoiceModel invoice) {
    _db.createInvoice(invoice);
    _toast.success(
      'Invoice generated successfully',
      message: '${invoice.invoiceNumber} for ${invoice.customerName} • ₹${invoice.grandTotal.toStringAsFixed(2)}',
    );
    notifyListeners();
  }

  void recordPayment(String invoiceId, PaymentRecord payment) {
    _db.recordInvoicePayment(invoiceId, payment);
    _toast.success(
      'Payment recorded successfully',
      message: '₹${payment.amount.toStringAsFixed(2)} via ${payment.paymentMethod}',
    );
    notifyListeners();
  }

  void saveQuotation(QuotationModel quotation) {
    _db.saveQuotation(quotation);
    _toast.success('Quotation ${quotation.quotationNumber} saved');
    notifyListeners();
  }

  // Products & Inventory
  void saveProduct(ProductModel product, {bool isNew = false}) {
    _db.saveProduct(product);
    _toast.success(
      isNew ? 'Product added successfully' : 'Product updated successfully',
      message: '${product.name} (${product.sku})',
    );
    notifyListeners();
  }

  void deleteProduct(String id) {
    final p = _db.getProductById(id);
    _db.deleteProduct(id);
    _toast.warning(
      'Product deleted',
      message: p != null ? '${p.name} has been removed' : null,
    );
    notifyListeners();
  }

  void adjustStock(String productId, int newQuantity, String reason, String warehouse, String user) {
    _db.adjustStock(productId, newQuantity, reason, warehouse, user);
    final p = _db.getProductById(productId);
    _toast.info(
      'Stock updated successfully',
      message: '${p?.name ?? "Product"}: New stock $newQuantity',
    );
    notifyListeners();
  }

  // Customers
  void saveCustomer(CustomerModel customer, {bool isNew = false}) {
    _db.saveCustomer(customer);
    _toast.success(
      isNew ? 'Customer created successfully' : 'Customer profile updated',
      message: customer.name,
    );
    notifyListeners();
  }

  void deleteCustomer(String id) {
    final c = _db.getCustomerById(id);
    _db.deleteCustomer(id);
    _toast.warning('Customer removed', message: c?.name);
    notifyListeners();
  }

  void addCustomerActivity(String customerId, CustomerActivity activity) {
    _db.addCustomerActivity(customerId, activity);
    _toast.info('Activity logged', message: activity.title);
    notifyListeners();
  }

  // Suppliers
  void saveSupplier(SupplierModel supplier, {bool isNew = false}) {
    _db.saveSupplier(supplier);
    _toast.success(
      isNew ? 'Supplier registered successfully' : 'Supplier profile updated',
      message: supplier.name,
    );
    notifyListeners();
  }

  // CRM Leads
  void saveLead(LeadModel lead, {bool isNew = false}) {
    _db.saveLead(lead);
    _toast.success(
      isNew ? 'New lead added to pipeline' : 'Lead updated',
      message: '${lead.name} • ${lead.stage.label}',
    );
    notifyListeners();
  }

  void updateLeadStage(String leadId, LeadStage stage) {
    _db.updateLeadStage(leadId, stage);
    _toast.info('Pipeline updated', message: 'Lead moved to ${stage.label}');
    notifyListeners();
  }

  void deleteLead(String id) {
    _db.deleteLead(id);
    _toast.warning('Lead removed from pipeline');
    notifyListeners();
  }

  // Purchases
  void createPurchaseOrder(PurchaseOrderModel po) {
    _db.createPurchaseOrder(po);
    _toast.success(
      'Purchase Order Created',
      message: '${po.poNumber} for ${po.supplierName}',
    );
    notifyListeners();
  }

  void receiveGoods(String poId, String receivedBy) {
    _db.receiveGoods(poId, receivedBy);
    _toast.success(
      'Goods Receipt Verified',
      message: 'Inventory stock auto-incremented for PO $poId',
    );
    notifyListeners();
  }

  // Accounting
  void addTransaction(TransactionRecord transaction) {
    _db.addTransaction(transaction);
    _toast.success(
      'Transaction recorded',
      message: '${transaction.title} (₹${transaction.amount.toStringAsFixed(2)})',
    );
    notifyListeners();
  }

  // HR
  void markAttendance(AttendanceRecord record) {
    _db.markAttendance(record);
    _toast.info('Attendance recorded for ${record.employeeName}');
    notifyListeners();
  }

  void processLeaveRequest(String leaveId, LeaveStatus status, String approvedBy) {
    _db.processLeaveRequest(leaveId, status, approvedBy);
    _toast.info(
      'Leave request updated',
      message: 'Status marked as ${status.label}',
    );
    notifyListeners();
  }

  // Projects
  void updateTaskStatus(String projectId, String taskId, TaskStatus status) {
    _db.updateTaskStatus(projectId, taskId, status);
    notifyListeners();
  }

  void addTask(String projectId, ProjectTask task) {
    _db.addTask(projectId, task);
    _toast.success('Task added to project', message: task.title);
    notifyListeners();
  }

  // Notifications
  void markNotificationAsRead(String id) {
    _db.markNotificationAsRead(id);
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    _db.markAllNotificationsAsRead();
    _toast.info('All notifications marked as read');
    notifyListeners();
  }

  void clearNotifications() {
    _db.clearNotifications();
    _toast.info('Notifications cleared');
    notifyListeners();
  }
}
