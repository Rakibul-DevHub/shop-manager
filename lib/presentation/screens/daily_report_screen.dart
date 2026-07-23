import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';

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
      context.read<ShopStore>().setReportDay(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final days = _buildDays(store);
    final selectedIndex = days.indexWhere(
      (d) =>
          d.year == store.reportDay.year &&
          d.month == store.reportDay.month &&
          d.day == store.reportDay.day,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.reportTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
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
              children: List.generate(days.length, (index) {
                final day = days[index];
                final selected = index == selectedIndex;
                return ChoiceChip(
                  label: Text(DateFormat('dd MMM').format(day)),
                  selected: selected,
                  onSelected: (_) => store.setReportDay(day),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  checkmarkColor: Colors.white,
                );
              }),
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
            const SizedBox(height: 20),
            Text(
              DateFormat('yyyy-MM-dd').format(store.reportDay),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 10),
            if (store.reportSales.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    t.noSales,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...store.reportSales.map(
                (sale) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      sale.productName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${sale.productCode} • ${t.qty}: ${sale.qty} • ${sale.paymentType}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTaka(sale.total),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${t.profit} ${formatTaka(sale.profit)}',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _buildDays(ShopStore store) {
    final today = DateTime.now();
    final set = <String, DateTime>{};
    for (var i = 0; i < 7; i++) {
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      set['${d.year}-${d.month}-${d.day}'] = d;
    }
    for (final d in store.saleDays) {
      final day = DateTime(d.year, d.month, d.day);
      set['${day.year}-${day.month}-${day.day}'] = day;
    }
    final list = set.values.toList()
      ..sort((a, b) => b.compareTo(a));
    return list.take(10).toList();
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value});

  final String label;
  final String value;

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
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
