import 'discount.dart';
import 'product.dart';

/// One line in the counter cart (piece or weight).
class CartLine {
  CartLine({
    required this.product,
    required this.qty,
    required this.unitPrice,
    this.isWeight = false,
    this.discountType = DiscountType.none,
    this.discountValue = 0,
  });

  final Product product;
  double qty;
  double unitPrice;
  final bool isWeight;
  DiscountType discountType;
  double discountValue;

  /// Price × qty before any line discount.
  double get lineGross => unitPrice * qty;

  double get lineDiscountAmount =>
      BillDiscount(type: discountType, value: discountValue).amountFor(lineGross);

  /// Net line total after item discount.
  double get lineTotal =>
      (lineGross - lineDiscountAmount).clamp(0, double.infinity);

  bool get hasDiscount => lineDiscountAmount > 0;

  /// Stock units to remove (weight uses ceil for simple demo stock).
  int get stockToDeduct {
    if (isWeight) {
      final n = qty.ceil();
      return n < 1 ? 1 : n;
    }
    return qty.round().clamp(1, 999999);
  }

  String get qtyLabel {
    if (isWeight) {
      final text = qty == qty.roundToDouble()
          ? qty.toStringAsFixed(0)
          : qty.toStringAsFixed(2);
      return '$text kg';
    }
    return qty == qty.roundToDouble()
        ? qty.toStringAsFixed(0)
        : qty.toStringAsFixed(2);
  }

  CartLine copyWith({
    Product? product,
    double? qty,
    double? unitPrice,
    bool? isWeight,
    DiscountType? discountType,
    double? discountValue,
  }) {
    return CartLine(
      product: product ?? this.product,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      isWeight: isWeight ?? this.isWeight,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }
}

/// Parked / held bill so another customer can be served.
class ParkedBill {
  ParkedBill({
    required this.id,
    required this.label,
    required this.lines,
    required this.discount,
    required this.parkedAt,
  });

  final String id;
  final String label;
  final List<CartLine> lines;
  final BillDiscount discount;
  final DateTime parkedAt;

  double get subtotal => lines.fold(0, (s, l) => s + l.lineTotal);
}
