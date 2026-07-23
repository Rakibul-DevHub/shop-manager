import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/local_shop_repository.dart';
import '../presentation/screens/app_gate.dart';
import '../presentation/state/shop_store.dart';

class ShopManagerApp extends StatelessWidget {
  const ShopManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopStore(repository: LocalShopRepository())..init(),
      child: MaterialApp(
        title: 'Shop Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppGate(),
      ),
    );
  }
}
