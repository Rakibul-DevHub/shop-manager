import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/tap_mark.dart';
import '../state/shop_store.dart';
import 'daily_report_screen.dart';
import 'due_customers_screen.dart';
import 'expense_screen.dart';
import 'expiring_products_screen.dart';
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
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
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
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
                            child:
                                const Icon(Icons.flash_on, color: Colors.white),
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
                  text:
                      'Tap a summary card for history, stock, dues, or expense',
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final crossAxisCount = maxWidth >= 600
                        ? 3
                        : maxWidth < 320
                            ? 1
                            : 2;
                    final spacing = maxWidth < 360 ? 8.0 : 10.0;
                    final cardWidth =
                        (maxWidth - spacing * (crossAxisCount - 1)) /
                            crossAxisCount;
                    // Keep enough height for icon + label + value (+ hint)
                    // on narrow phones; widen slightly on larger screens.
                    final minCardHeight = maxWidth < 360 ? 132.0 : 120.0;
                    final maxCardHeight = maxWidth >= 600 ? 140.0 : 150.0;
                    final cardHeight =
                        (cardWidth / 1.35).clamp(minCardHeight, maxCardHeight);
                    final childAspectRatio = cardWidth / cardHeight;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: childAspectRatio,
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
                          hint:
                              '${t.storeQty}: ${store.totalStoreQty} • ${t.warehouseQty}: ${store.totalWarehouseQty}',
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
                          icon: Icons.event_busy_outlined,
                          label: t.expiryAlerts,
                          value: '${store.expiryAlertProducts.length}',
                          tint: store.expiryAlertProducts.isEmpty
                              ? AppColors.primaryLight
                              : const Color(0xFFFFEBEE),
                          iconColor: store.expiryAlertProducts.isEmpty
                              ? AppColors.primary
                              : AppColors.danger,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ExpiringProductsScreen(),
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
                              MaterialPageRoute(
                                builder: (_) => const ExpenseScreen(),
                              ),
                            );
                          },
                        ),
                        _SummaryCard(
                          icon: Icons.assignment_return_outlined,
                          label: t.todayReturns,
                          value: '${store.todayReturnCount}',
                          hint: store.todayReturnCount == 0
                              ? t.todayReturnsHint
                              : formatTaka(store.todayReturnAmount),
                          tint: store.todayReturnCount == 0
                              ? AppColors.primaryLight
                              : const Color(0xFFFFF8E1),
                          iconColor: store.todayReturnCount == 0
                              ? AppColors.primary
                              : AppColors.accent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SaleHistoryScreen(
                                  returnsOnly: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final compact = h < 120;
            final pad = compact ? 10.0 : 14.0;
            final iconBox = compact ? 30.0 : 36.0;
            final iconSize = compact ? 17.0 : 20.0;
            final labelSize = compact ? 11.0 : 12.0;
            final valueSize = compact ? 14.0 : 16.0;
            final hintSize = compact ? 10.0 : 11.0;

            return Container(
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: iconSize),
                  ),
                  const Spacer(),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: labelSize,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: compact ? 1 : 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hint != null) ...[
                    SizedBox(height: compact ? 1 : 2),
                    Text(
                      hint!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: hintSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
