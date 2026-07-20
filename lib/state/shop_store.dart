import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../models/customer.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/user.dart';

class ShopStore extends ChangeNotifier {
  ShopStore({AppDatabase? database}) : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

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

  static const demoOtp = '1234';
  static const shopTypes = [
    'মুদি দোকান',
    'কাপড়',
    'মোবাইল এক্সেসরিজ',
    'কসমেটিকস',
    'ফাস্টফুড',
  ];
  static const expenseTypes = [
    'দোকান ভাড়া',
    'বেতন',
    'বিদ্যুৎ',
    'পরিবহন',
  ];

  bool get isLoggedIn => currentUser != null;
  bool get hasShop => shop != null;

  int get lowStockThreshold => shop?.lowStockThreshold ?? 5;

  List<Product> get lowStockProducts =>
      products.where((p) => p.stock <= lowStockThreshold).toList()
        ..sort((a, b) => a.stock.compareTo(b.stock));

  double get todaySalesTotal =>
      todaySales.fold(0, (sum, s) => sum + s.total);

  double get todayProfit =>
      todaySales.fold(0, (sum, s) => sum + s.profit);

  int get todayPieces =>
      todaySales.fold(0, (sum, s) => sum + s.qty);

  double get totalDue =>
      dueCustomers.fold(0, (sum, c) => sum + c.dueAmount);

  double get reportSalesTotal =>
      reportSales.fold(0, (sum, s) => sum + s.total);

  double get reportProfit =>
      reportSales.fold(0, (sum, s) => sum + s.profit);

  int get reportPieces =>
      reportSales.fold(0, (sum, s) => sum + s.qty);

  Future<void> init() async {
    try {
      onboardingDone = await _db.getBoolSetting('onboarding_done');
      languageSelected = await _db.getBoolSetting('language_selected');
      languageCode = await _db.getSetting('language_code') ?? 'bn';

      final login = await _db.getSetting('user_login');
      if (login != null && login.isNotEmpty) {
        currentUser = await _db.findUserByLogin(login);
      }

      shop = await _db.getShop();
      await _db.seedDemoCatalog();
      await refreshAll();
    } catch (e, st) {
      debugPrint('ShopStore.init failed: $e\n$st');
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    products = await _db.getProducts();
    dueCustomers = await _db.getDueCustomers();
    expenses = await _db.getExpenses();
    todaySales = await _db.getSalesForDay(DateTime.now());
    saleDays = await _db.getSaleDays();
    reportSales = await _db.getSalesForDay(reportDay);
    shop = await _db.getShop();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _db.setBoolSetting('onboarding_done', true);
    onboardingDone = true;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    await _db.setSetting('language_code', code);
    await _db.setBoolSetting('language_selected', true);
    languageCode = code;
    languageSelected = true;
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String otp,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.isEmpty) {
      return languageCode == 'bn'
          ? 'সব ঘর পূরণ করুন'
          : 'Please fill all fields';
    }
    if (password != confirmPassword) {
      return languageCode == 'bn'
          ? 'পাসওয়ার্ড মিলছে না'
          : 'Passwords do not match';
    }
    if (otp.trim() != demoOtp) {
      return languageCode == 'bn'
          ? 'OTP ভুল (ডেমো OTP: $demoOtp)'
          : 'Invalid OTP (demo OTP: $demoOtp)';
    }
    if (await _db.emailOrPhoneExists(email, phone)) {
      return languageCode == 'bn'
          ? 'ইমেইল/ফোন আগে থেকেই আছে'
          : 'Email/phone already registered';
    }

    final user = AppUser(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password,
    );
    final id = await _db.insertUser(user);
    currentUser = user.copyWithId(id);
    await _persistSession(currentUser!);
    notifyListeners();
    return null;
  }

  Future<String?> signIn({
    required String login,
    required String password,
    String? otp,
  }) async {
    if (login.trim().isEmpty || password.isEmpty) {
      return languageCode == 'bn'
          ? 'ইমেইল/ফোন ও পাসওয়ার্ড দিন'
          : 'Enter email/phone and password';
    }
    if (otp == null || otp.trim() != demoOtp) {
      return languageCode == 'bn'
          ? 'OTP ভুল (ডেমো OTP: $demoOtp)'
          : 'Invalid OTP (demo OTP: $demoOtp)';
    }

    final user = await _db.findUserByLogin(login);
    if (user == null || user.password != password) {
      return languageCode == 'bn'
          ? 'লগইন তথ্য ভুল'
          : 'Invalid login details';
    }
    currentUser = user;
    await _persistSession(user);
    notifyListeners();
    return null;
  }

  Future<void> _persistSession(AppUser user) async {
    await _db.setSetting('user_id', '${user.id}');
    await _db.setSetting('user_login', user.email);
  }

  Future<void> signOut() async {
    await _db.removeSetting('user_id');
    await _db.removeSetting('user_login');
    currentUser = null;
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
    await _db.upsertShop(profile);
    shop = await _db.getShop();
    notifyListeners();
    return null;
  }

  Future<String?> addProduct(Product product) async {
    if (product.name.trim().isEmpty || product.code.trim().isEmpty) {
      return languageCode == 'bn' ? 'নাম ও কোড দিতে হবে' : 'Name and code required';
    }
    final exists = await _db.getProductByCode(product.code);
    if (exists != null) {
      return languageCode == 'bn' ? 'এই কোড আগেই আছে' : 'Code already exists';
    }
    await _db.insertProduct(product);
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
      customer = await _db.getCustomerByPhone(phone);
      if (customer == null) {
        final id = await _db.insertCustomer(
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

    await _db.insertSale(sale);
    await _db.updateProduct(product.copyWith(stock: product.stock - qty));

    if (paymentType == 'due' && customer != null) {
      await _db.updateCustomer(
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
    await _db.updateCustomer(customer.copyWith(dueAmount: remaining));
    await _db.insertPayment(customerId: customer.id!, amount: amount);
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
    await _db.insertExpense(
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
    reportSales = await _db.getSalesForDay(reportDay);
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

extension on AppUser {
  AppUser copyWithId(int id) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
