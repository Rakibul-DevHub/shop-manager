import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/product_list_tile.dart';
import '../../core/widgets/screen_header.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/product.dart';
import '../state/shop_store.dart';
import 'add_product_screen.dart';
import 'expiring_products_screen.dart';
import 'quick_sell_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  /// 0 = Store (shop), 1 = Stock (warehouse)
  int _tab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openOfferEditor(Product product) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ProductOfferSheet(product: product),
    );
    if (saved == true && mounted) {
      showAppMessage(
        context,
        AppText(context.read<ShopStore>().languageCode).offerSaved,
      );
    }
  }

  Future<void> _openTransfer({
    required Product product,
    required bool toStore,
  }) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _TransferSheet(product: product, toStore: toStore),
    );
    if (done == true && mounted) {
      showAppMessage(
        context,
        AppText(context.read<ShopStore>().languageCode).transferDone,
      );
    }
  }

  Widget _expiryBanner(ShopStore store, AppText t) {
    if (!store.expiryFeatureEnabled || store.expiryAlertProducts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExpiringProductsScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.event_busy_outlined, color: Color(0xFFC63B3B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${t.expiryAlerts}: ${store.expiryAlertProducts.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC63B3B),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFC63B3B)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddProduct() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final items = store.searchProducts(_searchController.text);
    final warehouseOn = store.warehouseInventoryEnabled;
    final isStore = !warehouseOn || _tab == 0;

    return SafeArea(
      child: Column(
        children: [
          ScreenHeader(
            title: warehouseOn ? t.productsTitle : t.productsTitleSimple,
            subtitle: warehouseOn
                ? (isStore ? t.storeHint : t.stockHint)
                : t.storeHintSimple,
            trailing: OfflineBadge(label: t.offline),
          ),
          if (warehouseOn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(t.storeTab),
                    icon: const Icon(Icons.storefront_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(t.stockTab),
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (v) => setState(() => _tab = v.first),
              ),
            ),
          if (warehouseOn) const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          _expiryBanner(store, t),
          const SizedBox(height: 8),
          if (isStore) ...[
            if (!warehouseOn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openAddProduct,
                    icon: const Icon(Icons.add),
                    label: Text(t.addProduct),
                  ),
                ),
              ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openAddProduct,
                  icon: const Icon(Icons.add),
                  label: Text(t.addProduct),
                ),
              ),
            ),
          ],
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
                      final product = items[index];
                      if (isStore) {
                        return ProductListTile(
                          product: product,
                          qtyFocus: ProductQtyFocus.store,
                          onTap: () => _openOfferEditor(product),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'offer') {
                                _openOfferEditor(product);
                              } else if (value == 'sell') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuickSellScreen(
                                      standalone: true,
                                      initialCode: product.code,
                                    ),
                                  ),
                                );
                              } else if (value == 'toWarehouse') {
                                _openTransfer(
                                  product: product,
                                  toStore: false,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'offer',
                                child: Text(t.setProductOffer),
                              ),
                              PopupMenuItem(
                                value: 'sell',
                                child: Text(t.sell),
                              ),
                              if (warehouseOn)
                                PopupMenuItem(
                                  value: 'toWarehouse',
                                  child: Text(t.returnToWarehouse),
                                ),
                            ],
                            child: _QtyChip(
                              label: t.storeQty,
                              value: product.storeStock,
                              accent: product.hasOffer,
                            ),
                          ),
                        );
                      }
                      return ProductListTile(
                        product: product,
                        qtyFocus: ProductQtyFocus.warehouse,
                        onTap: () => _openTransfer(
                          product: product,
                          toStore: true,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'toStore') {
                              _openTransfer(product: product, toStore: true);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'toStore',
                              child: Text(t.sendToStore),
                            ),
                          ],
                          child: _QtyChip(
                            label: t.warehouseQty,
                            value: product.warehouseStock,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QtyChip extends StatelessWidget {
  const _QtyChip({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final int value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accent ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferSheet extends StatefulWidget {
  const _TransferSheet({
    required this.product,
    required this.toStore,
  });

  final Product product;
  final bool toStore;

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  late int _qty;
  bool _saving = false;

  Product get product => widget.product;
  bool get toStore => widget.toStore;
  int get maxQty => toStore ? product.warehouseStock : product.storeStock;

  @override
  void initState() {
    super.initState();
    _qty = maxQty > 0 ? 1 : 0;
  }

  Future<void> _save() async {
    if (_qty <= 0 || _qty > maxQty) return;
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    final error = toStore
        ? await store.transferWarehouseToStore(product: product, qty: _qty)
        : await store.transferStoreToWarehouse(product: product, qty: _qty);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            toStore ? t.sendToStore : t.returnToWarehouse,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${product.name} • ${product.code}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text('${t.storeQty}: ${product.storeStock}'),
          Text('${t.warehouseQty}: ${product.warehouseStock}'),
          const SizedBox(height: 16),
          if (maxQty <= 0)
            Text(
              toStore ? t.stockHint : t.notEnoughStore,
              style: const TextStyle(color: AppColors.danger),
            )
          else ...[
            Text(t.transferQty, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                QuantityStepper(
                  value: _qty,
                  min: 1,
                  max: maxQty,
                  onChanged: (v) => setState(() => _qty = v),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _qty = maxQty),
                  child: Text('Max $maxQty'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _saving
                  ? '...'
                  : (toStore ? t.sendToStore : t.returnToWarehouse),
              onPressed: _saving ? null : _save,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ProductOfferSheet extends StatefulWidget {
  const _ProductOfferSheet({required this.product});

  final Product product;

  @override
  State<_ProductOfferSheet> createState() => _ProductOfferSheetState();
}

class _ProductOfferSheetState extends State<_ProductOfferSheet> {
  late DiscountType _type;
  late final TextEditingController _valueController;
  bool _saving = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _type = product.discountType;
    final v = product.discountValue;
    _valueController = TextEditingController(
      text: !product.hasOffer
          ? ''
          : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString()),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final value = double.tryParse(_valueController.text.trim()) ?? 0;
    final error = await context.read<ShopStore>().updateProductOffer(
          product: product,
          discountType: _type,
          discountValue: value,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);
    final raw = double.tryParse(_valueController.text.trim()) ?? 0;
    final previewCut =
        BillDiscount(type: _type, value: raw).amountFor(product.sellPrice);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.setProductOffer,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.name} • ${product.code}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text('${t.storeQty}: ${product.storeStock}'),
            Text('${t.warehouseQty}: ${product.warehouseStock}'),
            Text(
              '${t.sellPrice}: ${formatTaka(product.sellPrice)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              t.productDiscountHint,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(t.discountNone),
                  selected: _type == DiscountType.none,
                  onSelected: (_) => setState(() {
                    _type = DiscountType.none;
                    _valueController.clear();
                  }),
                ),
                ChoiceChip(
                  label: Text(t.discountPercent),
                  selected: _type == DiscountType.percent,
                  onSelected: (_) =>
                      setState(() => _type = DiscountType.percent),
                ),
                ChoiceChip(
                  label: Text(t.discountAmount),
                  selected: _type == DiscountType.amount,
                  onSelected: (_) =>
                      setState(() => _type = DiscountType.amount),
                ),
              ],
            ),
            if (_type != DiscountType.none) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _valueController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _type == DiscountType.percent
                      ? t.discountPercent
                      : t.discountAmount,
                  prefixText: _type == DiscountType.percent ? null : '৳ ',
                  suffixText: _type == DiscountType.percent ? '%' : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (previewCut > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '${t.youSave}: ${formatTaka(previewCut)}  →  ${t.afterDiscount}: ${formatTaka(product.sellPrice - previewCut)}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  t.noOffer,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: _saving ? '...' : t.saveOffer,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
