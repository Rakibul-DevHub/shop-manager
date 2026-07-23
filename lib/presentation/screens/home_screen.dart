import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/tap_mark.dart';
import 'quick_sell_screen.dart';

/// PDF Home Dashboard: Quick Sell + category shortcuts
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
                      t.homeTitle,
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
            text: 'Tap the green Quick Sell banner to open POS',
          ),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickSellScreen(standalone: true),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
              Text(
                t.shopType,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              const TapMark(2, tooltip: 'Or tap a category → Quick Sell'),
            ],
          ),
          const SizedBox(height: 8),
          const TapHint(
            number: 2,
            text: 'Or tap any category tile (same as Quick Sell)',
          ),
          const SizedBox(height: 4),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: ShopStore.shopTypes.map((type) {
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuickSellScreen(standalone: true),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _iconForType(type),
                          color: AppColors.primary,
                          size: 26,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          type,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: t.todaySales,
                  value: formatTaka(store.todaySalesTotal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: t.due,
                  value: formatTaka(store.totalDue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains('মুদি')) return Icons.shopping_basket_outlined;
    if (type.contains('কাপড়')) return Icons.checkroom_outlined;
    if (type.contains('মোবাইল')) return Icons.phone_android_outlined;
    if (type.contains('কসমেটিকস')) return Icons.spa_outlined;
    if (type.contains('ফাস্ট')) return Icons.fastfood_outlined;
    return Icons.storefront_outlined;
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
