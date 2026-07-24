import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../../domain/entities/product.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/tap_mark.dart';
import 'barcode_scan_screen.dart';

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
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  Product? _selected;
  int _qty = 1;
  bool _flexiblePrice = false;
  String _paymentType = 'cash';
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
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  double get _unitPrice {
    if (_flexiblePrice) {
      return double.tryParse(_priceController.text.trim()) ??
          (_selected?.sellPrice ?? 0);
    }
    return _selected?.sellPrice ?? 0;
  }

  double get _total => _unitPrice * _qty;

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
      _qty = 1;
      _flexiblePrice = false;
      _paymentType = 'cash';
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

  Future<void> _completeSale() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    final t = AppText(store.languageCode);
    final error = await store.completeSale(
      product: _selected!,
      qty: _qty,
      unitPrice: _unitPrice,
      paymentType: _paymentType,
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppMessage(context, error);
      return;
    }

    final sold = _selected!;
    final qty = _qty;
    final total = _total;

    setState(() {
      _selected = null;
      _codeController.clear();
      _priceController.clear();
      _customerNameController.clear();
      _customerPhoneController.clear();
      _qty = 1;
      _flexiblePrice = false;
      _paymentType = 'cash';
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.saleDone),
        content: Text('${sold.name} × $qty\n${t.total}: ${formatTaka(total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ok),
          ),
        ],
      ),
    );
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
            children: [
              const _SellSteps(),
              const SizedBox(height: 12),
              const TapHint(
                number: 1,
                text: 'Scan QR/barcode with the camera, or type a code',
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
              const SizedBox(height: 16),
              if (_selected != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selected!.code,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selected!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_selected!.variant} • ${t.stock}: ${_selected!.stock}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            t.flexiblePrice,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(t.flexiblePriceHint),
                          value: _flexiblePrice,
                          onChanged: (value) {
                            setState(() {
                              _flexiblePrice = value;
                              if (!value && _selected != null) {
                                _priceController.text =
                                    _selected!.sellPrice.toStringAsFixed(0);
                              }
                            });
                          },
                        ),
                        if (_flexiblePrice)
                          TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: t.sellPriceField,
                              prefixText: '৳ ',
                              helperText:
                                  '${t.costPrice}: ${formatTaka(_selected!.costPrice)}',
                            ),
                            onChanged: (_) => setState(() {}),
                          )
                        else
                          Text(
                            '${t.sellPrice}: ${formatTaka(_selected!.sellPrice)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              t.qty,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            QuantityStepper(
                              value: _qty,
                              max: _selected!.stock,
                              onChanged: (value) => setState(() => _qty = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'cash', label: Text(t.cash)),
                            ButtonSegment(value: 'due', label: Text(t.dueSale)),
                          ],
                          selected: {_paymentType},
                          onSelectionChanged: (value) {
                            setState(() => _paymentType = value.first);
                          },
                        ),
                        if (_paymentType == 'due') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(labelText: t.customerName),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _customerPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(labelText: t.customerPhone),
                          ),
                        ],
                        const Divider(height: 28),
                        Row(
                          children: [
                            Text(
                              t.total,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formatTaka(_total),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const TapHint(
                  number: 2,
                  text: 'Adjust qty / price, then tap বিক্রি সম্পন্ন',
                ),
                PrimaryButton(
                  label: _saving ? '...' : t.completeSale,
                  onPressed: _saving ? null : _completeSale,
                ),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    t.quickSellHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
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
}

class _SellSteps extends StatelessWidget {
  const _SellSteps();

  @override
  Widget build(BuildContext context) {
    const steps = ['কোড দিন', 'পণ্য দেখুন', '+/- চাপুন', 'বিক্রি শেষ'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'বিক্রি করার সহজ নিয়ম',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0)
                const Expanded(
                  child: Divider(color: AppColors.border, thickness: 1),
                ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[i],
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
