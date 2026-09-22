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
import '../interfaces/erp_repository.dart';

class MockErpDatabase implements IErpRepository {
  static final MockErpDatabase _instance = MockErpDatabase._internal();
  factory MockErpDatabase() => _instance;

  final List<ProductModel> _products = [];
  final List<StockMovement> _stockMovements = [];
  final List<WarehouseModel> _warehouses = [];
  final List<CustomerModel> _customers = [];
  final List<SupplierModel> _suppliers = [];
  final List<LeadModel> _leads = [];
  final List<InvoiceModel> _invoices = [];
  final List<QuotationModel> _quotations = [];
  final List<PurchaseOrderModel> _purchaseOrders = [];
  final List<TransactionRecord> _transactions = [];
  final List<EmployeeModel> _employees = [];
  final List<AttendanceRecord> _attendance = [];
  final List<LeaveRequest> _leaveRequests = [];
  final List<ProjectModel> _projects = [];
  final List<NotificationModel> _notifications = [];
  final List<UserModel> _users = [];
  final List<AuditLogModel> _auditLogs = [];

  MockErpDatabase._internal() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // 1. Warehouses
    _warehouses.addAll([
      WarehouseModel(
        id: 'WH-01',
        name: 'Main Flagship Showroom & Storage',
        code: 'WH-MUM-01',
        location: 'Ground Floor, Al Rabee Grand Avenue, Bandra West',
        manager: 'Suhail Mansoori',
        totalCapacity: 5000,
        currentUsage: 3840,
        isColdStorage: true,
      ),
      WarehouseModel(
        id: 'WH-02',
        name: 'Central Cold Chain Logistics Hub',
        code: 'WH-BHI-02',
        location: 'Sector 4, Cold Storage Terminal, Bhiwandi',
        manager: 'Farhan Qureshi',
        totalCapacity: 25000,
        currentUsage: 18200,
        isColdStorage: true,
      ),
      WarehouseModel(
        id: 'WH-03',
        name: 'Airport Cargo Fast-Fulfillment Hub',
        code: 'WH-AIR-03',
        location: 'Air Cargo Complex, Terminal 2 Road',
        manager: 'Anand Kulkarni',
        totalCapacity: 8000,
        currentUsage: 5120,
        isColdStorage: true,
      ),
    ]);

    // 2. Products (50+ realistic specialized Al Rabee items)
    _products.addAll([
      // Dates
      ProductModel(
        id: 'PRD-001',
        name: 'Royal Ajwa Dates (Madina Al-Munawwarah)',
        sku: 'DAT-AJW-001',
        barcode: '890123400101',
        category: 'Dates',
        brand: 'Al Rabee Reserve',
        origin: 'Saudi Arabia',
        unit: 'kg',
        purchasePrice: 1650.0,
        sellingPrice: 2450.0,
        mrp: 2700.0,
        currentStock: 145,
        minimumStock: 40,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 1 - Bay A',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 320)),
        iconCode: 'dates',
      ),
      ProductModel(
        id: 'PRD-002',
        name: 'Jumbo Medjool Dates (King of Dates)',
        sku: 'DAT-MED-002',
        barcode: '890123400102',
        category: 'Dates',
        brand: 'Al Rabee Select',
        origin: 'Jordan / California',
        unit: 'kg',
        purchasePrice: 1200.0,
        sellingPrice: 1850.0,
        mrp: 2100.0,
        currentStock: 28, // LOW STOCK
        minimumStock: 35,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 1 - Bay B',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 280)),
        iconCode: 'dates',
      ),
      ProductModel(
        id: 'PRD-003',
        name: 'Premium Safawi Dates',
        sku: 'DAT-SAF-003',
        barcode: '890123400103',
        category: 'Dates',
        brand: 'Al Rabee Classics',
        origin: 'Saudi Arabia',
        unit: 'kg',
        purchasePrice: 750.0,
        sellingPrice: 1150.0,
        mrp: 1300.0,
        currentStock: 210,
        minimumStock: 50,
        primaryWarehouse: 'Central Cold Chain Logistics Hub',
        rackLocation: 'Aisle 1 - Bay C',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 350)),
        iconCode: 'dates',
      ),
      ProductModel(
        id: 'PRD-004',
        name: 'Sukkari Soft Golden Dates',
        sku: 'DAT-SUK-004',
        barcode: '890123400104',
        category: 'Dates',
        brand: 'Al Rabee Select',
        origin: 'Saudi Arabia - Al Qassim',
        unit: 'kg',
        purchasePrice: 680.0,
        sellingPrice: 1050.0,
        mrp: 1200.0,
        currentStock: 95,
        minimumStock: 30,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 1 - Bay D',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 210)),
        iconCode: 'dates',
      ),
      ProductModel(
        id: 'PRD-005',
        name: 'Mabroom Premium Slender Dates',
        sku: 'DAT-MAB-005',
        barcode: '890123400105',
        category: 'Dates',
        brand: 'Al Rabee Reserve',
        origin: 'Saudi Arabia',
        unit: 'kg',
        purchasePrice: 980.0,
        sellingPrice: 1550.0,
        mrp: 1750.0,
        currentStock: 0, // OUT OF STOCK
        minimumStock: 25,
        primaryWarehouse: 'Central Cold Chain Logistics Hub',
        rackLocation: 'Aisle 1 - Bay E',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 360)),
        iconCode: 'dates',
      ),

      // Nuts
      ProductModel(
        id: 'PRD-006',
        name: 'Mamra Almonds (Iranian Super Kernel)',
        sku: 'NUT-MAM-006',
        barcode: '890123400201',
        category: 'Nuts',
        brand: 'Al Rabee Gold',
        origin: 'Iran',
        unit: 'kg',
        purchasePrice: 2400.0,
        sellingPrice: 3600.0,
        mrp: 4000.0,
        currentStock: 82,
        minimumStock: 20,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 2 - Bay A',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 400)),
        iconCode: 'nuts',
      ),
      ProductModel(
        id: 'PRD-007',
        name: 'Iranian Super Green Pistachios (Pistachio Kernels)',
        sku: 'NUT-PST-007',
        barcode: '890123400202',
        category: 'Nuts',
        brand: 'Al Rabee Gold',
        origin: 'Iran - Rafsanjan',
        unit: 'kg',
        purchasePrice: 2800.0,
        sellingPrice: 4200.0,
        mrp: 4600.0,
        currentStock: 18, // LOW STOCK
        minimumStock: 25,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 2 - Bay B',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        iconCode: 'nuts',
      ),
      ProductModel(
        id: 'PRD-008',
        name: 'Chilean Extra Light Walnut Halves',
        sku: 'NUT-WAL-008',
        barcode: '890123400203',
        category: 'Nuts',
        brand: 'Al Rabee Select',
        origin: 'Chile',
        unit: 'kg',
        purchasePrice: 1100.0,
        sellingPrice: 1750.0,
        mrp: 1950.0,
        currentStock: 140,
        minimumStock: 40,
        primaryWarehouse: 'Central Cold Chain Logistics Hub',
        rackLocation: 'Aisle 2 - Bay C',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        iconCode: 'nuts',
      ),
      ProductModel(
        id: 'PRD-009',
        name: 'Jumbo Roasted Salted Cashews W-180',
        sku: 'NUT-CSH-009',
        barcode: '890123400204',
        category: 'Nuts',
        brand: 'Al Rabee Classics',
        origin: 'India - Mangalore / Goa',
        unit: 'kg',
        purchasePrice: 950.0,
        sellingPrice: 1450.0,
        mrp: 1600.0,
        currentStock: 190,
        minimumStock: 50,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 2 - Bay D',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 270)),
        iconCode: 'nuts',
      ),
      ProductModel(
        id: 'PRD-010',
        name: 'Macadamia Nuts (Dry Roasted & Sea Salted)',
        sku: 'NUT-MAC-010',
        barcode: '890123400205',
        category: 'Nuts',
        brand: 'Al Rabee Gourmet',
        origin: 'Australia / Hawaii',
        unit: 'kg',
        purchasePrice: 2200.0,
        sellingPrice: 3400.0,
        mrp: 3800.0,
        currentStock: 45,
        minimumStock: 15,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 2 - Bay E',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 240)),
        iconCode: 'nuts',
      ),
      ProductModel(
        id: 'PRD-011',
        name: 'Pine Nuts / Chilgoza (Wild Harvested)',
        sku: 'NUT-PIN-011',
        barcode: '890123400206',
        category: 'Nuts',
        brand: 'Al Rabee Reserve',
        origin: 'Afghanistan / Kashmir',
        unit: 'kg',
        purchasePrice: 4800.0,
        sellingPrice: 7200.0,
        mrp: 7800.0,
        currentStock: 12, // LOW STOCK
        minimumStock: 15,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 2 - Bay F',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 360)),
        iconCode: 'nuts',
      ),

      // Dry Fruits
      ProductModel(
        id: 'PRD-012',
        name: 'Afghan Giant Golden Figs (Anjeer Jumbo)',
        sku: 'DRY-FIG-012',
        barcode: '890123400301',
        category: 'Dry Fruits',
        brand: 'Al Rabee Reserve',
        origin: 'Afghanistan - Kandahar',
        unit: 'kg',
        purchasePrice: 1500.0,
        sellingPrice: 2350.0,
        mrp: 2600.0,
        currentStock: 110,
        minimumStock: 30,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 3 - Bay A',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        iconCode: 'dryfruit',
      ),
      ProductModel(
        id: 'PRD-013',
        name: 'Turkish Sun-Dried Golden Apricots',
        sku: 'DRY-APR-013',
        barcode: '890123400302',
        category: 'Dry Fruits',
        brand: 'Al Rabee Select',
        origin: 'Turkey - Malatya',
        unit: 'kg',
        purchasePrice: 720.0,
        sellingPrice: 1150.0,
        mrp: 1300.0,
        currentStock: 165,
        minimumStock: 40,
        primaryWarehouse: 'Central Cold Chain Logistics Hub',
        rackLocation: 'Aisle 3 - Bay B',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 280)),
        iconCode: 'dryfruit',
      ),
      ProductModel(
        id: 'PRD-014',
        name: 'Wild Whole Dried Blueberries',
        sku: 'DRY-BLU-014',
        barcode: '890123400303',
        category: 'Dry Fruits',
        brand: 'Al Rabee Gourmet',
        origin: 'USA / Canada',
        unit: 'kg',
        purchasePrice: 1400.0,
        sellingPrice: 2200.0,
        mrp: 2450.0,
        currentStock: 75,
        minimumStock: 25,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 3 - Bay C',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 360)),
        iconCode: 'dryfruit',
      ),
      ProductModel(
        id: 'PRD-015',
        name: 'Premium Ruby Cranberries (Sliced & Infused)',
        sku: 'DRY-CRN-015',
        barcode: '890123400304',
        category: 'Dry Fruits',
        brand: 'Al Rabee Classics',
        origin: 'USA',
        unit: 'kg',
        purchasePrice: 650.0,
        sellingPrice: 980.0,
        mrp: 1100.0,
        currentStock: 220,
        minimumStock: 50,
        primaryWarehouse: 'Central Cold Chain Logistics Hub',
        rackLocation: 'Aisle 3 - Bay D',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 360)),
        iconCode: 'dryfruit',
      ),

      // Chocolates
      ProductModel(
        id: 'PRD-016',
        name: 'Belgian Artisan Dark Chocolate Truffles 70%',
        sku: 'CHO-BEL-016',
        barcode: '890123400401',
        category: 'Chocolates',
        brand: 'Al Rabee Maison du Chocolat',
        origin: 'Belgium',
        unit: 'box',
        purchasePrice: 950.0,
        sellingPrice: 1650.0,
        mrp: 1850.0,
        currentStock: 68,
        minimumStock: 20,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 4 - Cold Bay A',
        taxRate: 18.0,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        iconCode: 'chocolate',
      ),
      ProductModel(
        id: 'PRD-017',
        name: 'Swiss Pralines Assorted Royal Box 500g',
        sku: 'CHO-SWI-017',
        barcode: '890123400402',
        category: 'Chocolates',
        brand: 'Al Rabee Maison du Chocolat',
        origin: 'Switzerland',
        unit: 'box',
        purchasePrice: 1450.0,
        sellingPrice: 2450.0,
        mrp: 2750.0,
        currentStock: 54,
        minimumStock: 15,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 4 - Cold Bay B',
        taxRate: 18.0,
        expiryDate: DateTime.now().add(const Duration(days: 210)),
        iconCode: 'chocolate',
      ),
      ProductModel(
        id: 'PRD-018',
        name: 'Gourmet Almond-Stuffed Chocolate Dates 1kg',
        sku: 'CHO-DAT-018',
        barcode: '890123400403',
        category: 'Chocolates',
        brand: 'Al Rabee Signature',
        origin: 'Dubai / UAE',
        unit: 'box',
        purchasePrice: 1100.0,
        sellingPrice: 1850.0,
        mrp: 2100.0,
        currentStock: 120,
        minimumStock: 30,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 4 - Cold Bay C',
        taxRate: 18.0,
        expiryDate: DateTime.now().add(const Duration(days: 150)),
        iconCode: 'chocolate',
      ),

      // Juices & Beverages
      ProductModel(
        id: 'PRD-019',
        name: 'Pure Cold-Pressed Pomegranate Nectar 750ml',
        sku: 'JUC-POM-019',
        barcode: '890123400501',
        category: 'Juices',
        brand: 'Al Rabee Pure',
        origin: 'Spain / Turkey',
        unit: 'bottle',
        purchasePrice: 280.0,
        sellingPrice: 480.0,
        mrp: 550.0,
        currentStock: 160,
        minimumStock: 40,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 5 - Bay A',
        taxRate: 12.0,
        expiryDate: DateTime.now().add(const Duration(days: 90)),
        iconCode: 'juice',
      ),
      ProductModel(
        id: 'PRD-020',
        name: 'Sparkling White Grape & Saffron Nectar 750ml',
        sku: 'JUC-GRP-020',
        barcode: '890123400502',
        category: 'Juices',
        brand: 'Al Rabee Pure',
        origin: 'France',
        unit: 'bottle',
        purchasePrice: 380.0,
        sellingPrice: 650.0,
        mrp: 750.0,
        currentStock: 85,
        minimumStock: 25,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 5 - Bay B',
        taxRate: 12.0,
        expiryDate: DateTime.now().add(const Duration(days: 120)),
        iconCode: 'juice',
      ),

      // Imported Fruits
      ProductModel(
        id: 'PRD-021',
        name: 'Japanese Ruby Roman & Shine Muscat Grapes',
        sku: 'FRU-JAP-021',
        barcode: '890123400601',
        category: 'Imported Fruits',
        brand: 'Al Rabee Fresh Air-Freight',
        origin: 'Japan - Yamanashi',
        unit: 'box',
        purchasePrice: 3200.0,
        sellingPrice: 4800.0,
        mrp: 5200.0,
        currentStock: 14, // LOW STOCK
        minimumStock: 15,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Chilled Fruit Bay 1',
        taxRate: 0.0,
        expiryDate: DateTime.now().add(const Duration(days: 8)),
        iconCode: 'fruit',
      ),
      ProductModel(
        id: 'PRD-022',
        name: 'Hass Avocados (Air-Flown Grade A)',
        sku: 'FRU-AVO-022',
        barcode: '890123400602',
        category: 'Imported Fruits',
        brand: 'Al Rabee Fresh Air-Freight',
        origin: 'Peru / Mexico',
        unit: 'kg',
        purchasePrice: 480.0,
        sellingPrice: 750.0,
        mrp: 850.0,
        currentStock: 180,
        minimumStock: 40,
        primaryWarehouse: 'Airport Cargo Fast-Fulfillment Hub',
        rackLocation: 'Chilled Fruit Bay 2',
        taxRate: 0.0,
        expiryDate: DateTime.now().add(const Duration(days: 12)),
        iconCode: 'fruit',
      ),
      ProductModel(
        id: 'PRD-023',
        name: 'Red Vietnamese Dragon Fruit (Pitaya)',
        sku: 'FRU-DRA-023',
        barcode: '890123400603',
        category: 'Imported Fruits',
        brand: 'Al Rabee Fresh Air-Freight',
        origin: 'Vietnam',
        unit: 'kg',
        purchasePrice: 220.0,
        sellingPrice: 380.0,
        mrp: 450.0,
        currentStock: 240,
        minimumStock: 50,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Chilled Fruit Bay 3',
        taxRate: 0.0,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        iconCode: 'fruit',
      ),

      // Packaged Delicacies
      ProductModel(
        id: 'PRD-024',
        name: 'Pure Kashmiri Super Negin Saffron 5g',
        sku: 'DEL-SAF-024',
        barcode: '890123400701',
        category: 'Packaged Delicacies',
        brand: 'Al Rabee Royal Gold',
        origin: 'Kashmir - Pampore',
        unit: 'box',
        purchasePrice: 1400.0,
        sellingPrice: 2250.0,
        mrp: 2500.0,
        currentStock: 80,
        minimumStock: 20,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Vault Section A',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 700)),
        iconCode: 'delicacy',
      ),
      ProductModel(
        id: 'PRD-025',
        name: 'Yemeni Sidr Do\'ani Raw Organic Honey 500g',
        sku: 'DEL-HNY-025',
        barcode: '890123400702',
        category: 'Packaged Delicacies',
        brand: 'Al Rabee Reserve',
        origin: 'Yemen - Hadramaut',
        unit: 'bottle',
        purchasePrice: 3100.0,
        sellingPrice: 4900.0,
        mrp: 5500.0,
        currentStock: 32,
        minimumStock: 10,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Vault Section B',
        taxRate: 5.0,
        expiryDate: DateTime.now().add(const Duration(days: 900)),
        iconCode: 'delicacy',
      ),
      ProductModel(
        id: 'PRD-026',
        name: 'Turkish Gaziantep Pistachio Baklava Luxury Tin 1kg',
        sku: 'DEL-BAK-026',
        barcode: '890123400703',
        category: 'Packaged Delicacies',
        brand: 'Al Rabee Sultan',
        origin: 'Turkey - Gaziantep',
        unit: 'box',
        purchasePrice: 1600.0,
        sellingPrice: 2750.0,
        mrp: 3000.0,
        currentStock: 50,
        minimumStock: 15,
        primaryWarehouse: 'Main Flagship Showroom & Storage',
        rackLocation: 'Aisle 6 - Bay A',
        taxRate: 18.0,
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        iconCode: 'delicacy',
      ),
    ]);

    // 3. Customers (20+ realistic Al Rabee clients)
    _customers.addAll([
      CustomerModel(
        id: 'CUST-001',
        name: 'Dr. Tariq Al-Mansoor',
        company: 'Mansoor Medical Group',
        phone: '+91 98201 44521',
        email: 'tariq.mansoor@mansoormed.com',
        address: 'Villa 14, Sea Face Towers, Worli',
        city: 'Mumbai',
        gstin: '27AABCM9102K1Z5',
        totalPurchases: 384500.0,
        outstandingBalance: 0.0,
        creditLimit: 150000.0,
        totalOrders: 18,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        tier: 'VIP Client',
      ),
      CustomerModel(
        id: 'CUST-002',
        name: 'The Oberoi Luxury Banquets',
        company: 'Oberoi Hotels & Resorts',
        phone: '+91 98110 88231',
        email: 'procurement.banquets@oberoihotels.com',
        address: 'Nariman Point Waterfront',
        city: 'Mumbai',
        gstin: '27AAACT2819P1ZU',
        totalPurchases: 1420000.0,
        outstandingBalance: 125000.0,
        creditLimit: 500000.0,
        totalOrders: 42,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 4)),
        tier: 'Corporate',
      ),
      CustomerModel(
        id: 'CUST-003',
        name: 'Aisha Siddiqui',
        company: 'Siddiqui Interiors',
        phone: '+91 98334 11290',
        email: 'aisha.siddiqui@gmail.com',
        address: 'Palm Crest, 16th Road, Khar West',
        city: 'Mumbai',
        totalPurchases: 128400.0,
        outstandingBalance: 0.0,
        creditLimit: 50000.0,
        totalOrders: 9,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 6)),
        tier: 'Retail',
      ),
      CustomerModel(
        id: 'CUST-004',
        name: 'Vikram & Radhika Malhotra',
        company: 'Malhotra Capital',
        phone: '+91 99200 77123',
        email: 'v.malhotra@malhotracap.in',
        address: 'Penthouse B, Altamount Road',
        city: 'Mumbai',
        totalPurchases: 540000.0,
        outstandingBalance: 45000.0,
        creditLimit: 200000.0,
        totalOrders: 24,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 1)),
        tier: 'VIP Client',
      ),
      CustomerModel(
        id: 'CUST-005',
        name: 'Gourmet Central Retail Chain',
        company: 'GC Supermarkets LLP',
        phone: '+91 97690 33412',
        email: 'orders@gourmetcentral.in',
        address: 'Logistics Park, Kurla West',
        city: 'Mumbai',
        gstin: '27AALCG5582M1Z0',
        totalPurchases: 2890000.0,
        outstandingBalance: 340000.0,
        creditLimit: 1000000.0,
        totalOrders: 65,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 3)),
        tier: 'Wholesale',
      ),
      CustomerModel(
        id: 'CUST-006',
        name: 'Farah Khan Gifting Studio',
        company: 'FK Luxury Hampers',
        phone: '+91 98212 90817',
        email: 'gifting@farahkhan.co.in',
        address: 'Bungalow 9, Juhu Tara Road',
        city: 'Mumbai',
        totalPurchases: 780000.0,
        outstandingBalance: 0.0,
        creditLimit: 250000.0,
        totalOrders: 31,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 8)),
        tier: 'Corporate',
      ),
      CustomerModel(
        id: 'CUST-007',
        name: 'Zameer Merchant',
        company: 'Merchant Shipping Ltd',
        phone: '+91 98205 66781',
        email: 'zameer@merchantshipping.com',
        address: 'Cuffe Parade Heights',
        city: 'Mumbai',
        totalPurchases: 215000.0,
        outstandingBalance: 18500.0,
        creditLimit: 100000.0,
        totalOrders: 14,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        tier: 'VIP Client',
      ),
      CustomerModel(
        id: 'CUST-008',
        name: 'Royal Emirates Gifting Concierge',
        company: 'Royal Emirates LLC',
        phone: '+971 50 1234567',
        email: 'procurement@royalemirates.ae',
        address: 'Sheikh Zayed Road, Financial Centre',
        city: 'Dubai',
        totalPurchases: 4500000.0,
        outstandingBalance: 210000.0,
        creditLimit: 1500000.0,
        totalOrders: 52,
        lastPurchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        tier: 'Corporate',
      ),
    ]);

    // 4. Suppliers (International & Domestic)
    _suppliers.addAll([
      SupplierModel(
        id: 'SUP-001',
        name: 'Madina Dates Agriculture Establishment',
        contactPerson: 'Sheikh Abdulrahman Al-Harbi',
        phone: '+966 50 987 6543',
        email: 'export@madinadates.sa',
        country: 'Saudi Arabia',
        address: 'King Abdulaziz Road, Madina Al-Munawwarah',
        categorySpecialty: 'Ajwa, Safawi, Mabroom Dates',
        totalPurchased: 4850000.0,
        outstandingPayable: 420000.0,
        totalOrders: 28,
        rating: 4.9,
      ),
      SupplierModel(
        id: 'SUP-002',
        name: 'Khorasan Pistachio & Mamra Export Syndicate',
        contactPerson: 'Morteza Hosseini',
        phone: '+98 912 345 6789',
        email: 'trade@khorasanpistachio.ir',
        country: 'Iran',
        address: 'Boulevard Jomhuri, Rafsanjan, Kerman',
        categorySpecialty: 'Mamra Almonds & Super Green Pistachios',
        totalPurchased: 6200000.0,
        outstandingPayable: 650000.0,
        totalOrders: 34,
        rating: 4.9,
      ),
      SupplierModel(
        id: 'SUP-003',
        name: 'Belgian Choco Crafts SPRL',
        contactPerson: 'Marc Van Damme',
        phone: '+32 3 234 5678',
        email: 'orders@belgianchococrafts.be',
        country: 'Belgium',
        address: 'Havenlaan 86, Antwerp',
        categorySpecialty: 'Artisan Truffles & Couverture Chocolate',
        totalPurchased: 2100000.0,
        outstandingPayable: 180000.0,
        totalOrders: 16,
        rating: 4.8,
      ),
      SupplierModel(
        id: 'SUP-004',
        name: 'Kashmir Valley Organic Growers',
        contactPerson: 'Bashir Ahmed Mir',
        phone: '+91 94190 22345',
        email: 'bashir@kashmirsaffronvalley.in',
        country: 'India',
        address: 'National Highway 44, Pampore, Pulwama',
        categorySpecialty: 'Super Negin Saffron & Kashmiri Walnuts',
        totalPurchased: 1850000.0,
        outstandingPayable: 0.0,
        totalOrders: 22,
        rating: 4.9,
      ),
      SupplierModel(
        id: 'SUP-005',
        name: 'Anatolia Malatya Dry Fruits A.S.',
        contactPerson: 'Emre Yilmaz',
        phone: '+90 422 321 4567',
        email: 'sales@anatoliamalatya.com.tr',
        country: 'Turkey',
        address: 'Organize Sanayi Bolgesi, Malatya',
        categorySpecialty: 'Sun-dried Apricots, Figs & Baklava',
        totalPurchased: 1450000.0,
        outstandingPayable: 95000.0,
        totalOrders: 14,
        rating: 4.7,
      ),
    ]);

    // 5. CRM Leads
    _leads.addAll([
      LeadModel(
        id: 'LEAD-001',
        name: 'Kabir Singhania',
        company: 'Singhania Diamonds',
        phone: '+91 98200 11990',
        email: 'kabir@singhaniadiamonds.com',
        source: 'Corporate Inquiry',
        estimatedValue: 450000.0,
        assignedTo: 'Zaid Ansari',
        stage: LeadStage.proposal,
        nextFollowUp: DateTime.now().add(const Duration(days: 1)),
        notes: 'Requested 250 bespoke luxury wooden boxes with Ajwa & Mamra Almonds for Diwali/New Year executive gifting.',
        interestedCategory: 'Dates & Dry Fruits Hampers',
      ),
      LeadModel(
        id: 'LEAD-002',
        name: 'Fatima Al-Sabah',
        company: 'Kuwait International Banquets',
        phone: '+965 9988 7766',
        email: 'fatima@al-sabah.kw',
        source: 'Website',
        estimatedValue: 1200000.0,
        assignedTo: 'Suhail Mansoori',
        stage: LeadStage.negotiation,
        nextFollowUp: DateTime.now().add(const Duration(days: 2)),
        notes: 'Bulk air cargo order of Medjool Dates and Pure Saffron.',
        interestedCategory: 'Dates & Delicacies',
      ),
      LeadModel(
        id: 'LEAD-003',
        name: 'Rajeev Mehra',
        company: 'Mehra Financial Advisory',
        phone: '+91 98190 33214',
        email: 'rajeev@mehrafin.in',
        source: 'Referral',
        estimatedValue: 180000.0,
        assignedTo: 'Zaid Ansari',
        stage: LeadStage.qualified,
        nextFollowUp: DateTime.now().add(const Duration(days: 3)),
        notes: 'Client onboarding welcome gift boxes.',
        interestedCategory: 'Chocolates & Nuts',
      ),
      LeadModel(
        id: 'LEAD-004',
        name: 'Leela Palace Hotel Procurement',
        company: 'The Leela Palaces',
        phone: '+91 98330 45678',
        email: 'chef.pantry@theleela.com',
        source: 'Trade Fair',
        estimatedValue: 850000.0,
        assignedTo: 'Suhail Mansoori',
        stage: LeadStage.contacted,
        nextFollowUp: DateTime.now().add(const Duration(hours: 18)),
        notes: 'Interested in daily fruit delivery and dessert nuts supply.',
        interestedCategory: 'Imported Fruits & Nuts',
      ),
      LeadModel(
        id: 'LEAD-005',
        name: 'Ananya Deshmukh',
        company: 'Deshmukh Wedding Planners',
        phone: '+91 99201 88762',
        email: 'ananya@royalweddings.in',
        source: 'Walk-in',
        estimatedValue: 650000.0,
        assignedTo: 'Imran Shaikh',
        stage: LeadStage.won,
        nextFollowUp: DateTime.now().add(const Duration(days: 10)),
        notes: 'Order confirmed for 500 Royal Date & Belgian Chocolate boxes.',
        interestedCategory: 'Dates & Chocolates',
      ),
    ]);

    // 6. Invoices & Sales
    _seedInvoices();

    // 7. Purchase Orders
    _seedPurchaseOrders();

    // 8. Accounting & Financial Transactions
    _seedTransactions();

    // 9. HR Employees & Attendance
    _seedHrData();

    // 10. Projects & Tasks
    _seedProjects();

    // 11. Notifications
    _seedNotifications();

    // 12. Users & Demo Accounts
    _seedUsers();

    // 13. Audit Logs
    _seedAuditLogs();
  }

  void _seedInvoices() {
    final now = DateTime.now();

    _invoices.addAll([
      InvoiceModel(
        id: 'INV-001',
        invoiceNumber: 'INV-2026-00142',
        customerId: 'CUST-001',
        customerName: 'Dr. Tariq Al-Mansoor',
        customerPhone: '+91 98201 44521',
        customerEmail: 'tariq.mansoor@mansoormed.com',
        customerAddress: 'Villa 14, Sea Face Towers, Worli, Mumbai',
        customerGstin: '27AABCM9102K1Z5',
        invoiceDate: now.subtract(const Duration(hours: 3)),
        dueDate: now.add(const Duration(days: 15)),
        items: [
          InvoiceItem(
            productId: 'PRD-001',
            productName: 'Royal Ajwa Dates (Madina Al-Munawwarah)',
            sku: 'DAT-AJW-001',
            quantity: 5,
            unitPrice: 2450.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-006',
            productName: 'Mamra Almonds (Iranian Super Kernel)',
            sku: 'NUT-MAM-006',
            quantity: 3,
            unitPrice: 3600.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-024',
            productName: 'Pure Kashmiri Super Negin Saffron 5g',
            sku: 'DEL-SAF-024',
            quantity: 2,
            unitPrice: 2250.0,
            taxPercent: 5.0,
          ),
        ],
        amountPaid: 29000.0,
        paymentStatus: PaymentStatus.paid,
        salesStatus: SalesStatus.completed,
        salesPerson: 'Zaid Ansari',
        paymentMethod: 'UPI / GPay',
        paymentHistory: [
          PaymentRecord(
            id: 'PAY-001',
            invoiceId: 'INV-001',
            amount: 29000.0,
            paymentMethod: 'UPI / GPay',
            referenceNumber: 'UPI/2026/89124401',
            paymentDate: now.subtract(const Duration(hours: 3)),
            receivedBy: 'Zaid Ansari',
            notes: 'Received via Flagship Counter Scanner',
          )
        ],
      ),
      InvoiceModel(
        id: 'INV-002',
        invoiceNumber: 'INV-2026-00141',
        customerId: 'CUST-002',
        customerName: 'The Oberoi Luxury Banquets',
        customerPhone: '+91 98110 88231',
        customerEmail: 'procurement.banquets@oberoihotels.com',
        customerAddress: 'Nariman Point Waterfront, Mumbai',
        customerGstin: '27AAACT2819P1ZU',
        invoiceDate: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 28)),
        items: [
          InvoiceItem(
            productId: 'PRD-002',
            productName: 'Jumbo Medjool Dates (King of Dates)',
            sku: 'DAT-MED-002',
            quantity: 40,
            unitPrice: 1850.0,
            discountPercent: 5.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-016',
            productName: 'Belgian Artisan Dark Chocolate Truffles 70%',
            sku: 'CHO-BEL-016',
            quantity: 30,
            unitPrice: 1650.0,
            taxPercent: 18.0,
          ),
        ],
        amountPaid: 0.0,
        paymentStatus: PaymentStatus.unpaid,
        salesStatus: SalesStatus.confirmed,
        salesPerson: 'Suhail Mansoori',
        paymentMethod: 'Bank Transfer (30 Days)',
      ),
      InvoiceModel(
        id: 'INV-003',
        invoiceNumber: 'INV-2026-00140',
        customerId: 'CUST-004',
        customerName: 'Vikram & Radhika Malhotra',
        customerPhone: '+91 99200 77123',
        customerEmail: 'v.malhotra@malhotracap.in',
        customerAddress: 'Penthouse B, Altamount Road, Mumbai',
        invoiceDate: now.subtract(const Duration(days: 3)),
        dueDate: now.subtract(const Duration(days: 1)), // OVERDUE
        items: [
          InvoiceItem(
            productId: 'PRD-025',
            productName: 'Yemeni Sidr Do\'ani Raw Organic Honey 500g',
            sku: 'DEL-HNY-025',
            quantity: 4,
            unitPrice: 4900.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-011',
            productName: 'Pine Nuts / Chilgoza (Wild Harvested)',
            sku: 'NUT-PIN-011',
            quantity: 3,
            unitPrice: 7200.0,
            taxPercent: 5.0,
          ),
        ],
        amountPaid: 20000.0,
        paymentStatus: PaymentStatus.partial,
        salesStatus: SalesStatus.completed,
        salesPerson: 'Imran Shaikh',
        paymentMethod: 'Credit Card',
        paymentHistory: [
          PaymentRecord(
            id: 'PAY-002',
            invoiceId: 'INV-003',
            amount: 20000.0,
            paymentMethod: 'Credit Card',
            referenceNumber: 'HDFC-POS-7821',
            paymentDate: now.subtract(const Duration(days: 3)),
            receivedBy: 'Imran Shaikh',
            notes: 'Advance swipe at billing counter',
          )
        ],
      ),
      InvoiceModel(
        id: 'INV-004',
        invoiceNumber: 'INV-2026-00139',
        customerId: 'CUST-003',
        customerName: 'Aisha Siddiqui',
        customerPhone: '+91 98334 11290',
        customerEmail: 'aisha.siddiqui@gmail.com',
        customerAddress: 'Palm Crest, Khar West, Mumbai',
        invoiceDate: now.subtract(const Duration(days: 4)),
        dueDate: now.add(const Duration(days: 10)),
        items: [
          InvoiceItem(
            productId: 'PRD-012',
            productName: 'Afghan Giant Golden Figs (Anjeer Jumbo)',
            sku: 'DRY-FIG-012',
            quantity: 3,
            unitPrice: 2350.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-019',
            productName: 'Pure Cold-Pressed Pomegranate Nectar 750ml',
            sku: 'JUC-POM-019',
            quantity: 6,
            unitPrice: 480.0,
            taxPercent: 12.0,
          ),
        ],
        amountPaid: 10500.0,
        paymentStatus: PaymentStatus.paid,
        salesStatus: SalesStatus.completed,
        salesPerson: 'Zaid Ansari',
        paymentMethod: 'Cash',
      ),
    ]);

    // Quotations
    _quotations.addAll([
      QuotationModel(
        id: 'QTN-001',
        quotationNumber: 'QTN-2026-0048',
        customerId: 'CUST-006',
        customerName: 'Farah Khan Gifting Studio',
        customerPhone: '+91 98212 90817',
        date: now.subtract(const Duration(days: 1)),
        validUntil: now.add(const Duration(days: 14)),
        items: [
          InvoiceItem(
            productId: 'PRD-001',
            productName: 'Royal Ajwa Dates (Madina Al-Munawwarah)',
            sku: 'DAT-AJW-001',
            quantity: 100,
            unitPrice: 2450.0,
            discountPercent: 10.0,
            taxPercent: 5.0,
          ),
          InvoiceItem(
            productId: 'PRD-026',
            productName: 'Turkish Gaziantep Pistachio Baklava Luxury Tin 1kg',
            sku: 'DEL-BAK-026',
            quantity: 100,
            unitPrice: 2750.0,
            discountPercent: 8.0,
            taxPercent: 18.0,
          ),
        ],
        status: 'Sent',
        createdBy: 'Suhail Mansoori',
        notes: 'Special wedding season quotation with bespoke packaging.',
      )
    ]);
  }

  void _seedPurchaseOrders() {
    final now = DateTime.now();

    _purchaseOrders.addAll([
      PurchaseOrderModel(
        id: 'PO-001',
        poNumber: 'PO-2026-0038',
        supplierId: 'SUP-001',
        supplierName: 'Madina Dates Agriculture Establishment',
        supplierCountry: 'Saudi Arabia',
        orderDate: now.subtract(const Duration(days: 7)),
        expectedDeliveryDate: now.add(const Duration(days: 5)),
        items: [
          PurchaseItem(
            productId: 'PRD-001',
            productName: 'Royal Ajwa Dates (Madina Al-Munawwarah)',
            sku: 'DAT-AJW-001',
            quantity: 250,
            unitCost: 1650.0,
            taxPercent: 5.0,
          ),
          PurchaseItem(
            productId: 'PRD-005',
            productName: 'Mabroom Premium Slender Dates',
            sku: 'DAT-MAB-005',
            quantity: 150,
            unitCost: 980.0,
            taxPercent: 5.0,
          ),
        ],
        shippingFee: 25000.0,
        status: PurchaseStatus.ordered,
        destinationWarehouse: 'Central Cold Chain Logistics Hub',
        paymentTerms: '50% Advance, 50% on Delivery',
        requestedBy: 'Farhan Qureshi',
        approvedBy: 'Suhail Mansoori',
        notes: 'Direct refrigerated container via Jeddah - JNPT sea route.',
      ),
      PurchaseOrderModel(
        id: 'PO-002',
        poNumber: 'PO-2026-0037',
        supplierId: 'SUP-002',
        supplierName: 'Khorasan Pistachio & Mamra Export Syndicate',
        supplierCountry: 'Iran',
        orderDate: now.subtract(const Duration(days: 14)),
        expectedDeliveryDate: now.subtract(const Duration(days: 2)),
        items: [
          PurchaseItem(
            productId: 'PRD-006',
            productName: 'Mamra Almonds (Iranian Super Kernel)',
            sku: 'NUT-MAM-006',
            quantity: 100,
            receivedQuantity: 100,
            unitCost: 2400.0,
            taxPercent: 5.0,
          ),
          PurchaseItem(
            productId: 'PRD-007',
            productName: 'Iranian Super Green Pistachios (Pistachio Kernels)',
            sku: 'NUT-PST-007',
            quantity: 80,
            receivedQuantity: 80,
            unitCost: 2800.0,
            taxPercent: 5.0,
          ),
        ],
        status: PurchaseStatus.completed,
        destinationWarehouse: 'Main Flagship Showroom & Storage',
        paymentTerms: 'Letter of Credit',
        requestedBy: 'Farhan Qureshi',
        approvedBy: 'Suhail Mansoori',
      ),
    ]);
  }

  void _seedTransactions() {
    final now = DateTime.now();

    _transactions.addAll([
      TransactionRecord(
        id: 'TXN-001',
        referenceNumber: 'TXN-2026-0914',
        type: TransactionType.income,
        category: 'Flagship Showroom POS Sales',
        title: 'Daily Counter Collection (Cash & UPI)',
        amount: 85420.0,
        paymentAccount: 'HDFC Flagship Current A/C',
        partyName: 'Walk-in Retail Clients',
        date: now.subtract(const Duration(hours: 2)),
      ),
      TransactionRecord(
        id: 'TXN-002',
        referenceNumber: 'TXN-2026-0913',
        type: TransactionType.customerPayment,
        category: 'Corporate Receivables',
        title: 'Invoice Payment Received — INV-2026-00138',
        amount: 145000.0,
        paymentAccount: 'HDFC Flagship Current A/C',
        partyName: 'The Oberoi Luxury Banquets',
        date: now.subtract(const Duration(days: 1)),
      ),
      TransactionRecord(
        id: 'TXN-003',
        referenceNumber: 'TXN-2026-0912',
        type: TransactionType.expense,
        category: ExpenseCategory.importCustoms.label,
        title: 'Customs Clearance & Import Duty (Dubai Air Cargo)',
        amount: 48500.0,
        paymentAccount: 'ICICI Export-Import A/C',
        partyName: 'Mumbai Customs Air Cargo Complex',
        date: now.subtract(const Duration(days: 2)),
      ),
      TransactionRecord(
        id: 'TXN-004',
        referenceNumber: 'TXN-2026-0911',
        type: TransactionType.expense,
        category: ExpenseCategory.coldChainStorage.label,
        title: 'Cold Storage Terminal Electric & Refrigeration Maintenance',
        amount: 32000.0,
        paymentAccount: 'HDFC Flagship Current A/C',
        partyName: 'Bhiwandi Cold Chain Services',
        date: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  void _seedHrData() {
    final now = DateTime.now();

    _employees.addAll([
      EmployeeModel(
        id: 'EMP-001',
        employeeCode: 'AR-DIR-001',
        name: 'Saajid Al-Rabee',
        designation: 'Managing Director & Founder',
        department: 'Executive',
        phone: '+91 98200 00001',
        email: 'saajid@alrabee.com',
        basicSalary: 250000.0,
        allowances: 50000.0,
        joiningDate: DateTime(2020, 1, 15),
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      ),
      EmployeeModel(
        id: 'EMP-002',
        employeeCode: 'AR-MGR-002',
        name: 'Suhail Mansoori',
        designation: 'General Operations Manager',
        department: 'Executive',
        phone: '+91 98201 12345',
        email: 'suhail@alrabee.com',
        basicSalary: 95000.0,
        allowances: 15000.0,
        joiningDate: DateTime(2021, 3, 10),
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      ),
      EmployeeModel(
        id: 'EMP-003',
        employeeCode: 'AR-SAL-003',
        name: 'Zaid Ansari',
        designation: 'Senior Sales Executive & Sommelier',
        department: 'Retail Sales',
        phone: '+91 98202 23456',
        email: 'zaid@alrabee.com',
        basicSalary: 45000.0,
        allowances: 10000.0,
        joiningDate: DateTime(2022, 6, 1),
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      ),
      EmployeeModel(
        id: 'EMP-004',
        employeeCode: 'AR-LOG-004',
        name: 'Farhan Qureshi',
        designation: 'Head of Inventory & Logistics',
        department: 'Warehouse & Logistics',
        phone: '+91 98203 34567',
        email: 'farhan@alrabee.com',
        basicSalary: 55000.0,
        allowances: 8000.0,
        joiningDate: DateTime(2021, 8, 15),
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
      ),
      EmployeeModel(
        id: 'EMP-005',
        employeeCode: 'AR-ACC-005',
        name: 'Nadia Merchant',
        designation: 'Chief Accountant & Tax Auditor',
        department: 'Accounts & Finance',
        phone: '+91 98204 45678',
        email: 'nadia@alrabee.com',
        basicSalary: 65000.0,
        allowances: 10000.0,
        joiningDate: DateTime(2021, 11, 1),
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      ),
      EmployeeModel(
        id: 'EMP-006',
        employeeCode: 'AR-HRM-006',
        name: 'Rashida Kapadia',
        designation: 'HR & Talent Manager',
        department: 'HR & Administration',
        phone: '+91 98205 56789',
        email: 'rashida@alrabee.com',
        basicSalary: 52000.0,
        allowances: 7000.0,
        joiningDate: DateTime(2022, 1, 10),
        avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      ),
    ]);

    // Attendance
    for (var emp in _employees) {
      _attendance.add(AttendanceRecord(
        id: 'ATT-${emp.id}',
        employeeId: emp.id,
        employeeName: emp.name,
        date: now,
        checkIn: '08:58 AM',
        checkOut: null,
        status: AttendanceStatus.present,
      ));
    }

    // Leave Requests
    _leaveRequests.addAll([
      LeaveRequest(
        id: 'LEV-001',
        employeeId: 'EMP-003',
        employeeName: 'Zaid Ansari',
        leaveType: 'Annual Vacation',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 14)),
        totalDays: 5,
        reason: 'Family pilgrimage trip to Madina',
        status: LeaveStatus.pending,
        appliedOn: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void _seedProjects() {
    final now = DateTime.now();

    _projects.addAll([
      ProjectModel(
        id: 'PRJ-001',
        title: 'Ramadan & Eid Royal Gifting Catalog 2026',
        category: 'Seasonal Campaign',
        client: 'Al Rabee Luxury Retail & VIPs',
        manager: 'Suhail Mansoori',
        progress: 0.75,
        startDate: now.subtract(const Duration(days: 20)),
        deadline: now.add(const Duration(days: 15)),
        budget: 450000.0,
        status: 'In Progress',
        tasks: [
          ProjectTask(
            id: 'TSK-101',
            projectId: 'PRJ-001',
            title: 'Design custom embossed velvet and walnut wooden date gift boxes',
            description: 'Finalize gold foil calligraphy and dimensions for 1kg and 2kg sets',
            assignedTo: 'Suhail Mansoori',
            status: TaskStatus.completed,
            priority: TaskPriority.high,
            dueDate: now.subtract(const Duration(days: 5)),
          ),
          ProjectTask(
            id: 'TSK-102',
            projectId: 'PRJ-001',
            title: 'Confirm import consignment of fresh Madina Ajwa & Royal Medjool',
            description: 'Coordinate cold storage space with Bhiwandi logistics hub',
            assignedTo: 'Farhan Qureshi',
            status: TaskStatus.inProgress,
            priority: TaskPriority.urgent,
            dueDate: now.add(const Duration(days: 2)),
          ),
          ProjectTask(
            id: 'TSK-103',
            projectId: 'PRJ-001',
            title: 'Launch corporate tasting preview for top 50 corporate clients',
            description: 'Host private evening tasting at Flagship Showroom',
            assignedTo: 'Zaid Ansari',
            status: TaskStatus.todo,
            priority: TaskPriority.medium,
            dueDate: now.add(const Duration(days: 8)),
          ),
        ],
      ),
      ProjectModel(
        id: 'PRJ-002',
        title: 'New Flagship Boutique Launch — BKC Promenade',
        category: 'Store Expansion',
        client: 'Al Rabee Brands',
        manager: 'Suhail Mansoori',
        progress: 0.40,
        startDate: now.subtract(const Duration(days: 35)),
        deadline: now.add(const Duration(days: 45)),
        budget: 2500000.0,
        status: 'In Progress',
        tasks: [
          ProjectTask(
            id: 'TSK-201',
            projectId: 'PRJ-002',
            title: 'Interior architectural woodwork & humidity-controlled display cabinets',
            description: 'Precision chillers for chocolates and fresh soft dates',
            assignedTo: 'Suhail Mansoori',
            status: TaskStatus.inProgress,
            priority: TaskPriority.high,
            dueDate: now.add(const Duration(days: 12)),
          ),
        ],
      ),
    ]);
  }

  void _seedNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      NotificationModel(
        id: 'NOT-001',
        title: 'Low Stock Alert: Jumbo Medjool Dates',
        message: 'Current stock is 28 kg (below minimum threshold of 35 kg).',
        category: NotificationCategory.inventory,
        timestamp: now.subtract(const Duration(minutes: 12)),
      ),
      NotificationModel(
        id: 'NOT-002',
        title: 'Large Sale Completed: INV-2026-00142',
        message: '₹29,000 received via UPI from Dr. Tariq Al-Mansoor.',
        category: NotificationCategory.sales,
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 'NOT-003',
        title: 'Purchase Order Approval Required: PO-2026-0038',
        message: 'Madina Dates consignment of ₹5.88L awaiting management sign-off.',
        category: NotificationCategory.purchases,
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'NOT-004',
        title: 'Air Freight Consignment Cleared',
        message: 'Japanese Shine Muscat Grapes shipment cleared at Mumbai Air Cargo.',
        category: NotificationCategory.system,
        timestamp: now.subtract(const Duration(hours: 8)),
      ),
    ]);
  }

  void _seedUsers() {
    _users.addAll([
      UserModel(
        id: 'USR-001',
        name: 'Super Admin (Saajid)',
        email: 'admin@alrabee.com',
        phone: '+91 98200 00001',
        role: UserRole.superAdmin,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        department: 'Executive Management',
      ),
      UserModel(
        id: 'USR-002',
        name: 'Store Manager (Suhail)',
        email: 'manager@alrabee.com',
        phone: '+91 98201 12345',
        role: UserRole.manager,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        department: 'Store Operations',
      ),
      UserModel(
        id: 'USR-003',
        name: 'Sales Staff (Zaid)',
        email: 'sales@alrabee.com',
        phone: '+91 98202 23456',
        role: UserRole.salesStaff,
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        department: 'Retail Sales',
      ),
      UserModel(
        id: 'USR-004',
        name: 'Inventory Manager (Farhan)',
        email: 'inventory@alrabee.com',
        phone: '+91 98203 34567',
        role: UserRole.inventoryManager,
        avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150',
        department: 'Warehouse & Logistics',
      ),
      UserModel(
        id: 'USR-005',
        name: 'Chief Accountant (Nadia)',
        email: 'accounts@alrabee.com',
        phone: '+91 98204 45678',
        role: UserRole.accountant,
        avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
        department: 'Finance & Taxation',
      ),
      UserModel(
        id: 'USR-006',
        name: 'HR Manager (Rashida)',
        email: 'hr@alrabee.com',
        phone: '+91 98205 56789',
        role: UserRole.hrManager,
        avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
        department: 'Human Resources',
      ),
    ]);
  }

  void _seedAuditLogs() {
    final now = DateTime.now();

    _auditLogs.addAll([
      AuditLogModel(
        id: 'AUD-001',
        user: 'Super Admin (Saajid)',
        role: 'Super Admin',
        action: 'SYSTEM_LOGIN',
        module: 'Authentication',
        details: 'Admin logged in from Enterprise Console',
        timestamp: now.subtract(const Duration(minutes: 35)),
      ),
      AuditLogModel(
        id: 'AUD-002',
        user: 'Zaid Ansari',
        role: 'Sales Staff',
        action: 'CREATE_INVOICE',
        module: 'Sales',
        details: 'Generated invoice INV-2026-00142 for Dr. Tariq Al-Mansoor (₹29,000)',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      AuditLogModel(
        id: 'AUD-003',
        user: 'Farhan Qureshi',
        role: 'Inventory Manager',
        action: 'STOCK_ADJUSTMENT',
        module: 'Inventory',
        details: 'Stock audit count updated for PRD-006 (Mamra Almonds)',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
    ]);
  }

  // --- REPOSITORY IMPLEMENTATIONS ---

  @override
  List<ProductModel> getProducts() => List.unmodifiable(_products);

  @override
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void saveProduct(ProductModel product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    } else {
      _products.insert(0, product);
    }
    logAudit('Admin', 'Super Admin', 'SAVE_PRODUCT', 'Products', 'Saved product ${product.name}');
  }

  @override
  void deleteProduct(String id) {
    final product = getProductById(id);
    if (product != null) {
      _products.removeWhere((p) => p.id == id);
      logAudit('Admin', 'Super Admin', 'DELETE_PRODUCT', 'Products', 'Deleted product ${product.name}');
    }
  }

  @override
  void adjustStock(String productId, int newQuantity, String reason, String warehouse, String user) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _products[index];
      final delta = newQuantity - product.currentStock;
      _products[index] = product.copyWith(currentStock: newQuantity);

      _stockMovements.insert(
        0,
        StockMovement(
          id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          productName: product.name,
          type: delta >= 0 ? StockMovementType.adjustment : StockMovementType.damage,
          quantity: delta.abs(),
          stockAfter: newQuantity,
          reference: 'ADJ-${DateTime.now().day}${DateTime.now().hour}',
          warehouse: warehouse,
          notes: reason,
          timestamp: DateTime.now(),
          performedBy: user,
        ),
      );

      logAudit(user, 'Inventory Manager', 'STOCK_ADJUSTMENT', 'Inventory',
          'Adjusted stock for ${product.name} to $newQuantity ($reason)');
    }
  }

  @override
  List<StockMovement> getStockMovements() => List.unmodifiable(_stockMovements);

  @override
  List<WarehouseModel> getWarehouses() => List.unmodifiable(_warehouses);

  @override
  List<CustomerModel> getCustomers() => List.unmodifiable(_customers);

  @override
  CustomerModel? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void saveCustomer(CustomerModel customer) {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    } else {
      _customers.insert(0, customer);
    }
    logAudit('Admin', 'Super Admin', 'SAVE_CUSTOMER', 'Customers', 'Saved customer ${customer.name}');
  }

  @override
  void deleteCustomer(String id) {
    final c = getCustomerById(id);
    if (c != null) {
      _customers.removeWhere((item) => item.id == id);
      logAudit('Admin', 'Super Admin', 'DELETE_CUSTOMER', 'Customers', 'Deleted customer ${c.name}');
    }
  }

  @override
  void addCustomerActivity(String customerId, CustomerActivity activity) {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final c = _customers[index];
      final updatedActivities = List<CustomerActivity>.from(c.activities)..insert(0, activity);
      _customers[index] = c.copyWith(activities: updatedActivities);
    }
  }

  @override
  List<SupplierModel> getSuppliers() => List.unmodifiable(_suppliers);

  @override
  SupplierModel? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void saveSupplier(SupplierModel supplier) {
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _suppliers[index] = supplier;
    } else {
      _suppliers.insert(0, supplier);
    }
    logAudit('Admin', 'Super Admin', 'SAVE_SUPPLIER', 'Suppliers', 'Saved supplier ${supplier.name}');
  }

  @override
  List<LeadModel> getLeads() => List.unmodifiable(_leads);

  @override
  void saveLead(LeadModel lead) {
    final index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _leads[index] = lead;
    } else {
      _leads.insert(0, lead);
    }
    logAudit('Sales', 'Sales Staff', 'SAVE_LEAD', 'CRM', 'Saved lead ${lead.name}');
  }

  @override
  void updateLeadStage(String leadId, LeadStage stage) {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final lead = _leads[index];
      _leads[index] = lead.copyWith(stage: stage);
      logAudit('Sales', 'Sales Staff', 'UPDATE_LEAD_STAGE', 'CRM',
          'Updated lead ${lead.name} stage to ${stage.label}');
    }
  }

  @override
  void deleteLead(String id) {
    _leads.removeWhere((l) => l.id == id);
  }

  @override
  List<InvoiceModel> getInvoices() => List.unmodifiable(_invoices);

  @override
  InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void createInvoice(InvoiceModel invoice) {
    _invoices.insert(0, invoice);

    // 1. Deduct Product Stock & Log Movements
    for (var item in invoice.items) {
      final productIndex = _products.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final p = _products[productIndex];
        final newStock = (p.currentStock - item.quantity).clamp(0, 999999);
        _products[productIndex] = p.copyWith(currentStock: newStock);

        _stockMovements.insert(
          0,
          StockMovement(
            id: 'MOV-${DateTime.now().millisecondsSinceEpoch}-${item.productId}',
            productId: p.id,
            productName: p.name,
            type: StockMovementType.sale,
            quantity: item.quantity,
            stockAfter: newStock,
            reference: invoice.invoiceNumber,
            warehouse: p.primaryWarehouse,
            notes: 'Sale to ${invoice.customerName}',
            timestamp: DateTime.now(),
            performedBy: invoice.salesPerson,
          ),
        );

        // Low stock notification if applicable
        if (newStock <= p.minimumStock) {
          _notifications.insert(
            0,
            NotificationModel(
              id: 'NOT-${DateTime.now().millisecondsSinceEpoch}',
              title: 'Low Stock Alert: ${p.name}',
              message: 'Stock has fallen to $newStock ${p.unit} after invoice ${invoice.invoiceNumber}.',
              category: NotificationCategory.inventory,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // 2. Update Customer Totals & Outstanding
    final custIndex = _customers.indexWhere((c) => c.id == invoice.customerId);
    if (custIndex != -1) {
      final c = _customers[custIndex];
      final newPurchases = c.totalPurchases + invoice.grandTotal;
      final newOutstanding = c.outstandingBalance + invoice.balanceDue;
      _customers[custIndex] = c.copyWith(
        totalPurchases: newPurchases,
        outstandingBalance: newOutstanding,
        totalOrders: c.totalOrders + 1,
        lastPurchaseDate: DateTime.now(),
      );
    }

    // 3. Add Accounting Record
    _transactions.insert(
      0,
      TransactionRecord(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        referenceNumber: 'TXN-${invoice.invoiceNumber.replaceAll("INV-", "")}',
        type: TransactionType.income,
        category: 'Sales Invoice',
        title: 'Invoice ${invoice.invoiceNumber} — ${invoice.customerName}',
        amount: invoice.amountPaid > 0 ? invoice.amountPaid : invoice.grandTotal,
        paymentAccount: 'HDFC Flagship Current A/C',
        partyName: invoice.customerName,
        date: DateTime.now(),
      ),
    );

    // 4. Add Notification
    _notifications.insert(
      0,
      NotificationModel(
        id: 'NOT-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Invoice Created',
        message: 'Invoice ${invoice.invoiceNumber} created for ${invoice.customerName} (₹${invoice.grandTotal.toStringAsFixed(2)}).',
        category: NotificationCategory.sales,
        timestamp: DateTime.now(),
      ),
    );

    logAudit(invoice.salesPerson, 'Sales Staff', 'CREATE_INVOICE', 'Sales',
        'Created invoice ${invoice.invoiceNumber} for ${invoice.customerName}');
  }

  @override
  void recordInvoicePayment(String invoiceId, PaymentRecord payment) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index != -1) {
      final inv = _invoices[index];
      final newPaid = inv.amountPaid + payment.amount;
      final newStatus = newPaid >= inv.grandTotal
          ? PaymentStatus.paid
          : (newPaid > 0 ? PaymentStatus.partial : PaymentStatus.unpaid);

      final updatedHistory = List<PaymentRecord>.from(inv.paymentHistory)..add(payment);
      _invoices[index] = inv.copyWith(
        amountPaid: newPaid,
        paymentStatus: newStatus,
        paymentHistory: updatedHistory,
      );

      // Update customer outstanding
      final custIndex = _customers.indexWhere((c) => c.id == inv.customerId);
      if (custIndex != -1) {
        final c = _customers[custIndex];
        _customers[custIndex] = c.copyWith(
          outstandingBalance: (c.outstandingBalance - payment.amount).clamp(0.0, double.infinity),
        );
      }

      // Add accounting transaction
      _transactions.insert(
        0,
        TransactionRecord(
          id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
          referenceNumber: 'TXN-${payment.referenceNumber}',
          type: TransactionType.customerPayment,
          category: 'Customer Receipt',
          title: 'Payment for ${inv.invoiceNumber}',
          amount: payment.amount,
          paymentAccount: 'HDFC Flagship Current A/C',
          partyName: inv.customerName,
          date: DateTime.now(),
        ),
      );

      logAudit(payment.receivedBy, 'Sales / Accounts', 'RECORD_PAYMENT', 'Sales',
          'Recorded payment of ₹${payment.amount} for ${inv.invoiceNumber}');
    }
  }

  @override
  List<QuotationModel> getQuotations() => List.unmodifiable(_quotations);

  @override
  void saveQuotation(QuotationModel quotation) {
    final index = _quotations.indexWhere((q) => q.id == quotation.id);
    if (index != -1) {
      _quotations[index] = quotation;
    } else {
      _quotations.insert(0, quotation);
    }
  }

  @override
  List<PurchaseOrderModel> getPurchaseOrders() => List.unmodifiable(_purchaseOrders);

  @override
  void createPurchaseOrder(PurchaseOrderModel po) {
    _purchaseOrders.insert(0, po);
    logAudit(po.requestedBy, 'Purchase Staff', 'CREATE_PO', 'Purchases',
        'Created Purchase Order ${po.poNumber} for ${po.supplierName}');
  }

  @override
  void receiveGoods(String poId, String receivedBy) {
    final index = _purchaseOrders.indexWhere((p) => p.id == poId);
    if (index != -1) {
      final po = _purchaseOrders[index];
      final updatedItems = po.items.map((item) => item.copyWith(receivedQuantity: item.quantity)).toList();
      _purchaseOrders[index] = po.copyWith(
        status: PurchaseStatus.completed,
        items: updatedItems,
      );

      // Increment stock for each item
      for (var item in po.items) {
        final prodIndex = _products.indexWhere((p) => p.id == item.productId);
        if (prodIndex != -1) {
          final p = _products[prodIndex];
          final newStock = p.currentStock + item.quantity;
          _products[prodIndex] = p.copyWith(currentStock: newStock);

          _stockMovements.insert(
            0,
            StockMovement(
              id: 'MOV-${DateTime.now().millisecondsSinceEpoch}-${item.productId}',
              productId: p.id,
              productName: p.name,
              type: StockMovementType.purchase,
              quantity: item.quantity,
              stockAfter: newStock,
              reference: po.poNumber,
              warehouse: po.destinationWarehouse,
              notes: 'Received from ${po.supplierName}',
              timestamp: DateTime.now(),
              performedBy: receivedBy,
            ),
          );
        }
      }

      // Add Notification
      _notifications.insert(
        0,
        NotificationModel(
          id: 'NOT-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Goods Received: ${po.poNumber}',
          message: 'All items from ${po.supplierName} verified and added to inventory.',
          category: NotificationCategory.purchases,
          timestamp: DateTime.now(),
        ),
      );

      logAudit(receivedBy, 'Inventory Manager', 'RECEIVE_GOODS', 'Purchases',
          'Received all goods for PO ${po.poNumber}');
    }
  }

  @override
  void updatePurchaseStatus(String poId, PurchaseStatus status) {
    final index = _purchaseOrders.indexWhere((p) => p.id == poId);
    if (index != -1) {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(status: status);
    }
  }

  @override
  List<TransactionRecord> getTransactions() => List.unmodifiable(_transactions);

  @override
  void addTransaction(TransactionRecord transaction) {
    _transactions.insert(0, transaction);
    logAudit('Accountant', 'Accountant', 'ADD_TRANSACTION', 'Accounting',
        'Recorded transaction ${transaction.title} (₹${transaction.amount})');
  }

  @override
  List<EmployeeModel> getEmployees() => List.unmodifiable(_employees);

  @override
  void saveEmployee(EmployeeModel employee) {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employees[index] = employee;
    } else {
      _employees.insert(0, employee);
    }
  }

  @override
  List<AttendanceRecord> getAttendance() => List.unmodifiable(_attendance);

  @override
  void markAttendance(AttendanceRecord record) {
    final index = _attendance.indexWhere((a) => a.employeeId == record.employeeId && a.date.day == record.date.day);
    if (index != -1) {
      _attendance[index] = record;
    } else {
      _attendance.insert(0, record);
    }
  }

  @override
  List<LeaveRequest> getLeaveRequests() => List.unmodifiable(_leaveRequests);

  @override
  void processLeaveRequest(String leaveId, LeaveStatus status, String approvedBy) {
    final index = _leaveRequests.indexWhere((l) => l.id == leaveId);
    if (index != -1) {
      _leaveRequests[index] = _leaveRequests[index].copyWith(status: status, actionBy: approvedBy);
    }
  }

  @override
  List<ProjectModel> getProjects() => List.unmodifiable(_projects);

  @override
  void saveProject(ProjectModel project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    } else {
      _projects.insert(0, project);
    }
  }

  @override
  void updateTaskStatus(String projectId, String taskId, TaskStatus status) {
    final projIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projIndex != -1) {
      final proj = _projects[projIndex];
      final updatedTasks = proj.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(status: status);
        }
        return t;
      }).toList();

      final completedCount = updatedTasks.where((t) => t.status == TaskStatus.completed).length;
      final progress = updatedTasks.isEmpty ? 0.0 : completedCount / updatedTasks.length;

      _projects[projIndex] = proj.copyWith(tasks: updatedTasks, progress: progress);
    }
  }

  @override
  void addTask(String projectId, ProjectTask task) {
    final projIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projIndex != -1) {
      final proj = _projects[projIndex];
      final updatedTasks = List<ProjectTask>.from(proj.tasks)..add(task);
      _projects[projIndex] = proj.copyWith(tasks: updatedTasks);
    }
  }

  @override
  List<NotificationModel> getNotifications() => List.unmodifiable(_notifications);

  @override
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  void markAllNotificationsAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  void clearNotifications() {
    _notifications.clear();
  }

  @override
  List<UserModel> getUsers() => List.unmodifiable(_users);

  @override
  void saveUser(UserModel user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.insert(0, user);
    }
  }

  @override
  List<AuditLogModel> getAuditLogs() => List.unmodifiable(_auditLogs);

  @override
  void logAudit(String user, String role, String action, String module, String details) {
    _auditLogs.insert(
      0,
      AuditLogModel(
        id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
        user: user,
        role: role,
        action: action,
        module: module,
        details: details,
        timestamp: DateTime.now(),
      ),
    );
  }
}
