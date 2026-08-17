import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/product.dart';
import '../state/shop_store.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _variantController = TextEditingController();
  final _codeController = TextEditingController();
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _stockController = TextEditingController();
  final _storeStockController = TextEditingController();
  final _discountValueController = TextEditingController();
  DateTime? _expiryDate;
  DiscountType _discountType = DiscountType.none;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _variantController.dispose();
    _codeController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    _storeStockController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      helpText: AppText(context.read<ShopStore>().languageCode).expiryDate,
    );
    if (picked != null) {
      setState(() {
        _expiryDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  String? _validate(ShopStore store, AppText t) {
    final name = _nameController.text.trim();
    final variant = _variantController.text.trim();
    final code = _codeController.text.trim();
    final costText = _costController.text.trim();
    final sellText = _sellController.text.trim();
    final stockText = _stockController.text.trim();
    final storeStockText = _storeStockController.text.trim();
    final discountText = _discountValueController.text.trim();

    if (name.isEmpty ||
        variant.isEmpty ||
        code.isEmpty ||
        costText.isEmpty ||
        sellText.isEmpty ||
        stockText.isEmpty ||
        (store.warehouseInventoryEnabled && storeStockText.isEmpty)) {
      return t.fillAllFields;
    }

    final cost = double.tryParse(costText);
    final sell = double.tryParse(sellText);
    if (cost == null || cost < 0 || sell == null || sell < 0) {
      return t.invalidPrice;
    }

    final stockQty = int.tryParse(stockText);
    if (stockQty == null || stockQty < 0) {
      return t.invalidStockQty;
    }
    if (store.warehouseInventoryEnabled) {
      final storeQty = int.tryParse(storeStockText);
      if (storeQty == null || storeQty < 0) {
        return t.invalidStockQty;
      }
    }

    if (_discountType != DiscountType.none) {
      if (discountText.isEmpty) return t.discountValueRequired;
      final value = double.tryParse(discountText);
      if (value == null || value < 0) return t.discountValueRequired;
      if (_discountType == DiscountType.percent && value > 100) {
        return store.languageCode == 'bn'
            ? 'শতাংশ ১০০-এর বেশি হতে পারে না'
            : 'Percent cannot be over 100';
      }
    }

    if (store.expiryFeatureEnabled && _expiryDate == null) {
      return t.expiryRequired;
    }

    return null;
  }

  Future<void> _save() async {
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final validationError = _validate(store, t);
    if (validationError != null) {
      showAppMessage(context, validationError);
      return;
    }

    setState(() => _saving = true);
    final warehouseOn = store.warehouseInventoryEnabled;
    final stockQty = int.parse(_stockController.text.trim());
    final storeQty = warehouseOn
        ? int.parse(_storeStockController.text.trim())
        : stockQty;
    final error = await store.addProduct(
      Product(
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        variant: _variantController.text.trim(),
        costPrice: double.parse(_costController.text.trim()),
        sellPrice: double.parse(_sellController.text.trim()),
        warehouseStock: warehouseOn ? stockQty : 0,
        storeStock: storeQty,
        expiryDate: store.expiryFeatureEnabled ? _expiryDate : null,
        discountType: _discountType,
        discountValue: _discountType == DiscountType.none
            ? 0
            : double.parse(_discountValueController.text.trim()),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final warehouseOn = store.warehouseInventoryEnabled;
    final expiryOn = store.expiryFeatureEnabled;
    final expiryLabel = _expiryDate == null
        ? t.noExpiry
        : DateFormat('dd MMM yyyy').format(_expiryDate!);
    final sellPreview = double.tryParse(_sellController.text.trim()) ?? 0;
    final offerValue =
        double.tryParse(_discountValueController.text.trim()) ?? 0;
    final offerCut = BillDiscount(type: _discountType, value: offerValue)
        .amountFor(sellPreview);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.addProductTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${t.productName} *',
                  hintText: 'টি-শার্ট',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _variantController,
                      decoration: InputDecoration(
                        labelText: '${t.variant} *',
                        hintText: 'L / 5kg',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: '${t.codeLabel} *',
                        hintText: 'TS002-L',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${t.costPrice} *',
                        prefixText: '৳ ',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _sellController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${t.sellPriceField} *',
                        prefixText: '৳ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (warehouseOn) ...[
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${t.warehouseQty} *',
                    hintText: '20',
                    helperText: t.stockHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _storeStockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${t.storeQty} *',
                    hintText: '0',
                    helperText: t.storeHint,
                  ),
                ),
              ] else
                TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '${t.stockCount} *',
                    hintText: '20',
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                t.productDiscount,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                t.productDiscountHint,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(t.discountNone),
                    selected: _discountType == DiscountType.none,
                    onSelected: (_) => setState(() {
                      _discountType = DiscountType.none;
                      _discountValueController.clear();
                    }),
                  ),
                  ChoiceChip(
                    label: Text(t.discountPercent),
                    selected: _discountType == DiscountType.percent,
                    onSelected: (_) =>
                        setState(() => _discountType = DiscountType.percent),
                  ),
                  ChoiceChip(
                    label: Text(t.discountAmount),
                    selected: _discountType == DiscountType.amount,
                    onSelected: (_) =>
                        setState(() => _discountType = DiscountType.amount),
                  ),
                ],
              ),
              if (_discountType != DiscountType.none) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _discountValueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _discountType == DiscountType.percent
                        ? '${t.discountPercent} *'
                        : '${t.discountAmount} *',
                    prefixText:
                        _discountType == DiscountType.percent ? null : '৳ ',
                    suffixText:
                        _discountType == DiscountType.percent ? '%' : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (sellPreview > 0 && offerCut > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${t.youSave}: ${formatTaka(offerCut)}  →  ${t.afterDiscount}: ${formatTaka(sellPreview - offerCut)}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
              if (expiryOn) ...[
                const SizedBox(height: 16),
                Text(
                  '${t.expiryDate} *',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  t.expiryDateHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickExpiry,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.expiryDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  expiryLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_expiryDate != null)
                            IconButton(
                              tooltip: t.clearExpiryDate,
                              onPressed: () =>
                                  setState(() => _expiryDate = null),
                              icon: const Icon(Icons.close),
                            )
                          else
                            Text(
                              t.setExpiryDate,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  store.languageCode == 'bn'
                      ? 'সব ঘর পূরণ করতে হবে। খালি রাখা যাবে না।'
                      : 'All fields are required. Empty values are not allowed.',
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _saving ? '...' : t.saveProduct,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
