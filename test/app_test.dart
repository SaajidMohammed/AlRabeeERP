import 'package:flutter_test/flutter_test.dart';
import 'package:alrabee/providers/erp_provider.dart';
import 'package:alrabee/models/sales_model.dart';
import 'package:alrabee/models/purchase_model.dart';

void main() {
  group('Al Rabee ERP Core Database & Business Logic Tests', () {
    late ErpProvider erp;

    setUp(() {
      erp = ErpProvider();
    });

    test('Initial seeded catalog contains realistic Al Rabee products', () {
      expect(erp.products.length, greaterThanOrEqualTo(20));
      expect(erp.customers.length, greaterThanOrEqualTo(5));
      expect(erp.suppliers.length, greaterThanOrEqualTo(4));
      expect(erp.invoices.length, greaterThanOrEqualTo(3));
      expect(erp.warehouses.length, equals(3));
    });

    test('Creating a sale invoice deducts stock and logs stock movement', () {
      final product = erp.products.first;
      final initialStock = product.currentStock;
      final customer = erp.customers.first;
      final initialPurchases = customer.totalPurchases;

      final invoice = InvoiceModel(
        id: 'TEST-INV-001',
        invoiceNumber: 'INV-2026-99999',
        customerId: customer.id,
        customerName: customer.name,
        customerPhone: customer.phone,
        invoiceDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 15)),
        items: [
          InvoiceItem(
            productId: product.id,
            productName: product.name,
            sku: product.sku,
            quantity: 5,
            unitPrice: product.sellingPrice,
          ),
        ],
        amountPaid: product.sellingPrice * 5,
        paymentStatus: PaymentStatus.paid,
        salesPerson: 'Tester',
      );

      erp.createInvoice(invoice);

      final updatedProduct = erp.getProductById(product.id);
      expect(updatedProduct?.currentStock, equals(initialStock - 5));

      final updatedCustomer = erp.customers.firstWhere((c) => c.id == customer.id);
      expect(updatedCustomer.totalPurchases, greaterThan(initialPurchases));
    });

    test('Receiving Goods on Purchase Order auto-increments product stock', () {
      final po = erp.purchaseOrders.firstWhere((p) => p.status == PurchaseStatus.ordered);
      final item = po.items.first;
      final productBefore = erp.getProductById(item.productId);
      final stockBefore = productBefore!.currentStock;

      erp.receiveGoods(po.id, 'Test Inspector');

      final productAfter = erp.getProductById(item.productId);
      expect(productAfter!.currentStock, equals(stockBefore + item.quantity));
    });
  });
}
