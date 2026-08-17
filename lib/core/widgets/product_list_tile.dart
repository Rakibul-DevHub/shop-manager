import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../text/app_text.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/product.dart';
import '../../presentation/state/shop_store.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';

enum ProductQtyFocus { store, warehouse, both }

class ProductListTile extends StatelessWidget {
  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
    this.qtyFocus = ProductQtyFocus.both,
  });

  final Product product;
  final VoidCallback? onTap;
  final Widget? trailing;
  final ProductQtyFocus qtyFocus;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final threshold = store.lowStockThreshold;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.code,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${product.variant} • ${t.cost} ${formatTaka(product.costPrice)} • ${t.sellPrice} ${formatTaka(product.sellPrice)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (qtyFocus == ProductQtyFocus.both) ...[
                const SizedBox(height: 4),
                Text(
                  store.warehouseInventoryEnabled
                      ? '${t.storeQty}: ${product.storeStock}  •  ${t.warehouseQty}: ${product.warehouseStock}'
                      : '${t.stock}: ${product.storeStock}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
              if (product.hasOffer) ...[
                const SizedBox(height: 4),
                Text(
                  product.discountType == DiscountType.percent
                      ? '${t.productDiscount}: ${product.discountValue.toStringAsFixed(product.discountValue.truncateToDouble() == product.discountValue ? 0 : 1)}%'
                      : '${t.productDiscount}: ${formatTaka(product.discountValue)}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
              if (store.expiryFeatureEnabled && product.hasExpiry) ...[
                const SizedBox(height: 6),
                _ExpiryBadge(product: product, t: t),
              ],
            ],
          ),
        ),
        isThreeLine: true,
        trailing: trailing ??
            _DefaultQtyTrailing(
              product: product,
              t: t,
              qtyFocus: qtyFocus,
              threshold: threshold,
            ),
      ),
    );
  }
}

class _DefaultQtyTrailing extends StatelessWidget {
  const _DefaultQtyTrailing({
    required this.product,
    required this.t,
    required this.qtyFocus,
    required this.threshold,
  });

  final Product product;
  final AppText t;
  final ProductQtyFocus qtyFocus;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final label = switch (qtyFocus) {
      ProductQtyFocus.store => t.storeTab,
      ProductQtyFocus.warehouse => t.stockTab,
      ProductQtyFocus.both => t.totalQty,
    };
    final value = switch (qtyFocus) {
      ProductQtyFocus.store => product.storeStock,
      ProductQtyFocus.warehouse => product.warehouseStock,
      ProductQtyFocus.both => product.totalStock,
    };
    final danger = value <= threshold;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: danger ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.product, required this.t});

  final Product product;
  final AppText t;

  @override
  Widget build(BuildContext context) {
    final days = product.daysUntilExpiry ?? 0;
    final Color color;
    final String label;
    if (product.isExpired) {
      color = AppColors.danger;
      label =
          '${t.expired} • ${DateFormat('dd MMM yyyy').format(product.expiryDay!)}'
          ' (${days.abs()} ${t.expiredAgo})';
    } else if (product.isExpiringSoon()) {
      color = AppColors.accent;
      label =
          '${t.expiringSoon} • ${DateFormat('dd MMM yyyy').format(product.expiryDay!)}'
          ' ($days ${t.daysLeft})';
    } else {
      color = AppColors.primary;
      label =
          '${t.expiresOn} ${DateFormat('dd MMM yyyy').format(product.expiryDay!)}'
          ' ($days ${t.daysLeft})';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
