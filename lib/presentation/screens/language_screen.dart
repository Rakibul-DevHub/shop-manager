import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/tap_mark.dart';

/// PDF Language Selection
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = context.read<ShopStore>().languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Language Selection',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'ভাষা নির্বাচন করুন',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your app language',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 32),
              const TapHint(
                number: 1,
                text: 'Tap বাংলা or English to select',
              ),
              _LanguageCard(
                title: 'বাংলা',
                selected: _selected == 'bn',
                onTap: () => setState(() => _selected = 'bn'),
              ),
              const SizedBox(height: 12),
              _LanguageCard(
                title: 'English',
                selected: _selected == 'en',
                onTap: () => setState(() => _selected = 'en'),
              ),
              const Spacer(),
              const TapHint(
                number: 2,
                text: 'Then tap Next to continue',
              ),
              PrimaryButton(
                label: _saving ? '...' : 'Next',
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await context.read<ShopStore>().setLanguage(_selected);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
