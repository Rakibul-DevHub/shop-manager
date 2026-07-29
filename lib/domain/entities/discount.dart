enum DiscountType { none, percent, amount }

extension DiscountTypeStorage on DiscountType {
  String get storageValue => name;

  static DiscountType fromStorage(Object? raw) {
    switch (raw?.toString()) {
      case 'percent':
        return DiscountType.percent;
      case 'amount':
        return DiscountType.amount;
      default:
        return DiscountType.none;
    }
  }
}

class BillDiscount {
  const BillDiscount({
    this.type = DiscountType.none,
    this.value = 0,
    this.reason = '',
  });

  final DiscountType type;
  final double value;
  final String reason;

  double amountFor(double subtotal) {
    if (subtotal <= 0 || type == DiscountType.none || value <= 0) return 0;
    if (type == DiscountType.percent) {
      return (subtotal * value / 100).clamp(0, subtotal);
    }
    return value.clamp(0, subtotal);
  }
}
