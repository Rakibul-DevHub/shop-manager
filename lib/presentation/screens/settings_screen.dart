import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/text/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/offline_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _language;
  late TextEditingController _shopNameController;
  late TextEditingController _thresholdController;
  String? _shopType;
  late bool _warehouseEnabled;
  late bool _expiryEnabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final store = context.read<ShopStore>();
    _language = store.languageCode;
    _shopNameController = TextEditingController(text: store.shop?.name ?? '');
    _shopType = store.shop?.type;
    _thresholdController = TextEditingController(
      text: '${store.lowStockThreshold}',
    );
    _warehouseEnabled = store.warehouseInventoryEnabled;
    _expiryEnabled = store.expiryFeatureEnabled;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final store = context.read<ShopStore>();
    await store.setLanguage(_language);
    await store.setWarehouseInventoryEnabled(_warehouseEnabled);
    await store.setExpiryFeatureEnabled(_expiryEnabled);
    final error = await store.saveShop(
      name: _shopNameController.text,
      type: _shopType ?? store.shop?.type ?? ShopStore.shopTypes.first,
      lowStockThreshold: int.tryParse(_thresholdController.text.trim()) ?? 5,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppMessage(context, error);
      return;
    }

    showAppMessage(context, AppText(store.languageCode).settingsSaved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppText(_language);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: OfflineBadge(label: t.offline)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              t.settingsHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(
              t.languageTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _LangOption(
                    label: 'বাংলা',
                    selected: _language == 'bn',
                    onTap: () => setState(() => _language = 'bn'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _LangOption(
                    label: 'English',
                    selected: _language == 'en',
                    onTap: () => setState(() => _language = 'en'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                labelText: t.shopName,
                prefixIcon: const Icon(Icons.store_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.shopType,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ShopStore.shopTypes.map((type) {
                final selected = _shopType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (_) => setState(() => _shopType = type),
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
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.lowStock,
                helperText: t.lowStockHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.featureOptions,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.warehouseInventory),
              subtitle: Text(t.warehouseInventoryHint),
              value: _warehouseEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _warehouseEnabled = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.expiryTracking),
              subtitle: Text(t.expiryTrackingHint),
              value: _expiryEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _expiryEnabled = v),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _saving ? '...' : t.save,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
