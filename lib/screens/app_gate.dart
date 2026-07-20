import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_text.dart';
import '../state/shop_store.dart';
import '../theme/app_colors.dart';
import 'language_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';
import 'shop_setup_screen.dart';

/// Frontend flow (no login): Splash → Onboarding → Language → Shop Setup → Home
class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ShopStore>();

    if (!store.ready) {
      return const _BootSplash();
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

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.splashTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
