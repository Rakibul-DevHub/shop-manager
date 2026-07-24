import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/tap_mark.dart';
import '../state/shop_store.dart';
import 'daily_report_screen.dart';
import 'due_customers_screen.dart';
import 'expense_screen.dart';
import 'low_stock_screen.dart';
import 'products_screen.dart';
import 'quick_sell_screen.dart';
import 'sale_history_screen.dart';

/// Home: shop name + Quick Sell + sales / cost / stock summary.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final shopName = store.shop?.name ?? 'Shop Manager';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.shopSummary,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              OfflineBadge(label: t.offline),
            ],
          ),
          const SizedBox(height: 20),
          const TapHint(
            number: 1,
            text: 'Tap Quick Sell to open the rear camera scanner',
          ),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickSellScreen(
                      standalone: true,
                      openScannerOnStart: true,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                child: Row(
                  children: [
                    const TapMark(1, tooltip: 'Tap here → Quick Sell'),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flash_on, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.quickSell,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.quickSellHint,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.todaySummary,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyReportScreen(),
                    ),
                  );
                },
                child: Text(t.viewReport),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const TapHint(
            number: 2,
            text: 'Tap a summary card for history, stock, dues, or expense',
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _SummaryCard(
                icon: Icons.point_of_sale_outlined,
                label: t.todaySales,
                value: formatTaka(store.todaySalesTotal),
                hint: '${store.todayPieces} ${t.itemsUnit}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SaleHistoryScreen(),
                    ),
                  );
                },
              ),
              _SummaryCard(
                icon: Icons.trending_up,
                label: t.profit,
                value: formatTaka(store.todayProfit),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyReportScreen(),
                    ),
                  );
                },
              ),
              _SummaryCard(
                icon: Icons.inventory_2_outlined,
                label: t.stockItems,
                value: '${store.totalStockQty} ${t.itemsUnit}',
                hint: '${t.stockValue}: ${formatTaka(store.stockCostValue)}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: const ProductsScreen(),
                      ),
                    ),
                  );
                },
              ),
              _SummaryCard(
                icon: Icons.warning_amber_rounded,
                label: t.lowStock,
                value: '${store.lowStockProducts.length}',
                tint: store.lowStockProducts.isEmpty
                    ? AppColors.primaryLight
                    : const Color(0xFFFFF1E8),
                iconColor: store.lowStockProducts.isEmpty
                    ? AppColors.primary
                    : AppColors.accent,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LowStockScreen(),
                    ),
                  );
                },
              ),
              _SummaryCard(
                icon: Icons.account_balance_wallet_outlined,
                label: t.due,
                value: formatTaka(store.totalDue),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(),
                        body: const DueCustomersScreen(),
                      ),
                    ),
                  );
                },
              ),
              _SummaryCard(
                icon: Icons.receipt_long_outlined,
                label: t.todayExpense,
                value: formatTaka(store.todayExpenseTotal),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpenseScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.hint,
    this.tint = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final VoidCallback onTap;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(
                  hint!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
