import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../domain/entities/product.dart';
import '../state/shop_store.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/product_list_tile.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/tap_mark.dart';
import 'add_product_screen.dart';
import 'quick_sell_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final items = store.searchProducts(_searchController.text);

    return SafeArea(
      child: Column(
        children: [
          ScreenHeader(
            title: t.productsTitle,
            subtitle: t.searchProducts,
            trailing: OfflineBadge(label: t.offline),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: t.searchProducts,
                hintText: 'TS001-L',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TapHint(
              number: 1,
              text: 'Tap নতুন পণ্য যোগ করুন to add stock',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(t.addProduct),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      t.searchProducts,
                      style: const TextStyle(color: Color(0xFF5C6B68)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final Product product = items[index];
                      return ProductListTile(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const QuickSellScreen(standalone: true),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
