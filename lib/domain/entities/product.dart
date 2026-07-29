import 'discount.dart';

class Product {
  const Product({
    this.id,
    required this.code,
    required this.name,
    required this.variant,
    required this.costPrice,
    required this.sellPrice,
    required this.warehouseStock,
    this.storeStock = 0,
    this.expiryDate,
    this.discountType = DiscountType.none,
    this.discountValue = 0,
  });

  final int? id;
  final String code;
  final String name;
  final String variant;
  final double costPrice;
  final double sellPrice;

  /// Main warehouse / storehouse quantity.
  final int warehouseStock;

  /// Shop-floor quantity available to sell.
  final int storeStock;

  /// Optional — mainly for food / perishable items.
  final DateTime? expiryDate;

  /// Common shop offer applied by default when selling this product.
  final DiscountType discountType;
  final double discountValue;

  int get totalStock => warehouseStock + storeStock;

  bool get hasExpiry => expiryDate != null;

  bool get hasOffer =>
      discountType != DiscountType.none && discountValue > 0;

  double offerAmountFor(double base) =>
      BillDiscount(type: discountType, value: discountValue).amountFor(base);

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? get expiryDay {
    final d = expiryDate;
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day);
  }

  bool get isExpired {
    final day = expiryDay;
    if (day == null) return false;
    return day.isBefore(_today);
  }

  /// Expires within [withinDays] (inclusive), and not already expired.
  bool isExpiringSoon({int withinDays = 30}) {
    final day = expiryDay;
    if (day == null || isExpired) return false;
    final limit = _today.add(Duration(days: withinDays));
    return !day.isAfter(limit);
  }

  /// Days until expiry. Negative if already expired. Null if no expiry.
  int? get daysUntilExpiry {
    final day = expiryDay;
    if (day == null) return null;
    return day.difference(_today).inDays;
  }

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? variant,
    double? costPrice,
    double? sellPrice,
    int? warehouseStock,
    int? storeStock,
    DateTime? expiryDate,
    bool clearExpiry = false,
    DiscountType? discountType,
    double? discountValue,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      variant: variant ?? this.variant,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      warehouseStock: warehouseStock ?? this.warehouseStock,
      storeStock: storeStock ?? this.storeStock,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'variant': variant,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'stock': warehouseStock,
        'store_stock': storeStock,
        'expiry_date': expiryDay == null
            ? null
            : '${expiryDay!.year.toString().padLeft(4, '0')}-'
                '${expiryDay!.month.toString().padLeft(2, '0')}-'
                '${expiryDay!.day.toString().padLeft(2, '0')}',
        'discount_type': discountType.storageValue,
        'discount_value': discountValue,
      };

  factory Product.fromMap(Map<String, Object?> map) {
    final raw = map['expiry_date'] as String?;
    DateTime? expiry;
    if (raw != null && raw.trim().isNotEmpty) {
      expiry = DateTime.tryParse(raw.trim());
      if (expiry != null) {
        expiry = DateTime(expiry.year, expiry.month, expiry.day);
      }
    }
    return Product(
      id: map['id'] as int?,
      code: map['code']! as String,
      name: map['name']! as String,
      variant: map['variant']! as String,
      costPrice: (map['cost_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      warehouseStock: (map['stock'] as num?)?.toInt() ?? 0,
      storeStock: (map['store_stock'] as num?)?.toInt() ?? 0,
      expiryDate: expiry,
      discountType: DiscountTypeStorage.fromStorage(map['discount_type']),
      discountValue: (map['discount_value'] as num?)?.toDouble() ?? 0,
    );
  }
}
