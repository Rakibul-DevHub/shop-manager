class AppUser {
  const AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      };

  factory AppUser.fromMap(Map<String, Object?> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name']! as String,
      email: map['email']! as String,
      phone: map['phone']! as String,
      password: map['password']! as String,
    );
  }
}

class ShopProfile {
  const ShopProfile({
    this.id,
    required this.name,
    required this.type,
    this.lowStockThreshold = 5,
  });

  final int? id;
  final String name;
  final String type;
  final int lowStockThreshold;

  ShopProfile copyWith({
    int? id,
    String? name,
    String? type,
    int? lowStockThreshold,
  }) {
    return ShopProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'low_stock_threshold': lowStockThreshold,
      };

  factory ShopProfile.fromMap(Map<String, Object?> map) {
    return ShopProfile(
      id: map['id'] as int?,
      name: map['name']! as String,
      type: map['type']! as String,
      lowStockThreshold: (map['low_stock_threshold'] as int?) ?? 5,
    );
  }
}
