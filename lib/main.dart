import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/app_gate.dart';
import 'state/shop_store.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initDesktopSqlite();
  runApp(const ShopManagerApp());
}

void _initDesktopSqlite() {
  if (kIsWeb) return;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class ShopManagerApp extends StatelessWidget {
  const ShopManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopStore()..init(),
      child: MaterialApp(
        title: 'Shop Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppGate(),
      ),
    );
  }
}
