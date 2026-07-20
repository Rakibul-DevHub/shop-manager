import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop_manager/l10n/app_text.dart';
import 'package:shop_manager/screens/onboarding_screen.dart';
import 'package:shop_manager/state/shop_store.dart';
import 'package:shop_manager/theme/app_theme.dart';

void main() {
  testWidgets('Onboarding screen renders primary CTA', (tester) async {
    final store = ShopStore();
    store.ready = true;
    store.languageCode = 'bn';

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const OnboardingScreen(),
        ),
      ),
    );

    expect(find.text(AppText('bn').next), findsOneWidget);
    expect(find.text(AppText('bn').skip), findsOneWidget);
  });
}
