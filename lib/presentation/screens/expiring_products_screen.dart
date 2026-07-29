import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/product_list_tile.dart';
import '../state/shop_store.dart';

class ExpiringProductsScreen extends StatelessWidget {
  const ExpiringProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final expired = store.expiredProducts;
    final soon = store.expiringSoonProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.expiryAlerts),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: (expired.isEmpty && soon.isEmpty)
            ? Center(
                child: Text(
                  t.noExpiryAlerts,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    t.expiryAlertsHint,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (expired.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      t.expired,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...expired.map((p) => ProductListTile(product: p)),
                  ],
                  if (soon.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.expiringSoon,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...soon.map((p) => ProductListTile(product: p)),
                  ],
                ],
              ),
      ),
    );
  }
}
