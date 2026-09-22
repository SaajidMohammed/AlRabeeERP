import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';
import '../../models/product_model.dart';
import '../../models/lead_model.dart';
import '../../models/sales_model.dart';
import '../../models/purchase_model.dart';
import '../../models/accounting_model.dart';
import '../../models/hr_model.dart';
import '../../models/project_model.dart';
import '../../models/notification_model.dart';
import '../../models/audit_log_model.dart';
import '../../models/user_model.dart';

abstract class IErpRepository {
  // Products & Inventory
  List<ProductModel> getProducts();
  ProductModel? getProductById(String id);
  void saveProduct(ProductModel product);
  void deleteProduct(String id);
  void adjustStock(String productId, int newQuantity, String reason, String warehouse, String user);
  List<StockMovement> getStockMovements();
  List<WarehouseModel> getWarehouses();

  // Customers
  List<CustomerModel> getCustomers();
  CustomerModel? getCustomerById(String id);
  void saveCustomer(CustomerModel customer);
  void deleteCustomer(String id);
  void addCustomerActivity(String customerId, CustomerActivity activity);

  // Suppliers
  List<SupplierModel> getSuppliers();
  SupplierModel? getSupplierById(String id);
  void saveSupplier(SupplierModel supplier);

  // Leads & CRM
  List<LeadModel> getLeads();
  void saveLead(LeadModel lead);
  void updateLeadStage(String leadId, LeadStage stage);
  void deleteLead(String id);

  // Sales & Invoices
  List<InvoiceModel> getInvoices();
  InvoiceModel? getInvoiceById(String id);
  void createInvoice(InvoiceModel invoice);
  void recordInvoicePayment(String invoiceId, PaymentRecord payment);
  List<QuotationModel> getQuotations();
  void saveQuotation(QuotationModel quotation);

  // Purchases
  List<PurchaseOrderModel> getPurchaseOrders();
  void createPurchaseOrder(PurchaseOrderModel po);
  void receiveGoods(String poId, String receivedBy);
  void updatePurchaseStatus(String poId, PurchaseStatus status);

  // Accounting
  List<TransactionRecord> getTransactions();
  void addTransaction(TransactionRecord transaction);

  // HR & Employees
  List<EmployeeModel> getEmployees();
  void saveEmployee(EmployeeModel employee);
  List<AttendanceRecord> getAttendance();
  void markAttendance(AttendanceRecord record);
  List<LeaveRequest> getLeaveRequests();
  void processLeaveRequest(String leaveId, LeaveStatus status, String approvedBy);

  // Projects & Tasks
  List<ProjectModel> getProjects();
  void saveProject(ProjectModel project);
  void updateTaskStatus(String projectId, String taskId, TaskStatus status);
  void addTask(String projectId, ProjectTask task);

  // Notifications
  List<NotificationModel> getNotifications();
  void markNotificationAsRead(String id);
  void markAllNotificationsAsRead();
  void clearNotifications();

  // Administration & Audit
  List<UserModel> getUsers();
  void saveUser(UserModel user);
  List<AuditLogModel> getAuditLogs();
  void logAudit(String user, String role, String action, String module, String details);
}
