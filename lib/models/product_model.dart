enum StockStatus {
  healthy('Healthy', 'In Stock'),
  lowStock('Low Stock', 'Needs Reorder'),
  outOfStock('Out of Stock', 'Critical Alert');

  final String label;
  final String description;
  const StockStatus(this.label, this.description);
}

enum StockMovementType {
  purchase('Purchase Receipt', 1),
  sale('Sales Delivery', -1),
  transferIn('Transfer In', 1),
  transferOut('Transfer Out', -1),
  adjustment('Stock Adjustment', 0),
  damage('Damaged Stock Write-off', -1);

  final String label;
  final int multiplier;
  const StockMovementType(this.label, this.multiplier);
}

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final StockMovementType type;
  final int quantity;
  final int stockAfter;
  final String reference; // PO-2026-012, INV-2026-089, ADJ-004
  final String warehouse;
  final String notes;
  final DateTime timestamp;
  final String performedBy;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.stockAfter,
    required this.reference,
    required this.warehouse,
    this.notes = '',
    required this.timestamp,
    required this.performedBy,
  });
}

class WarehouseModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final String manager;
  final int totalCapacity;
  final int currentUsage;
  final bool isColdStorage;

  WarehouseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.manager,
    required this.totalCapacity,
    required this.currentUsage,
    this.isColdStorage = false,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String category; // 'Dates', 'Nuts', 'Dry Fruits', 'Chocolates', 'Juices', 'Imported Fruits', 'Packaged Delicacies'
  final String brand;
  final String origin; // 'Saudi Arabia', 'Iran', 'USA', 'Belgium', 'Spain', 'Turkey', 'India'
  final String unit; // 'kg', 'box', 'pack', 'bottle', 'piece'
  final double purchasePrice;
  final double sellingPrice;
  final double mrp;
  final int currentStock;
  final int minimumStock;
  final int reservedStock;
  final String primaryWarehouse;
  final String rackLocation;
  final double taxRate; // 5%, 12%, 18%
  final DateTime expiryDate;
  final String iconCode; // Mock product icon identification
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.category,
    required this.brand,
    required this.origin,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.mrp,
    required this.currentStock,
    required this.minimumStock,
    this.reservedStock = 0,
    required this.primaryWarehouse,
    required this.rackLocation,
    this.taxRate = 5.0,
    required this.expiryDate,
    this.iconCode = 'box',
    this.isActive = true,
  });

  StockStatus get stockStatus {
    if (currentStock <= 0) return StockStatus.outOfStock;
    if (currentStock <= minimumStock) return StockStatus.lowStock;
    return StockStatus.healthy;
  }

  int get availableStock => currentStock - reservedStock;
  double get totalStockValue => currentStock * purchasePrice;
  double get profitMargin => ((sellingPrice - purchasePrice) / sellingPrice) * 100;

  ProductModel copyWith({
    String? name,
    String? sku,
    String? barcode,
    String? category,
    String? brand,
    String? origin,
    String? unit,
    double? purchasePrice,
    double? sellingPrice,
    double? mrp,
    int? currentStock,
    int? minimumStock,
    int? reservedStock,
    String? primaryWarehouse,
    String? rackLocation,
    double? taxRate,
    DateTime? expiryDate,
    String? iconCode,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      origin: origin ?? this.origin,
      unit: unit ?? this.unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mrp: mrp ?? this.mrp,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      reservedStock: reservedStock ?? this.reservedStock,
      primaryWarehouse: primaryWarehouse ?? this.primaryWarehouse,
      rackLocation: rackLocation ?? this.rackLocation,
      taxRate: taxRate ?? this.taxRate,
      expiryDate: expiryDate ?? this.expiryDate,
      iconCode: iconCode ?? this.iconCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
