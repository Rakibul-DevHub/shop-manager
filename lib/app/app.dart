import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../data/repositories/local_shop_repository.dart';
import '../presentation/screens/app_gate.dart';
import '../presentation/state/shop_store.dart';

class ShopManagerApp extends StatefulWidget {
  const ShopManagerApp({super.key});

  @override
  State<ShopManagerApp> createState() => _ShopManagerAppState();
}

class _ShopManagerAppState extends State<ShopManagerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableFullScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableFullScreen();
    }
  }

  void _enableFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

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
