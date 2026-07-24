import '../entities/sale.dart';

/// Aggregated retail insights for a sales period.
class ReportInsights {
  const ReportInsights({
    required this.salesTotal,
    required this.profitTotal,
    required this.cogsTotal,
    required this.cashTotal,
    required this.dueTotal,
    required this.pieces,
    required this.lineCount,
    required this.thinMarginSales,
    required this.topByProfit,
    required this.topByQty,
    required this.topByRevenue,
    required this.dailyTrend,
  });

  final double salesTotal;
  final double profitTotal;
  final double cogsTotal;
  final double cashTotal;
  final double dueTotal;
  final int pieces;
  final int lineCount;
  final List<SaleRecord> thinMarginSales;
  final List<ProductInsight> topByProfit;
  final List<ProductInsight> topByQty;
  final List<ProductInsight> topByRevenue;
  final List<DailyTrendPoint> dailyTrend;

  double? get grossMarginPercent {
    if (salesTotal <= 0) return null;
    return (profitTotal / salesTotal) * 100;
  }

  double? get duePercent {
    if (salesTotal <= 0) return null;
    return (dueTotal / salesTotal) * 100;
  }

  double? get avgSaleLine {
    if (lineCount <= 0) return null;
    return salesTotal / lineCount;
  }

  double? get avgProfitPerPiece {
    if (pieces <= 0) return null;
    return profitTotal / pieces;
  }

  bool get isEmpty => lineCount == 0;

  static const thinMarginThresholdPercent = 10.0;

  factory ReportInsights.fromSales(
    List<SaleRecord> sales, {
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    var salesTotal = 0.0;
    var profitTotal = 0.0;
    var cogsTotal = 0.0;
    var cashTotal = 0.0;
    var dueTotal = 0.0;
    var pieces = 0;

    final thin = <SaleRecord>[];
    final byCode = <String, ProductInsight>{};
    final byDay = <String, DailyTrendPoint>{};

    for (final s in sales) {
      salesTotal += s.total;
      profitTotal += s.profit;
      cogsTotal += s.costPrice * s.qty;
      pieces += s.qty;
      if (s.paymentType == 'due') {
        dueTotal += s.total;
      } else {
        cashTotal += s.total;
      }

      final marginPct = s.total <= 0 ? 0.0 : (s.profit / s.total) * 100;
      if (s.profit <= 0 || marginPct < thinMarginThresholdPercent) {
        thin.add(s);
      }

      final existing = byCode[s.productCode];
      if (existing == null) {
        byCode[s.productCode] = ProductInsight(
          code: s.productCode,
          name: s.productName,
          qty: s.qty,
          revenue: s.total,
          profit: s.profit,
          cogs: s.costPrice * s.qty,
        );
      } else {
        byCode[s.productCode] = existing.copyWith(
          qty: existing.qty + s.qty,
          revenue: existing.revenue + s.total,
          profit: existing.profit + s.profit,
          cogs: existing.cogs + (s.costPrice * s.qty),
        );
      }

      final day = DateTime(s.soldAt.year, s.soldAt.month, s.soldAt.day);
      final key = _dayKey(day);
      final point = byDay[key];
      if (point == null) {
        byDay[key] = DailyTrendPoint(day: day, sales: s.total, profit: s.profit);
      } else {
        byDay[key] = DailyTrendPoint(
          day: day,
          sales: point.sales + s.total,
          profit: point.profit + s.profit,
        );
      }
    }

    thin.sort((a, b) => a.profit.compareTo(b.profit));
    final products = byCode.values.toList();
    final byProfit = [...products]..sort((a, b) => b.profit.compareTo(a.profit));
    final byQty = [...products]..sort((a, b) => b.qty.compareTo(a.qty));
    final byRevenue = [...products]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final trend = _filledTrend(
      byDay: byDay,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    return ReportInsights(
      salesTotal: salesTotal,
      profitTotal: profitTotal,
      cogsTotal: cogsTotal,
      cashTotal: cashTotal,
      dueTotal: dueTotal,
      pieces: pieces,
      lineCount: sales.length,
      thinMarginSales: thin,
      topByProfit: byProfit.take(5).toList(),
      topByQty: byQty.take(5).toList(),
      topByRevenue: byRevenue.take(5).toList(),
      dailyTrend: trend,
    );
  }

  static String _dayKey(DateTime day) =>
      '${day.year}-${day.month}-${day.day}';

  /// Builds one point per day in [rangeStart]..[rangeEnd] (zeros for empty days).
  static List<DailyTrendPoint> _filledTrend({
    required Map<String, DailyTrendPoint> byDay,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    if (rangeStart != null && rangeEnd != null) {
      var start = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
      var end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
      if (end.isBefore(start)) {
        final tmp = start;
        start = end;
        end = tmp;
      }
      final filled = <DailyTrendPoint>[];
      for (var d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))) {
        filled.add(
          byDay[_dayKey(d)] ?? DailyTrendPoint(day: d, sales: 0, profit: 0),
        );
      }
      return filled;
    }

    final trend = byDay.values.toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return trend;
  }
}

class ProductInsight {
  const ProductInsight({
    required this.code,
    required this.name,
    required this.qty,
    required this.revenue,
    required this.profit,
    required this.cogs,
  });

  final String code;
  final String name;
  final int qty;
  final double revenue;
  final double profit;
  final double cogs;

  double? get marginPercent {
    if (revenue <= 0) return null;
    return (profit / revenue) * 100;
  }

  ProductInsight copyWith({
    String? code,
    String? name,
    int? qty,
    double? revenue,
    double? profit,
    double? cogs,
  }) {
    return ProductInsight(
      code: code ?? this.code,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      revenue: revenue ?? this.revenue,
      profit: profit ?? this.profit,
      cogs: cogs ?? this.cogs,
    );
  }
}

class DailyTrendPoint {
  const DailyTrendPoint({
    required this.day,
    required this.sales,
    required this.profit,
  });

  final DateTime day;
  final double sales;
  final double profit;
}
