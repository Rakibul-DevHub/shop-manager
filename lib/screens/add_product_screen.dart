import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_text.dart';
import '../models/product.dart';
import '../state/shop_store.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/offline_badge.dart';

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
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _variantController.dispose();
    _codeController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    final error = await store.addProduct(
      Product(
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        variant: _variantController.text.trim().isEmpty
            ? '-'
            : _variantController.text.trim(),
        costPrice: double.tryParse(_costController.text.trim()) ?? 0,
        sellPrice: double.tryParse(_sellController.text.trim()) ?? 0,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
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
    final t = AppText(context.watch<ShopStore>().languageCode);

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
                  labelText: t.productName,
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
                        labelText: t.variant,
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
                        labelText: t.codeLabel,
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
                        labelText: t.costPrice,
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
                        labelText: t.sellPriceField,
                        prefixText: '৳ ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.stockCount,
                  hintText: '20',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.watch<ShopStore>().languageCode == 'bn'
                      ? 'নাম → সাইজ → দাম ও স্টক → সেভ করুন।'
                      : 'Name → size → price & stock → save.',
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
