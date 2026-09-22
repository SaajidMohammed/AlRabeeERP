class CustomerActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'Call', 'Meeting', 'Sale', 'Note', 'Email'
  final String author;

  CustomerActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.author,
  });
}

class CustomerModel {
  final String id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String gstin;
  final double totalPurchases;
  final double outstandingBalance;
  final double creditLimit;
  final int totalOrders;
  final DateTime? lastPurchaseDate;
  final bool isActive;
  final String tier; // 'Retail', 'Wholesale', 'VIP Client', 'Corporate'
  final List<CustomerActivity> activities;
  final List<String> notes;

  CustomerModel({
    required this.id,
    required this.name,
    this.company = '',
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    this.gstin = '',
    this.totalPurchases = 0,
    this.outstandingBalance = 0,
    this.creditLimit = 50000,
    this.totalOrders = 0,
    this.lastPurchaseDate,
    this.isActive = true,
    this.tier = 'Retail',
    List<CustomerActivity>? activities,
    List<String>? notes,
  })  : activities = activities ?? [],
        notes = notes ?? [];

  CustomerModel copyWith({
    String? name,
    String? company,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? gstin,
    double? totalPurchases,
    double? outstandingBalance,
    double? creditLimit,
    int? totalOrders,
    DateTime? lastPurchaseDate,
    bool? isActive,
    String? tier,
    List<CustomerActivity>? activities,
    List<String>? notes,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      gstin: gstin ?? this.gstin,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      totalOrders: totalOrders ?? this.totalOrders,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      isActive: isActive ?? this.isActive,
      tier: tier ?? this.tier,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }
}
