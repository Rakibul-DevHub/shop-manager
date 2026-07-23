import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/local_shop_repository.dart';

/// Presentation state — talks to [ShopRepository] only (not SQLite directly).
class ShopStore extends ChangeNotifier {
  ShopStore({ShopRepository? repository})
      : _repo = repository ?? LocalShopRepository();

  final ShopRepository _repo;

  bool ready = false;
  bool onboardingDone = false;
  bool languageSelected = false;
  String languageCode = 'bn';
  AppUser? currentUser;
  ShopProfile? shop;

  List<Product> products = [];
  List<Customer> dueCustomers = [];
  List<Expense> expenses = [];
  List<SaleRecord> todaySales = [];
  List<SaleRecord> reportSales = [];
  DateTime reportDay = DateTime.now();
  List<DateTime> saleDays = [];

  static const shopTypes = AppConstants.shopTypes;
  static const expenseTypes = AppConstants.expenseTypes;

  bool get hasShop => shop != null;
  int get lowStockThreshold => shop?.lowStockThreshold ?? 5;

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= lowStockThreshold).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

  double get todaySalesTotal => todaySales.fold(0, (sum, s) => sum + s.total);
  double get todayProfit => todaySales.fold(0, (sum, s) => sum + s.profit);
  int get todayPieces => todaySales.fold(0, (sum, s) => sum + s.qty);
  double get totalDue => dueCustomers.fold(0, (sum, c) => sum + c.dueAmount);
  double get reportSalesTotal =>
      reportSales.fold(0, (sum, s) => sum + s.total);
  double get reportProfit => reportSales.fold(0, (sum, s) => sum + s.profit);
  int get reportPieces => reportSales.fold(0, (sum, s) => sum + s.qty);

  Future<void> init() async {
    try {
      onboardingDone = await _repo.getBoolSetting('onboarding_done');
      languageSelected = await _repo.getBoolSetting('language_selected');
      languageCode = await _repo.getSetting('language_code') ?? 'bn';

      final login = await _repo.getSetting('user_login');
      if (login != null && login.isNotEmpty) {
        currentUser = await _repo.findUserByLogin(login);
      }

      shop = await _repo.getShop();
      await _repo.seedDemoCatalog();
      await refreshAll();
    } catch (e, st) {
      debugPrint('ShopStore.init failed: $e\n$st');
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    products = await _repo.getProducts();
    dueCustomers = await _repo.getDueCustomers();
    expenses = await _repo.getExpenses();
    todaySales = await _repo.getSalesForDay(DateTime.now());
    saleDays = await _repo.getSaleDays();
    reportSales = await _repo.getSalesForDay(reportDay);
    shop = await _repo.getShop();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _repo.setBoolSetting('onboarding_done', true);
    onboardingDone = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    await _repo.setSetting('language_code', code);
    await _repo.setBoolSetting('language_selected', true);
    languageCode = code;
    languageSelected = true;
    notifyListeners();
  }

  Future<String?> saveShop({
    required String name,
    required String type,
    int? lowStockThreshold,
  }) async {
    if (name.trim().isEmpty || type.trim().isEmpty) {
      return languageCode == 'bn'
          ? 'দোকানের নাম ও ধরন দিন'
          : 'Enter shop name and type';
    }
    final profile = ShopProfile(
      id: shop?.id,
      name: name.trim(),
      type: type.trim(),
      lowStockThreshold: lowStockThreshold ?? shop?.lowStockThreshold ?? 5,
    );
    await _repo.upsertShop(profile);
    shop = await _repo.getShop();
    notifyListeners();
    return null;
  }

  Future<String?> addProduct(Product product) async {
    if (product.name.trim().isEmpty || product.code.trim().isEmpty) {
      return languageCode == 'bn' ? 'নাম ও কোড দিতে হবে' : 'Name and code required';
    }
    final exists = await _repo.getProductByCode(product.code);
    if (exists != null) {
      return languageCode == 'bn' ? 'এই কোড আগেই আছে' : 'Code already exists';
    }
    await _repo.insertProduct(product);
    await refreshAll();
    return null;
  }

  Product? findProductByCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final product in products) {
      if (product.code.toUpperCase() == normalized) return product;
    }
    return null;
  }

  Future<String?> completeSale({
    required Product product,
    required int qty,
    required double unitPrice,
    required String paymentType,
    String? customerName,
    String? customerPhone,
  }) async {
    if (qty <= 0) {
      return languageCode == 'bn' ? 'পরিমাণ ঠিক নয়' : 'Invalid quantity';
    }
    if (qty > product.stock) {
      return languageCode == 'bn'
          ? 'স্টকে যথেষ্ট পণ্য নেই'
          : 'Not enough stock';
    }
    if (unitPrice < product.costPrice) {
      return languageCode == 'bn'
          ? 'ক্রয় দামের নিচে দাম দেওয়া যাবে না'
          : 'Price cannot be below cost';
    }

    Customer? customer;
    if (paymentType == 'due') {
      final name = customerName?.trim() ?? '';
      final phone = customerPhone?.trim() ?? '';
      if (name.isEmpty || phone.isEmpty) {
        return languageCode == 'bn'
            ? 'বাকি বিক্রির জন্য নাম ও ফোন দিন'
            : 'Name and phone required for due sale';
      }
      customer = await _repo.getCustomerByPhone(phone);
      if (customer == null) {
        final id = await _repo.insertCustomer(
          Customer(name: name, phone: phone, dueAmount: 0),
        );
        customer = Customer(id: id, name: name, phone: phone, dueAmount: 0);
      }
    }

    final total = unitPrice * qty;
    final profit = (unitPrice - product.costPrice) * qty;
    final sale = SaleRecord(
      productId: product.id!,
      productCode: product.code,
      productName: product.name,
      qty: qty,
      unitPrice: unitPrice,
      costPrice: product.costPrice,
      total: total,
      profit: profit,
      soldAt: DateTime.now(),
      paymentType: paymentType,
      customerId: customer?.id,
      customerName: customer?.name,
    );

    await _repo.insertSale(sale);
    await _repo.updateProduct(product.copyWith(stock: product.stock - qty));

    if (paymentType == 'due' && customer != null) {
      await _repo.updateCustomer(
        customer.copyWith(dueAmount: customer.dueAmount + total),
      );
    }

    await refreshAll();
    return null;
  }

  Future<String?> collectPayment({
    required Customer customer,
    required double amount,
  }) async {
    if (amount <= 0) {
      return languageCode == 'bn'
          ? 'সঠিক টাকার পরিমাণ দিন'
          : 'Enter a valid amount';
    }
    if (amount > customer.dueAmount) {
      return languageCode == 'bn'
          ? 'বাকির চেয়ে বেশি আদায় করা যাবে না'
          : 'Cannot collect more than due';
    }
    final remaining = customer.dueAmount - amount;
    await _repo.updateCustomer(customer.copyWith(dueAmount: remaining));
    await _repo.insertPayment(customerId: customer.id!, amount: amount);
    await refreshAll();
    return null;
  }

  Future<String?> addExpense({
    required String type,
    required double amount,
    String note = '',
  }) async {
    if (type.trim().isEmpty || amount <= 0) {
      return languageCode == 'bn'
          ? 'খরচের ধরন ও পরিমাণ দিন'
          : 'Enter expense type and amount';
    }
    await _repo.insertExpense(
      Expense(
        type: type,
        amount: amount,
        note: note.trim(),
        createdAt: DateTime.now(),
      ),
    );
    await refreshAll();
    return null;
  }

  Future<void> setReportDay(DateTime day) async {
    reportDay = DateTime(day.year, day.month, day.day);
    reportSales = await _repo.getSalesForDay(reportDay);
    notifyListeners();
  }

  List<Product> searchProducts(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) {
      return p.code.toLowerCase().contains(q) ||
          p.name.toLowerCase().contains(q) ||
          p.variant.toLowerCase().contains(q);
    }).toList();
  }
}
