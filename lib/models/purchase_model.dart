enum PurchaseStatus {
  draft('Draft'),
  pendingApproval('Pending Approval'),
  approved('Approved'),
  ordered('Ordered'),
  received('Received'),
  partiallyReceived('Partially Received'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const PurchaseStatus(this.label);
}

class PurchaseItem {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final int receivedQuantity;
  final double unitCost;
  final double taxPercent;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    this.receivedQuantity = 0,
    required this.unitCost,
    this.taxPercent = 5.0,
  });

  double get lineTotal => quantity * unitCost;
  double get taxAmount => lineTotal * (taxPercent / 100);
  double get totalWithTax => lineTotal + taxAmount;

  PurchaseItem copyWith({
    int? quantity,
    int? receivedQuantity,
    double? unitCost,
  }) {
    return PurchaseItem(
      productId: productId,
      productName: productName,
      sku: sku,
      quantity: quantity ?? this.quantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      unitCost: unitCost ?? this.unitCost,
      taxPercent: taxPercent,
    );
  }
}

class PurchaseOrderModel {
  final String id;
  final String poNumber; // PO-2026-0042
  final String supplierId;
  final String supplierName;
  final String supplierCountry;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final List<PurchaseItem> items;
  final double shippingFee;
  final double otherCharges;
  final PurchaseStatus status;
  final String destinationWarehouse;
  final String paymentTerms; // '30 Days Net', 'Advance 50%', 'LC at Sight'
  final String requestedBy;
  final String? approvedBy;
  final String notes;

  PurchaseOrderModel({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCountry,
    required this.orderDate,
    required this.expectedDeliveryDate,
    required this.items,
    this.shippingFee = 0.0,
    this.otherCharges = 0.0,
    this.status = PurchaseStatus.approved,
    required this.destinationWarehouse,
    this.paymentTerms = '30 Days Net',
    required this.requestedBy,
    this.approvedBy,
    this.notes = '',
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);
  double get totalTax => items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get grandTotal => subtotal + totalTax + shippingFee + otherCharges;

  PurchaseOrderModel copyWith({
    PurchaseStatus? status,
    List<PurchaseItem>? items,
    String? approvedBy,
    String? notes,
  }) {
    return PurchaseOrderModel(
      id: id,
      poNumber: poNumber,
      supplierId: supplierId,
      supplierName: supplierName,
      supplierCountry: supplierCountry,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      items: items ?? this.items,
      shippingFee: shippingFee,
      otherCharges: otherCharges,
      status: status ?? this.status,
      destinationWarehouse: destinationWarehouse,
      paymentTerms: paymentTerms,
      requestedBy: requestedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
    );
  }
}
