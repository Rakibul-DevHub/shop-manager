import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/tap_mark.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/product.dart';
import '../state/shop_store.dart';
import 'barcode_scan_screen.dart';

/// Counter POS: multi-item cart, hold bill, discount, return, weight qty.
class QuickSellScreen extends StatefulWidget {
  const QuickSellScreen({
    super.key,
    this.standalone = false,
    this.initialCode,
    this.openScannerOnStart = false,
  });

  final bool standalone;
  final String? initialCode;
  final bool openScannerOnStart;

  @override
  State<QuickSellScreen> createState() => _QuickSellScreenState();
}

class _QuickSellScreenState extends State<QuickSellScreen> {
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController(text: '1');
  final _itemDiscountValueController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _discountReasonController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _salesmanNameController = TextEditingController();
  final _salesmanIdController = TextEditingController();

  /// 0 = sell, 1 = return
  int _mode = 0;
  Product? _selected;
  int _pieceQty = 1;
  bool _weightMode = false;
  bool _flexiblePrice = false;
  DiscountType _itemDiscountType = DiscountType.none;
  String _paymentType = 'cash';
  DiscountType _discountType = DiscountType.none;
  final List<CartLine> _cart = [];
  bool _saving = false;
  bool _scannerOpened = false;

  @override
  void initState() {
    super.initState();
    final code = widget.initialCode?.trim();
    if (code != null && code.isNotEmpty) {
      _codeController.text = code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _findProduct();
      });
    } else if (widget.openScannerOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openScanner();
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _itemDiscountValueController.dispose();
    _discountValueController.dispose();
    _discountReasonController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _salesmanNameController.dispose();
    _salesmanIdController.dispose();
    super.dispose();
  }

  double get _unitPrice {
    if (_flexiblePrice) {
      return double.tryParse(_priceController.text.trim()) ??
          (_selected?.sellPrice ?? 0);
    }
    return _selected?.sellPrice ?? 0;
  }

  double get _weightQty =>
      double.tryParse(_weightController.text.trim()) ?? 0;

  double get _itemDiscountValue =>
      double.tryParse(_itemDiscountValueController.text.trim()) ?? 0;

  double get _linePreviewGross {
    if (_selected == null) return 0;
    return _weightMode ? _unitPrice * _weightQty : _unitPrice * _pieceQty;
  }

  double get _linePreviewDiscount => BillDiscount(
        type: _itemDiscountType,
        value: _itemDiscountValue,
      ).amountFor(_linePreviewGross);

  double get _linePreviewTotal =>
      (_linePreviewGross - _linePreviewDiscount).clamp(0, double.infinity);

  void _applyProductOffer(Product? product) {
    if (product == null || !product.hasOffer) {
      _itemDiscountType = DiscountType.none;
      _itemDiscountValueController.clear();
      return;
    }
    _itemDiscountType = product.discountType;
    final v = product.discountValue;
    _itemDiscountValueController.text = v <= 0
        ? ''
        : (v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString());
  }

  void _clearItemOfferForm() {
    _itemDiscountType = DiscountType.none;
    _itemDiscountValueController.clear();
  }

  double get _grossSubtotal => _cart.fold(0, (s, l) => s + l.lineGross);
  double get _itemDiscountTotal =>
      _cart.fold(0, (s, l) => s + l.lineDiscountAmount);
  /// After item offers; bill discount applies on this.
  double get _subtotal => _cart.fold(0, (s, l) => s + l.lineTotal);

  BillDiscount get _discount {
    final raw = double.tryParse(_discountValueController.text.trim()) ?? 0;
    return BillDiscount(
      type: _discountType,
      value: raw,
      reason: _discountReasonController.text.trim(),
    );
  }

  double get _billDiscountAmount => _discount.amountFor(_subtotal);
  double get _totalDiscount => _itemDiscountTotal + _billDiscountAmount;
  double get _payable =>
      (_subtotal - _billDiscountAmount).clamp(0, double.infinity);

  Future<void> _openScanner() async {
    if (_scannerOpened) return;
    _scannerOpened = true;
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    _scannerOpened = false;
    if (!mounted) return;
    if (code == null || code.trim().isEmpty) return;
    _codeController.text = code.trim();
    _findProduct();
  }

  void _findProduct() {
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final match = store.findProductByCode(_codeController.text);
    setState(() {
      _selected = match;
      _pieceQty = 1;
      _weightController.text = '1';
      _flexiblePrice = false;
      _applyProductOffer(match);
      if (match != null) {
        _priceController.text = match.sellPrice.toStringAsFixed(
          match.sellPrice.truncateToDouble() == match.sellPrice ? 0 : 2,
        );
      }
    });
    if (match == null && _codeController.text.trim().isNotEmpty) {
      showAppMessage(context, t.productNotFound);
    }
  }

  void _addToCart() {
    final t = AppText(context.read<ShopStore>().languageCode);
    if (_selected == null) return;
    if (_weightMode) {
      if (_weightQty <= 0) {
        showAppMessage(context, t.invalidWeight);
        return;
      }
      if (_weightQty.ceil() > _selected!.storeStock) {
        showAppMessage(
          context,
          context.read<ShopStore>().languageCode == 'bn'
              ? 'স্টোরে যথেষ্ট নেই'
              : 'Not enough store stock',
        );
        return;
      }
    } else if (_pieceQty > _selected!.storeStock) {
      showAppMessage(
        context,
        context.read<ShopStore>().languageCode == 'bn'
            ? 'স্টোরে যথেষ্ট নেই'
            : 'Not enough store stock',
      );
      return;
    }
    if (_unitPrice < _selected!.costPrice) {
      showAppMessage(
        context,
        context.read<ShopStore>().languageCode == 'bn'
            ? 'ক্রয় দামের নিচে দাম দেওয়া যাবে না'
            : 'Price cannot be below cost',
      );
      return;
    }

    setState(() {
      _cart.add(
        CartLine(
          product: _selected!,
          qty: _weightMode ? _weightQty : _pieceQty.toDouble(),
          unitPrice: _unitPrice,
          isWeight: _weightMode,
          discountType: _itemDiscountType,
          discountValue:
              _itemDiscountType == DiscountType.none ? 0 : _itemDiscountValue,
        ),
      );
      _selected = null;
      _codeController.clear();
      _pieceQty = 1;
      _weightController.text = '1';
      _flexiblePrice = false;
      _clearItemOfferForm();
    });
    showAppMessage(context, t.cartAdded);
  }

  void _holdBill() {
    final t = AppText(context.read<ShopStore>().languageCode);
    if (_cart.isEmpty) {
      showAppMessage(context, t.cartEmpty);
      return;
    }
    context.read<ShopStore>().parkBill(
          lines: List.of(_cart),
          discount: _discount,
        );
    setState(() {
      _cart.clear();
      _discountType = DiscountType.none;
      _discountValueController.clear();
      _discountReasonController.clear();
      _paymentType = 'cash';
    });
    showAppMessage(context, t.billHeld);
  }

  void _resumeBill(ParkedBill bill) {
    final taken = context.read<ShopStore>().takeParkedBill(bill.id);
    if (taken == null) return;
    setState(() {
      _cart
        ..clear()
        ..addAll(taken.lines);
      _discountType = taken.discount.type;
      _discountValueController.text = taken.discount.value <= 0
          ? ''
          : taken.discount.value.toString();
      _discountReasonController.text = taken.discount.reason;
      _mode = 0;
    });
  }

  Future<void> _checkout() async {
    final t = AppText(context.read<ShopStore>().languageCode);
    if (_cart.isEmpty) {
      showAppMessage(context, t.cartEmpty);
      return;
    }
    setState(() => _saving = true);
    final error = await context.read<ShopStore>().completeCartSale(
          lines: List.of(_cart),
          paymentType: _paymentType,
          discount: _discount,
          customerName: _customerNameController.text,
          customerPhone: _customerPhoneController.text,
          salesmanName: _salesmanNameController.text,
          salesmanId: _salesmanIdController.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    final paid = _payable;
    setState(() {
      _cart.clear();
      _discountType = DiscountType.none;
      _discountValueController.clear();
      _discountReasonController.clear();
      _customerNameController.clear();
      _customerPhoneController.clear();
      _paymentType = 'cash';
    });
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.saleDone),
        content: Text('${t.payable}: ${formatTaka(paid)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _doReturn() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final t = AppText(context.read<ShopStore>().languageCode);
    final error = await context.read<ShopStore>().returnToStock(
          product: _selected!,
          qty: _pieceQty,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    setState(() {
      _selected = null;
      _codeController.clear();
      _pieceQty = 1;
    });
    showAppMessage(context, t.returnDone);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);

    final body = ListView(
      children: [
        ScreenHeader(
          title: t.quickSellTitle,
          subtitle: t.quickSellHint,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.standalone)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              OfflineBadge(label: t.offline),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(value: 0, label: Text(t.sellMode)),
                  ButtonSegment(value: 1, label: Text(t.returnMode)),
                ],
                selected: {_mode},
                onSelectionChanged: (v) => setState(() {
                  _mode = v.first;
                  _selected = null;
                  _codeController.clear();
                  _clearItemOfferForm();
                }),
              ),
              const SizedBox(height: 12),
              const TapHint(
                number: 1,
                text: 'Scan or type code, add lines to cart, then checkout',
              ),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: t.productCode,
                  hintText: 'TS001-L',
                  prefixIcon: IconButton(
                    tooltip: t.scanCodeTitle,
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _findProduct,
                    icon: const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => _findProduct(),
              ),
              const SizedBox(height: 12),
              if (_selected != null) _buildSelectedCard(t),
              if (_mode == 0) ...[
                const SizedBox(height: 16),
                _buildCartSection(store, t),
                const SizedBox(height: 12),
                _buildDiscountSection(t),
                const SizedBox(height: 12),
                _buildPaymentSection(t),
                const SizedBox(height: 12),
                _buildHeldBills(store, t),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    if (widget.standalone) {
      return Scaffold(body: SafeArea(child: body));
    }
    return SafeArea(child: body);
  }

  Widget _buildSelectedCard(AppText t) {
    final p = _selected!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.code,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              p.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              '${p.variant} • ${t.storeQty}: ${p.storeStock}  •  ${t.warehouseQty}: ${p.warehouseStock}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (_mode == 0) ...[
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(t.pieceMode)),
                  ButtonSegment(value: true, label: Text(t.weightMode)),
                ],
                selected: {_weightMode},
                onSelectionChanged: (v) => setState(() => _weightMode = v.first),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.flexiblePrice),
                value: _flexiblePrice,
                onChanged: (v) {
                  setState(() {
                    _flexiblePrice = v;
                    if (!v) {
                      _priceController.text = p.sellPrice.toStringAsFixed(0);
                    }
                  });
                },
              ),
              if (_flexiblePrice)
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _weightMode
                        ? '${t.sellPriceField} / kg'
                        : t.sellPriceField,
                    prefixText: '৳ ',
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                Text(
                  _weightMode
                      ? '${t.sellPrice}/kg: ${formatTaka(p.sellPrice)}'
                      : '${t.sellPrice}: ${formatTaka(p.sellPrice)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const SizedBox(height: 10),
              if (_weightMode)
                TextField(
                  controller: _weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: t.weightQty),
                  onChanged: (_) => setState(() {}),
                )
              else
                Row(
                  children: [
                    Text(t.qty, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    QuantityStepper(
                      value: _pieceQty,
                      max: p.storeStock,
                      onChanged: (v) => setState(() => _pieceQty = v),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                t.itemDiscount,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (p.hasOffer) ...[
                const SizedBox(height: 4),
                Text(
                  '${t.productDiscount}: '
                  '${p.discountType == DiscountType.percent ? '${p.discountValue.toStringAsFixed(p.discountValue.truncateToDouble() == p.discountValue ? 0 : 1)}%' : formatTaka(p.discountValue)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(t.discountNone),
                    selected: _itemDiscountType == DiscountType.none,
                    onSelected: (_) => setState(() {
                      _itemDiscountType = DiscountType.none;
                      _itemDiscountValueController.clear();
                    }),
                  ),
                  ChoiceChip(
                    label: Text(t.discountPercent),
                    selected: _itemDiscountType == DiscountType.percent,
                    onSelected: (_) =>
                        setState(() => _itemDiscountType = DiscountType.percent),
                  ),
                  ChoiceChip(
                    label: Text(t.discountAmount),
                    selected: _itemDiscountType == DiscountType.amount,
                    onSelected: (_) =>
                        setState(() => _itemDiscountType = DiscountType.amount),
                  ),
                ],
              ),
              if (_itemDiscountType != DiscountType.none) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _itemDiscountValueController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _itemDiscountType == DiscountType.percent
                        ? t.discountPercent
                        : t.discountAmount,
                    prefixText:
                        _itemDiscountType == DiscountType.percent ? null : '৳ ',
                    suffixText:
                        _itemDiscountType == DiscountType.percent ? '%' : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 10),
              if (_linePreviewDiscount > 0) ...[
                Text(
                  '${t.subtotal}: ${formatTaka(_linePreviewGross)}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '${t.youSave}: ${formatTaka(_linePreviewDiscount)}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              Text(
                '${t.total}: ${formatTaka(_linePreviewTotal)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: t.addToCart, onPressed: _addToCart),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(t.qty, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  QuantityStepper(
                    value: _pieceQty,
                    max: 99,
                    onChanged: (v) => setState(() => _pieceQty = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: _saving ? '...' : t.returnStock,
                onPressed: _saving ? null : _doReturn,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection(ShopStore store, AppText t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${t.cart} (${_cart.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (_cart.isNotEmpty)
              TextButton(onPressed: _holdBill, child: Text(t.holdBill)),
          ],
        ),
        if (_cart.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              t.cartEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...List.generate(_cart.length, (i) {
            final line = _cart[i];
            final cut = line.lineDiscountAmount;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  line.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  [
                    '${line.product.code} • ${line.qtyLabel} × ${formatTaka(line.unitPrice)}${line.isWeight ? ' /kg' : ''}',
                    if (cut > 0)
                      line.discountType == DiscountType.percent
                          ? '${t.itemDiscount}: ${line.discountValue.toStringAsFixed(line.discountValue.truncateToDouble() == line.discountValue ? 0 : 1)}% (−${formatTaka(cut)})'
                          : '${t.itemDiscount}: −${formatTaka(cut)}',
                  ].join('\n'),
                ),
                isThreeLine: cut > 0,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (cut > 0)
                          Text(
                            formatTaka(line.lineGross),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          formatTaka(line.lineTotal),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: t.remove,
                      onPressed: () => setState(() => _cart.removeAt(i)),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            );
          }),
        if (_cart.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${t.subtotal}: ${formatTaka(_grossSubtotal)}'),
          if (_itemDiscountTotal > 0)
            Text(
              '${t.itemDiscount}: -${formatTaka(_itemDiscountTotal)}',
              style: const TextStyle(color: AppColors.accent),
            ),
          if (_billDiscountAmount > 0)
            Text(
              '${t.billDiscount}: -${formatTaka(_billDiscountAmount)}',
              style: const TextStyle(color: AppColors.accent),
            ),
          if (_totalDiscount > 0)
            Text(
              '${t.youSave}: ${formatTaka(_totalDiscount)}',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          Text(
            '${t.payable}: ${formatTaka(_payable)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDiscountSection(AppText t) {
    final liveBillCut = _billDiscountAmount;
    final liveAfter = _payable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.billDiscount, style: const TextStyle(fontWeight: FontWeight.w800)),
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
              onSelected: (_) => setState(() => _discountType = DiscountType.percent),
            ),
            ChoiceChip(
              label: Text(t.discountAmount),
              selected: _discountType == DiscountType.amount,
              onSelected: (_) => setState(() => _discountType = DiscountType.amount),
            ),
          ],
        ),
        if (_discountType != DiscountType.none) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _discountValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _discountType == DiscountType.percent
                  ? t.discountPercent
                  : t.discountAmount,
              prefixText: _discountType == DiscountType.percent ? null : '৳ ',
              suffixText: _discountType == DiscountType.percent ? '%' : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _discountReasonController,
            decoration: InputDecoration(labelText: t.discountReason),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t.youSave}: ${formatTaka(liveBillCut)}'
                  '${_discountType == DiscountType.percent && (_discount.value) > 0 ? ' (${_discount.value.toStringAsFixed(_discount.value.truncateToDouble() == _discount.value ? 0 : 1)}%)' : ''}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.afterDiscount}: ${formatTaka(liveAfter)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSection(AppText t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'cash', label: Text(t.cash)),
            ButtonSegment(value: 'due', label: Text(t.dueSale)),
          ],
          selected: {_paymentType},
          onSelectionChanged: (v) => setState(() => _paymentType = v.first),
        ),
        if (_paymentType == 'due') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(labelText: t.customerName),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customerPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: t.customerPhone),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          t.salesmanOptional,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _salesmanNameController,
          decoration: InputDecoration(labelText: t.salesmanName),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _salesmanIdController,
          decoration: InputDecoration(labelText: t.salesmanId),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: _saving ? '...' : t.checkout,
          onPressed: _saving || _cart.isEmpty ? null : _checkout,
        ),
      ],
    );
  }

  Widget _buildHeldBills(ShopStore store, AppText t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.heldBills, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (store.parkedBills.isEmpty)
          Text(
            t.noHeldBills,
            style: const TextStyle(color: AppColors.textSecondary),
          )
        else
          ...store.parkedBills.map(
            (bill) => Card(
              child: ListTile(
                title: Text(bill.label),
                subtitle: Text(
                  '${bill.lines.length} items • ${formatTaka(bill.subtotal)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _resumeBill(bill),
                      child: Text(t.resumeBill),
                    ),
                    IconButton(
                      tooltip: t.discardBill,
                      onPressed: () => store.discardParkedBill(bill.id),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
