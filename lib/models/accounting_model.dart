enum TransactionType {
  income('Income', 1),
  expense('Expense', -1),
  customerPayment('Customer Receivable', 1),
  supplierPayment('Supplier Payable', -1);

  final String label;
  final int multiplier;
  const TransactionType(this.label, this.multiplier);
}

enum ExpenseCategory {
  importCustoms('Import Duty & Customs'),
  coldChainStorage('Cold Chain & Warehousing'),
  storeRent('Showroom Rent & Utilities'),
  packagingMaterials('Luxury Gift Packaging & Boxes'),
  staffSalaries('Staff Salaries & Commission'),
  logisticsFreight('Air Freight & Container Shipping'),
  marketing('Marketing & Social Media'),
  maintenance('Refrigeration & Equipment Maintenance'),
  other('Office Supplies & Misc');

  final String label;
  const ExpenseCategory(this.label);
}

class TransactionRecord {
  final String id;
  final String referenceNumber; // TXN-2026-0812
  final TransactionType type;
  final String category;
  final String title;
  final double amount;
  final String paymentAccount; // 'HDFC Current A/C', 'Cash Drawer Flagship', 'ICICI Export A/C'
  final String partyName;
  final DateTime date;
  final String status; // 'Cleared', 'Pending', 'Reconciled'
  final String notes;

  TransactionRecord({
    required this.id,
    required this.referenceNumber,
    required this.type,
    required this.category,
    required this.title,
    required this.amount,
    required this.paymentAccount,
    required this.partyName,
    required this.date,
    this.status = 'Cleared',
    this.notes = '',
  });
}
