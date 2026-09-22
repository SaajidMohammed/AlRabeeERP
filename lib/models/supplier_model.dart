class SupplierModel {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String country; // 'Saudi Arabia', 'Iran', 'USA', 'Belgium', 'India', 'Turkey'
  final String address;
  final String categorySpecialty; // 'Ajwa & Medjool Dates', 'Dry Fruits & Nuts', 'Imported Chocolates'
  final double totalPurchased;
  final double outstandingPayable;
  final int totalOrders;
  final bool isActive;
  final double rating;

  SupplierModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.country,
    required this.address,
    required this.categorySpecialty,
    this.totalPurchased = 0,
    this.outstandingPayable = 0,
    this.totalOrders = 0,
    this.isActive = true,
    this.rating = 4.8,
  });

  SupplierModel copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? country,
    String? address,
    String? categorySpecialty,
    double? totalPurchased,
    double? outstandingPayable,
    int? totalOrders,
    bool? isActive,
    double? rating,
  }) {
    return SupplierModel(
      id: id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      country: country ?? this.country,
      address: address ?? this.address,
      categorySpecialty: categorySpecialty ?? this.categorySpecialty,
      totalPurchased: totalPurchased ?? this.totalPurchased,
      outstandingPayable: outstandingPayable ?? this.outstandingPayable,
      totalOrders: totalOrders ?? this.totalOrders,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
    );
  }
}
