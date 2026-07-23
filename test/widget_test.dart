import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop_manager/core/theme/app_theme.dart';
import 'package:shop_manager/presentation/screens/onboarding_screen.dart';
import 'package:shop_manager/presentation/state/shop_store.dart';

void main() {
  testWidgets('Onboarding shows PDF Monitor screen and Next', (tester) async {
    final store = ShopStore();
    store.ready = true;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const OnboardingScreen(),
        ),
      ),
    );

    expect(find.text('Monitor'), findsOneWidget);
    expect(find.text('Monitor Everything Anywhere'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
