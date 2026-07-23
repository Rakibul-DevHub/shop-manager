class Expense {
  const Expense({
    this.id,
    required this.type,
    required this.amount,
    this.note = '',
    required this.createdAt,
  });

  final int? id;
  final String type;
  final double amount;
  final String note;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type,
        'amount': amount,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      type: map['type']! as String,
      amount: (map['amount'] as num).toDouble(),
      note: (map['note'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at']! as String),
    );
  }
}
