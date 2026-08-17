class Payment {
  const Payment({
    this.id,
    required this.customerId,
    required this.amount,
    required this.createdAt,
  });

  final int? id;
  final int customerId;
  final double amount;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'customer_id': customerId,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
      };

  factory Payment.fromMap(Map<String, Object?> map) {
    return Payment(
      id: map['id'] as int?,
      customerId: map['customer_id']! as int,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}
