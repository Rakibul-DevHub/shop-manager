import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_text.dart';
import '../state/shop_store.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

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
    final t = AppText(_selected);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                t.languageTitle,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                t.chooseLanguage,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              _LanguageCard(
                title: 'বাংলা',
                subtitle: 'Primary',
                selected: _selected == 'bn',
                onTap: () => setState(() => _selected = 'bn'),
              ),
              const SizedBox(height: 12),
              _LanguageCard(
                title: 'English',
                subtitle: 'Optional',
                selected: _selected == 'en',
                onTap: () => setState(() => _selected = 'en'),
              ),
              const Spacer(),
              PrimaryButton(
                label: _saving ? '...' : t.continueLabel,
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await context.read<ShopStore>().setLanguage(_selected);
                        // AppGate switches to ShopSetup / Home automatically.
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
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(18),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
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
