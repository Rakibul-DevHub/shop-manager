import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../state/shop_store.dart';
import 'language_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';
import 'shop_setup_screen.dart';
import 'splash_screen.dart';

/// Routes: Splash → Onboarding → Language → Shop Setup → Home
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppConstants.splashDuration, () {
      if (!mounted) return;
      setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();

    if (!_splashDone || !store.ready) {
      return const SplashScreen();
    }
    if (!store.onboardingDone) {
      return const OnboardingScreen();
    }
    if (!store.languageSelected) {
      return const LanguageScreen();
    }
    if (!store.hasShop) {
      return const ShopSetupScreen();
    }
    return const MainShell();
  }
}
