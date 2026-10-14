import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _nameController = TextEditingController();
  final _customTypeController = TextEditingController();
  String? _selectedType;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  String get _resolvedType {
    final custom = _customTypeController.text.trim();
    if (custom.isNotEmpty) return custom;
    return _selectedType?.trim() ?? '';
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final store = context.read<ShopStore>();
    final error = await store.saveShop(
      name: _nameController.text,
      type: _resolvedType,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      showAppMessage(context, error);
      return;
    }
    // AppGate switches to MainShell automatically.
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                t.shopSetup,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                t.shopSetupHint,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t.shopName,
                  hintText: 'রহিম স্টোর',
                  prefixIcon: const Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                t.shopType,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ShopStore.shopTypes.map((type) {
                  final selected = _selectedType == type &&
                      _customTypeController.text.trim().isEmpty;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selectedType = type;
                      _customTypeController.clear();
                    }),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                t.shopTypeCustomHint,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _customTypeController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: t.shopTypeCustomLabel,
                  hintText: t.shopTypeCustomHint,
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      _selectedType = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 36),
              PrimaryButton(
                label: _loading ? '...' : t.startNow,
                onPressed: _loading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
