import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_text.dart';
import '../state/shop_store.dart';
import '../../core/theme/app_colors.dart';
import 'due_customers_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'products_screen.dart';
import 'quick_sell_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppText(context.watch<ShopStore>().languageCode);
    const pages = [
      HomeScreen(),
      QuickSellScreen(),
      ProductsScreen(),
      DueCustomersScreen(),
      MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: t.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.currency_exchange),
              activeIcon: const Icon(Icons.currency_exchange),
              label: t.sell,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: t.products,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_box_outline_blank),
              activeIcon: const Icon(Icons.check_box_outlined),
              label: t.dues,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz),
              activeIcon: const Icon(Icons.more_horiz),
              label: t.more,
            ),
          ],
        ),
      ),
    );
  }
}
