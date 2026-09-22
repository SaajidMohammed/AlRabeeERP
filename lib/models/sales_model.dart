enum SalesStatus {
  draft('Draft'),
  confirmed('Confirmed'),
  processing('Processing'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const SalesStatus(this.label);
}

enum PaymentStatus {
  paid('Paid'),
  partial('Partially Paid'),
  unpaid('Unpaid'),
  overdue('Overdue'),
  refunded('Refunded');

  final String label;
  const PaymentStatus(this.label);
}

class InvoiceItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double discountPercent;
  final double taxPercent;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0.0,
    this.taxPercent = 5.0,
  });

  double get lineSubtotal => quantity * unitPrice;
  double get discountAmount => lineSubtotal * (discountPercent / 100);
  double get taxableAmount => lineSubtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxPercent / 100);
  double get total => taxableAmount + taxAmount;
}

class PaymentRecord {
  final String id;
  final String invoiceId;
  final double amount;
  final String paymentMethod; // 'Cash', 'UPI / GPay', 'Credit Card', 'Bank Transfer', 'Cheque'
  final String referenceNumber;
  final DateTime paymentDate;
  final String receivedBy;
  final String notes;

  PaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.paymentDate,
    required this.receivedBy,
    this.notes = '',
  });
}

class InvoiceModel {
  final String id;
  final String invoiceNumber; // e.g. INV-2026-00125
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final String customerGstin;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final double discountAmount;
  final double shippingCharges;
  final double roundOff;
  final double amountPaid;
  final PaymentStatus paymentStatus;
  final SalesStatus salesStatus;
  final String branch;
  final String salesPerson;
  final String paymentMethod;
  final String notes;
  final List<PaymentRecord> paymentHistory;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail = '',
    this.customerAddress = '',
    this.customerGstin = '',
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    this.discountAmount = 0.0,
    this.shippingCharges = 0.0,
    this.roundOff = 0.0,
    this.amountPaid = 0.0,
    this.paymentStatus = PaymentStatus.unpaid,
    this.salesStatus = SalesStatus.completed,
    this.branch = 'Main Showroom - Riyadh / Mumbai Flagship',
    required this.salesPerson,
    this.paymentMethod = 'UPI / Cash',
    this.notes = 'Thank you for choosing Al Rabee Premium Delicacies.',
    List<PaymentRecord>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineSubtotal);
  double get totalItemDiscount => items.fold(0.0, (sum, item) => sum + item.discountAmount);
  double get totalTax => items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get grandTotal => subtotal - totalItemDiscount - discountAmount + totalTax + shippingCharges + roundOff;
  double get balanceDue => (grandTotal - amountPaid).clamp(0.0, double.infinity);

  InvoiceModel copyWith({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    double? discountAmount,
    double? shippingCharges,
    double? amountPaid,
    PaymentStatus? paymentStatus,
    SalesStatus? salesStatus,
    String? paymentMethod,
    String? notes,
    List<PaymentRecord>? paymentHistory,
  }) {
    return InvoiceModel(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGstin: customerGstin,
      invoiceDate: invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingCharges: shippingCharges ?? this.shippingCharges,
      roundOff: roundOff,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      salesStatus: salesStatus ?? this.salesStatus,
      branch: branch,
      salesPerson: salesPerson,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}

class QuotationModel {
  final String id;
  final String quotationNumber; // QTN-2026-0045
  final String customerId;
  final String customerName;
  final String customerPhone;
  final DateTime date;
  final DateTime validUntil;
  final List<InvoiceItem> items;
  final double discountAmount;
  final String status; // 'Draft', 'Sent', 'Accepted', 'Declined', 'Converted'
  final String createdBy;
  final String notes;

  QuotationModel({
    required this.id,
    required this.quotationNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.validUntil,
    required this.items,
    this.discountAmount = 0.0,
    this.status = 'Sent',
    required this.createdBy,
    this.notes = '',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineSubtotal);
  double get totalTax => items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get grandTotal => subtotal + totalTax - discountAmount;
}
