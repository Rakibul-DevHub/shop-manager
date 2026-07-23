import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/tap_mark.dart';
import 'daily_report_screen.dart';
import 'expense_screen.dart';
import 'low_stock_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);

    final items = [
      _MoreItem(
        title: t.report,
        subtitle: t.reportHint,
        icon: Icons.bar_chart_rounded,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DailyReportScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.expense,
        subtitle: t.expenseHint,
        icon: Icons.receipt_long_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ExpenseScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.lowStock,
        subtitle: t.lowStockHint,
        icon: Icons.warning_amber_rounded,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LowStockScreen()),
          );
        },
      ),
      _MoreItem(
        title: t.settings,
        subtitle: t.settingsHint,
        icon: Icons.settings_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];

    return SafeArea(
      child: ListView(
        children: [
          ScreenHeader(
            title: t.moreTitle,
            subtitle: t.moreHint,
            trailing: OfflineBadge(label: t.offline),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TapHint(
              number: 1,
              text: 'Tap a row: Report / Expense / Low stock / Settings',
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Card(
                child: ListTile(
                  onTap: item.onTap,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(item.icon, color: AppColors.primary),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
