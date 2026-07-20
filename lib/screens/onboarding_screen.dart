import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_text.dart';
import '../state/shop_store.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await context.read<ShopStore>().completeOnboarding();
    // AppGate switches to LanguageScreen automatically.
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();
    final t = AppText(store.languageCode);
    final pages = [
      (
        Icons.insights_rounded,
        store.languageCode == 'bn' ? 'মনিটর' : 'Monitor',
        store.languageCode == 'bn'
            ? 'সবকিছু যেকোনো জায়গা থেকে দেখুন'
            : 'Monitor Everything Anywhere',
        store.languageCode == 'bn'
            ? 'বিক্রি, স্টক ও বাকি — সব এক জায়গায়।'
            : 'Track sales, stock and dues in one place.',
      ),
      (
        Icons.point_of_sale_rounded,
        t.quickSell,
        store.languageCode == 'bn'
            ? 'কোড দিয়ে বিক্রি শেষ করুন'
            : 'Finish sales with product codes',
        store.languageCode == 'bn'
            ? 'পণ্য খুঁজুন, পরিমাণ বাড়ান, তাড়াতাড়ি বিক্রি সম্পন্ন করুন।'
            : 'Find products, adjust qty, and complete sales fast.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: _finish, child: Text(t.skip)),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(page.$1, size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.$2,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          page.$3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.$4,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: t.next,
                onPressed: _finishing
                    ? null
                    : () {
                        if (_index < pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                          return;
                        }
                        _finish();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
