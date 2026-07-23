import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/user.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'shop_manager.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createV1(db);
        await _createSettings(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createSettings(db);
        }
      },
    );
  }

  Future<void> _createSettings(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createV1(Database db) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE shop (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            low_stock_threshold INTEGER NOT NULL DEFAULT 5
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            variant TEXT NOT NULL,
            cost_price REAL NOT NULL,
            sell_price REAL NOT NULL,
            stock INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL UNIQUE,
            due_amount REAL NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            product_code TEXT NOT NULL,
            product_name TEXT NOT NULL,
            qty INTEGER NOT NULL,
            unit_price REAL NOT NULL,
            cost_price REAL NOT NULL,
            total REAL NOT NULL,
            profit REAL NOT NULL,
            sold_at TEXT NOT NULL,
            payment_type TEXT NOT NULL,
            customer_id INTEGER,
            customer_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
  }

  // ---- Settings (replaces shared_preferences) ----
  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  Future<bool> getBoolSetting(String key, {bool fallback = false}) async {
    final value = await getSetting(key);
    if (value == null) return fallback;
    return value == '1' || value.toLowerCase() == 'true';
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await setSetting(key, value ? '1' : '0');
  }

  // ---- Users ----
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap()..remove('id'));
  }

  Future<AppUser?> findUserByLogin(String login) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? OR phone = ?',
      whereArgs: [login.trim(), login.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<bool> emailOrPhoneExists(String email, String phone) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? OR phone = ?',
      whereArgs: [email.trim(), phone.trim()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  // ---- Shop ----
  Future<ShopProfile?> getShop() async {
    final db = await database;
    final rows = await db.query('shop', limit: 1);
    if (rows.isEmpty) return null;
    return ShopProfile.fromMap(rows.first);
  }

  Future<void> upsertShop(ShopProfile shop) async {
    final db = await database;
    final existing = await getShop();
    if (existing == null) {
      await db.insert('shop', shop.toMap()..remove('id'));
    } else {
      await db.update(
        'shop',
        shop.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }

  // ---- Products ----
  Future<List<Product>> getProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getProductByCode(String code) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'UPPER(code) = ?',
      whereArgs: [code.trim().toUpperCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap()..remove('id'));
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<List<Product>> getLowStock(int threshold) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );
    return rows.map(Product.fromMap).toList();
  }

  // ---- Customers ----
  Future<List<Customer>> getDueCustomers() async {
    final db = await database;
    final rows = await db.query(
      'customers',
      where: 'due_amount > 0',
      orderBy: 'due_amount DESC',
    );
    return rows.map(Customer.fromMap).toList();
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await database;
    final rows = await db.query(
      'customers',
      where: 'phone = ?',
      whereArgs: [phone.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Customer.fromMap(rows.first);
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return db.insert('customers', customer.toMap()..remove('id'));
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // ---- Sales ----
  Future<int> insertSale(SaleRecord sale) async {
    final db = await database;
    return db.insert('sales', sale.toMap()..remove('id'));
  }

  Future<List<SaleRecord>> getSalesForDay(DateTime day) async {
    final db = await database;
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      'sales',
      where: 'sold_at >= ? AND sold_at < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'sold_at DESC',
    );
    return rows.map(SaleRecord.fromMap).toList();
  }

  Future<List<DateTime>> getSaleDays({int limit = 14}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT substr(sold_at, 1, 10) AS day
      FROM sales
      ORDER BY day DESC
      LIMIT ?
    ''', [limit]);
    return rows
        .map((r) => DateTime.parse(r['day']! as String))
        .toList();
  }

  // ---- Expenses ----
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return db.insert('expenses', expense.toMap()..remove('id'));
  }

  Future<List<Expense>> getExpenses() async {
    final db = await database;
    final rows = await db.query('expenses', orderBy: 'created_at DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<void> insertPayment({
    required int customerId,
    required double amount,
  }) async {
    final db = await database;
    await db.insert('payments', {
      'customer_id': customerId,
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> hasAnyProducts() async {
    final db = await database;
    final rows = await db.query('products', limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> seedDemoCatalog() async {
    final existing = await hasAnyProducts();
    if (existing) return;

    final demo = [
      const Product(
        code: 'TS001-L',
        name: 'টি-শার্ট',
        variant: 'L',
        costPrice: 320,
        sellPrice: 450,
        stock: 12,
      ),
      const Product(
        code: 'CH05',
        name: 'চার্জার',
        variant: 'Type-C',
        costPrice: 230,
        sellPrice: 320,
        stock: 3,
      ),
      const Product(
        code: 'RC010',
        name: 'চাল',
        variant: '5kg',
        costPrice: 340,
        sellPrice: 390,
        stock: 8,
      ),
    ];
    for (final product in demo) {
      await insertProduct(product);
    }

    await insertCustomer(
      const Customer(name: 'রহিম', phone: '01712-000000', dueAmount: 1250),
    );
    await insertCustomer(
      const Customer(name: 'করিম', phone: '01822-000000', dueAmount: 680),
    );
    await insertCustomer(
      const Customer(name: 'সুমন', phone: '01933-000000', dueAmount: 420),
    );
  }
}
