import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../state/shop_store.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/product_list_tile.dart';

class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final lowStock = store.lowStockProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.lowStockTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: lowStock.isEmpty
            ? Center(
                child: Text(
                  store.languageCode == 'bn'
                      ? 'কম স্টকের পণ্য নেই'
                      : 'No low stock items',
                  style: const TextStyle(color: Color(0xFF5C6B68)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    t.lowStockHint,
                    style: const TextStyle(color: Color(0xFF5C6B68)),
                  ),
                  const SizedBox(height: 12),
                  ...lowStock.map((product) => ProductListTile(product: product)),
                ],
              ),
      ),
    );
  }
}
