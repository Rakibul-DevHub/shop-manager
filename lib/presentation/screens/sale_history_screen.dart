import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/entities/sale.dart';
import '../state/shop_store.dart';

class SaleHistoryScreen extends StatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  State<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopStore>().setHistoryPreset(ReportPreset.today);
    });
  }

  Future<void> _pickSingleDay(ShopStore store) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: store.historyStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) await store.setHistoryDay(picked);
  }

  Future<void> _pickRange(ShopStore store) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: store.historyStart,
        end: store.historyEnd,
      ),
    );
    if (range != null) {
      await store.setHistoryRange(range.start, range.end);
    }
  }

  String _periodLabel(ShopStore store) {
    final fmt = DateFormat('dd MMM yyyy');
    if (store.historyStart == store.historyEnd) {
      return fmt.format(store.historyStart);
    }
    return '${fmt.format(store.historyStart)} – ${fmt.format(store.historyEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final sales = store.historySales;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.saleHistory),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.saleHistoryHint,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(
                        label: t.today,
                        selected: store.historyPreset == ReportPreset.today,
                        onTap: () =>
                            store.setHistoryPreset(ReportPreset.today),
                      ),
                      _Chip(
                        label: t.thisWeek,
                        selected: store.historyPreset == ReportPreset.thisWeek,
                        onTap: () =>
                            store.setHistoryPreset(ReportPreset.thisWeek),
                      ),
                      _Chip(
                        label: t.thisMonth,
                        selected: store.historyPreset == ReportPreset.thisMonth,
                        onTap: () =>
                            store.setHistoryPreset(ReportPreset.thisMonth),
                      ),
                      _Chip(
                        label: t.previousMonth,
                        selected:
                            store.historyPreset == ReportPreset.previousMonth,
                        onTap: () => store
                            .setHistoryPreset(ReportPreset.previousMonth),
                      ),
                      _Chip(
                        label: t.customRange,
                        selected: store.historyPreset == ReportPreset.custom,
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
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _periodLabel(store),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: t.total,
                          value: formatTaka(store.historySalesTotal),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          label: t.profit,
                          value: formatTaka(store.historyProfit),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          label: t.pieces,
                          value: '${store.historyPieces}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: sales.isEmpty
                  ? Center(
                      child: Text(
                        t.noSaleHistory,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: sales.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _HistoryTile(sale: sales[index], t: t);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.sale, required this.t});

  final SaleRecord sale;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final marginPct =
        sale.total <= 0 ? 0.0 : (sale.profit / sale.total) * 100;
    final profitColor = sale.profit < 0
        ? AppColors.danger
        : marginPct < 10
            ? AppColors.accent
            : AppColors.success;
    final payLabel = sale.paymentType == 'due' ? t.dueSale : t.cash;

    return Card(
      child: ListTile(
        title: Text(
          sale.productName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${sale.productCode} • ${t.qty}: ${sale.qty} • $payLabel\n'
          '${DateFormat('dd MMM yyyy, hh:mm a').format(sale.soldAt)}'
          '${sale.customerName == null || sale.customerName!.isEmpty ? '' : ' • ${sale.customerName}'}',
        ),
        isThreeLine: true,
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
              style: TextStyle(color: profitColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
