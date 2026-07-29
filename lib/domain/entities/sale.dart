class SaleRecord {
  const SaleRecord({
    this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.costPrice,
    required this.total,
    required this.profit,
    required this.soldAt,
    required this.paymentType,
    this.customerId,
    this.customerName,
    this.salesmanName,
    this.salesmanId,
  });

  final int? id;
  final int productId;
  final String productCode;
  final String productName;
  final int qty;
  final double unitPrice;
  final double costPrice;
  final double total;
  final double profit;
  final DateTime soldAt;
  final String paymentType; // cash | due | return
  final int? customerId;
  final String? customerName;

  /// Optional free-text salesman name / code entered at sell time.
  final String? salesmanName;
  final String? salesmanId;

  double get marginPercent =>
      total <= 0 ? 0.0 : (profit / total) * 100;

  bool get hasSalesman {
    final name = salesmanName?.trim() ?? '';
    final sid = salesmanId?.trim() ?? '';
    return name.isNotEmpty || sid.isNotEmpty;
  }

  String get salesmanLabel {
    final name = salesmanName?.trim() ?? '';
    final sid = salesmanId?.trim() ?? '';
    if (name.isNotEmpty && sid.isNotEmpty) return '$name ($sid)';
    if (name.isNotEmpty) return name;
    return sid;
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'product_id': productId,
        'product_code': productCode,
        'product_name': productName,
        'qty': qty,
        'unit_price': unitPrice,
        'cost_price': costPrice,
        'total': total,
        'profit': profit,
        'sold_at': soldAt.toIso8601String(),
        'payment_type': paymentType,
        'customer_id': customerId,
        'customer_name': customerName,
        'salesman_name': salesmanName,
        'salesman_id': salesmanId,
      };

  factory SaleRecord.fromMap(Map<String, Object?> map) {
    return SaleRecord(
      id: map['id'] as int?,
      productId: map['product_id']! as int,
      productCode: map['product_code']! as String,
      productName: map['product_name']! as String,
      qty: map['qty']! as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
      soldAt: DateTime.parse(map['sold_at']! as String),
      paymentType: map['payment_type']! as String,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String?,
      salesmanName: map['salesman_name'] as String?,
      salesmanId: map['salesman_id'] as String?,
    );
  }
}
