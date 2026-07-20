class Product {
  const Product({
    this.id,
    required this.code,
    required this.name,
    required this.variant,
    required this.costPrice,
    required this.sellPrice,
    required this.stock,
  });

  final int? id;
  final String code;
  final String name;
  final String variant;
  final double costPrice;
  final double sellPrice;
  final int stock;

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? variant,
    double? costPrice,
    double? sellPrice,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      variant: variant ?? this.variant,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'variant': variant,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'stock': stock,
      };

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int?,
      code: map['code']! as String,
      name: map['name']! as String,
      variant: map['variant']! as String,
      costPrice: (map['cost_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      stock: map['stock']! as int,
    );
  }
}
