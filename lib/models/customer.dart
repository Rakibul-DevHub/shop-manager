class Customer {
  const Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.dueAmount,
  });

  final int? id;
  final String name;
  final String phone;
  final double dueAmount;

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    double? dueAmount,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dueAmount: dueAmount ?? this.dueAmount,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'due_amount': dueAmount,
      };

  factory Customer.fromMap(Map<String, Object?> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name']! as String,
      phone: map['phone']! as String,
      dueAmount: (map['due_amount'] as num).toDouble(),
    );
  }
}
