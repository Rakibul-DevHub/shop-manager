import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_text.dart';
import '../models/customer.dart';
import '../state/shop_store.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/offline_badge.dart';
import '../widgets/screen_header.dart';
import 'payment_collection_screen.dart';

class DueCustomersScreen extends StatelessWidget {
  const DueCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final customers = store.dueCustomers;

    return SafeArea(
      child: customers.isEmpty
          ? Column(
              children: [
                ScreenHeader(
                  title: t.dueBook,
                  subtitle: t.dueBookHint,
                  trailing: OfflineBadge(label: t.offline),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      t.noDues,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              children: [
                ScreenHeader(
                  title: t.dueBook,
                  subtitle: t.dueBookHint,
                  trailing: OfflineBadge(label: t.offline),
                ),
                ...customers.map(
                  (customer) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _DueCard(
                      customer: customer,
                      collectLabel: t.collectMoney,
                      dueLabel: t.due,
                      onCollect: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentCollectionScreen(customer: customer),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard({
    required this.customer,
    required this.collectLabel,
    required this.dueLabel,
    required this.onCollect,
  });

  final Customer customer;
  final String collectLabel;
  final String dueLabel;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    customer.name.isEmpty
                        ? '?'
                        : String.fromCharCodes(customer.name.runes.take(1)),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dueLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatTaka(customer.dueAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCollect,
                child: Text(collectLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
