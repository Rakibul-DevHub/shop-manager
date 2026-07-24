import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/analytics/report_insights.dart';
import '../state/shop_store.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopStore>().setReportPreset(ReportPreset.today);
    });
  }

  Future<void> _pickSingleDay(ShopStore store) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: store.reportStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) await store.setReportDay(picked);
  }

  Future<void> _pickRange(ShopStore store) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: store.reportStart,
        end: store.reportEnd,
      ),
    );
    if (range != null) {
      await store.setReportRange(range.start, range.end);
    }
  }

  String _periodLabel(ShopStore store) {
    final fmt = DateFormat('dd MMM yyyy');
    if (store.reportStart == store.reportEnd) {
      return fmt.format(store.reportStart);
    }
    return '${fmt.format(store.reportStart)} – ${fmt.format(store.reportEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final insights = store.reportInsights;
    final net = store.reportProfit - store.reportExpenseTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.reportTitle),
        actions: [
          IconButton(
            tooltip: t.pickDate,
            onPressed: () => _pickSingleDay(store),
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t.reportHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PresetChip(
                  label: t.today,
                  selected: store.reportPreset == ReportPreset.today,
                  onTap: () => store.setReportPreset(ReportPreset.today),
                ),
                _PresetChip(
                  label: t.thisWeek,
                  selected: store.reportPreset == ReportPreset.thisWeek,
                  onTap: () => store.setReportPreset(ReportPreset.thisWeek),
                ),
                _PresetChip(
                  label: t.thisMonth,
                  selected: store.reportPreset == ReportPreset.thisMonth,
                  onTap: () => store.setReportPreset(ReportPreset.thisMonth),
                ),
                _PresetChip(
                  label: t.previousMonth,
                  selected: store.reportPreset == ReportPreset.previousMonth,
                  onTap: () =>
                      store.setReportPreset(ReportPreset.previousMonth),
                ),
                _PresetChip(
                  label: t.customRange,
                  selected: store.reportPreset == ReportPreset.custom,
                  onTap: () => _pickRange(store),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _pickRange(store),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _periodLabel(store),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickSingleDay(store),
                        child: Text(t.pickDate),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ReportStat(
                    label: t.total,
                    value: formatTaka(store.reportSalesTotal),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportStat(
                    label: t.profit,
                    value: formatTaka(store.reportProfit),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportStat(
                    label: t.pieces,
                    value: '${store.reportPieces}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ReportStat(
                    label: t.periodExpense,
                    value: formatTaka(store.reportExpenseTotal),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportStat(
                    label: t.netEstimate,
                    value: formatTaka(net),
                    valueColor: net < 0 ? AppColors.danger : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              t.deepInsights,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              t.cashVsDueHint,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            // Pie first — most visible deep insight
            _ChartCard(
              title: t.cashVsDue,
              subtitle: t.cashVsDueHint,
              child: _CashDuePie(insights: insights, t: t),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: t.salesTrend,
              subtitle: t.salesTrendHint,
              child: _SalesTrendChart(
                points: store.salesTrendPoints,
                t: t,
              ),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: t.composition,
              subtitle: t.marginHealthHint,
              child: _CompositionBars(insights: insights, t: t),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: t.topProductsChart,
              subtitle: t.topByProfitHint,
              child: _TopProductsBar(insights: insights, t: t),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: t.thinMarginWatch,
              subtitle: t.thinMarginHint,
              child: _ThinMarginSummary(insights: insights, t: t),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      checkmarkColor: Colors.white,
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CashDuePie extends StatelessWidget {
  const _CashDuePie({required this.insights, required this.t});

  final ReportInsights insights;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final cash = insights.cashTotal;
    final due = insights.dueTotal;
    final total = cash + due;
    final hasData = total > 0;

    final sections = hasData
        ? <PieChartSectionData>[
            if (cash > 0)
              PieChartSectionData(
                value: cash,
                color: AppColors.success,
                title: '${((cash / total) * 100).round()}%',
                radius: 70,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            if (due > 0)
              PieChartSectionData(
                value: due,
                color: AppColors.accent,
                title: '${((due / total) * 100).round()}%',
                radius: 70,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
          ]
        : <PieChartSectionData>[
            PieChartSectionData(
              value: 1,
              color: AppColors.border,
              title: t.noSales,
              radius: 70,
              titleStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ];

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.35,
          child: PieChart(
            PieChartData(
              sectionsSpace: hasData ? 3 : 0,
              centerSpaceRadius: 48,
              startDegreeOffset: -90,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.success, label: t.cashSales),
            const SizedBox(width: 18),
            _LegendDot(color: AppColors.accent, label: t.dueSales),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      t.cashSales,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTaka(cash),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      t.dueSales,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTaka(due),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart({
    required this.points,
    required this.t,
  });

  final List<DailyTrendPoint> points;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final data = points.isEmpty
        ? [
            DailyTrendPoint(
              day: DateTime.now(),
              sales: 0,
              profit: 0,
            ),
          ]
        : points;

    final maxY = data
        .map((p) => p.sales > p.profit ? p.sales : p.profit)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final hasAnySales = data.any((p) => p.sales > 0);
    final chartMax = maxY <= 0 ? 100.0 : maxY * 1.25;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final p = data[group.x.toInt()];
                    final label = rodIndex == 0
                        ? '${t.total}: ${formatTaka(p.sales)}'
                        : '${t.profit}: ${formatTaka(p.profit)}';
                    return BarTooltipItem(
                      '${DateFormat('dd MMM').format(p.day)}\n$label',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value != 0 && value != meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value >= 1000
                            ? '${(value / 1000).toStringAsFixed(1)}k'
                            : value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= data.length) {
                        return const SizedBox.shrink();
                      }
                      if (data.length > 8 && i % 2 != 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('E').format(data[i].day),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border.withValues(alpha: 0.8),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 2,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].sales <= 0 ? 1.5 : data[i].sales,
                        width: data.length > 10 ? 6 : 9,
                        borderRadius: BorderRadius.circular(3),
                        color: data[i].sales <= 0
                            ? AppColors.border
                            : AppColors.primary,
                      ),
                      BarChartRodData(
                        toY: data[i].profit <= 0 ? 1.5 : data[i].profit,
                        width: data.length > 10 ? 6 : 9,
                        borderRadius: BorderRadius.circular(3),
                        color: data[i].profit <= 0
                            ? AppColors.border.withValues(alpha: 0.6)
                            : AppColors.success,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.primary, label: t.total),
            const SizedBox(width: 16),
            _LegendDot(color: AppColors.success, label: t.profit),
          ],
        ),
        if (!hasAnySales)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              t.salesTrendEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _CompositionBars extends StatelessWidget {
  const _CompositionBars({required this.insights, required this.t});

  final ReportInsights insights;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final items = [
      (t.total, insights.salesTotal, AppColors.primary),
      (t.cogs, insights.cogsTotal, AppColors.accent),
      (
        t.profit,
        insights.profitTotal < 0 ? 0.0 : insights.profitTotal,
        AppColors.success,
      ),
    ];
    final maxV =
        items.map((e) => e.$2).fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxV <= 0 ? 100.0 : maxV * 1.15;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= items.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          items[i].$1,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < items.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: items[i].$2 <= 0 ? 2 : items[i].$2,
                        width: 32,
                        borderRadius: BorderRadius.circular(6),
                        color: items[i].$2 <= 0
                            ? AppColors.border
                            : items[i].$3,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${t.grossMargin}: '
          '${insights.grossMarginPercent?.toStringAsFixed(1) ?? '—'}%',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TopProductsBar extends StatelessWidget {
  const _TopProductsBar({required this.insights, required this.t});

  final ReportInsights insights;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final products = insights.topByProfit;
    if (products.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            t.noProductInsight,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxY = products
        .map((p) => p.profit < 0 ? 0.0 : p.profit)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final p = products[group.x.toInt()];
                return BarTooltipItem(
                  '${p.name}\n${formatTaka(p.profit)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= products.length) {
                    return const SizedBox.shrink();
                  }
                  final code = products[i].code;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      code.length > 7 ? '${code.substring(0, 6)}…' : code,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.7),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < products.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: products[i].profit < 0 ? 0 : products[i].profit,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.success,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ThinMarginSummary extends StatelessWidget {
  const _ThinMarginSummary({required this.insights, required this.t});

  final ReportInsights insights;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final count = insights.thinMarginSales.length;
    final lossCount =
        insights.thinMarginSales.where((s) => s.profit < 0).length;
    final zeroCount =
        insights.thinMarginSales.where((s) => s.profit == 0).length;

    return Row(
      children: [
        Expanded(
          child: _MiniStatBox(
            label: t.thinMarginWatch,
            value: '$count',
            color: count == 0 ? AppColors.success : AppColors.danger,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatBox(
            label: t.lossSales,
            value: '$lossCount',
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatBox(
            label: t.breakEvenSales,
            value: '$zeroCount',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _MiniStatBox extends StatelessWidget {
  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
