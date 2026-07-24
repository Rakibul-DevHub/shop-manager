import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/analytics/report_insights.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../data/repositories/local_shop_repository.dart';

enum ReportPreset { today, thisWeek, thisMonth, previousMonth, custom }

/// Presentation state — talks to [ShopRepository] only (not SQLite directly).
class ShopStore extends ChangeNotifier {
  ShopStore({ShopRepository? repository})
      : _repo = repository ?? LocalShopRepository();

  final ShopRepository _repo;

  bool ready = false;
  bool onboardingDone = false;
  bool languageSelected = false;

  /// Default English; Bangla only after the user selects it.
  String languageCode = 'en';
  AppUser? currentUser;
  ShopProfile? shop;
  OwnerProfile ownerProfile = const OwnerProfile();

  List<Product> products = [];
  List<Customer> dueCustomers = [];
  List<Expense> expenses = [];
  List<StaffMember> staff = [];
  List<SaleRecord> todaySales = [];
  List<SaleRecord> reportSales = [];
  List<SaleRecord> historySales = [];
  /// Sales used only for the trend chart (always a multi-day window).
  List<SaleRecord> trendSales = [];
  List<DateTime> saleDays = [];

  DateTime reportStart = DateTime.now();
  DateTime reportEnd = DateTime.now();
  ReportPreset reportPreset = ReportPreset.today;

  DateTime historyStart = DateTime.now();
  DateTime historyEnd = DateTime.now();
  ReportPreset historyPreset = ReportPreset.today;

  DateTime trendStart = DateTime.now();
  DateTime trendEnd = DateTime.now();

  /// Kept for older call sites; maps to a single-day range.
  DateTime get reportDay => reportStart;

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

  ReportInsights get reportInsights => ReportInsights.fromSales(
        reportSales,
        rangeStart: reportStart,
        rangeEnd: reportEnd,
      );

  /// Day-by-day sales/profit for the trend graph (filled calendar days).
  List<DailyTrendPoint> get salesTrendPoints => ReportInsights.fromSales(
        trendSales,
        rangeStart: trendStart,
        rangeEnd: trendEnd,
      ).dailyTrend;

  double get historySalesTotal =>
      historySales.fold(0, (sum, s) => sum + s.total);
  double get historyProfit => historySales.fold(0, (sum, s) => sum + s.profit);
  int get historyPieces => historySales.fold(0, (sum, s) => sum + s.qty);

  double get reportExpenseTotal {
    return expenses
        .where((e) {
          final d = DateTime(
            e.createdAt.year,
            e.createdAt.month,
            e.createdAt.day,
          );
          return !d.isBefore(reportStart) && !d.isAfter(reportEnd);
        })
        .fold(0, (sum, e) => sum + e.amount);
  }

  int get totalStockQty => products.fold(0, (sum, p) => sum + p.stock);
  double get stockCostValue =>
      products.fold(0, (sum, p) => sum + (p.costPrice * p.stock));
  double get todayExpenseTotal {
    final now = DateTime.now();
    return expenses
        .where(
          (e) =>
              e.createdAt.year == now.year &&
              e.createdAt.month == now.month &&
              e.createdAt.day == now.day,
        )
        .fold(0, (sum, e) => sum + e.amount);
  }

  Future<void> init() async {
    try {
      onboardingDone = await _repo.getBoolSetting('onboarding_done');
      languageSelected = await _repo.getBoolSetting('language_selected');
      languageCode = await _repo.getSetting('language_code') ?? 'en';

      final login = await _repo.getSetting('user_login');
      if (login != null && login.isNotEmpty) {
        currentUser = await _repo.findUserByLogin(login);
      }

      await _loadOwnerProfile();
      shop = await _repo.getShop();
      await _repo.seedDemoCatalog();
      _applyPreset(ReportPreset.today);
      await refreshAll();
    } catch (e, st) {
      debugPrint('ShopStore.init failed: $e\n$st');
    } finally {
      ready = true;
      notifyListeners();
    }
  }

  Future<void> _loadOwnerProfile() async {
    ownerProfile = OwnerProfile(
      name: await _repo.getSetting('profile_name') ?? '',
      phone: await _repo.getSetting('profile_phone') ?? '',
      email: await _repo.getSetting('profile_email') ?? '',
    );
  }

  Future<void> refreshAll() async {
    products = await _repo.getProducts();
    dueCustomers = await _repo.getDueCustomers();
    expenses = await _repo.getExpenses();
    staff = await _repo.getStaff();
    todaySales = await _repo.getSalesForDay(DateTime.now());
    saleDays = await _repo.getSaleDays();
    reportSales = await _repo.getSalesInRange(reportStart, reportEnd);
    historySales = await _repo.getSalesInRange(historyStart, historyEnd);
    await _reloadTrendSales();
    shop = await _repo.getShop();
    await _loadOwnerProfile();
    notifyListeners();
  }

  /// Trend needs multiple days. If the report range is short, use last 7 days.
  void _updateTrendWindow() {
    final end = _dateOnly(reportEnd);
    final selectedDays = _dateOnly(reportEnd)
            .difference(_dateOnly(reportStart))
            .inDays +
        1;
    if (selectedDays >= 7) {
      trendStart = _dateOnly(reportStart);
      trendEnd = end;
    } else {
      trendStart = end.subtract(const Duration(days: 6));
      trendEnd = end;
    }
  }

  Future<void> _reloadTrendSales() async {
    _updateTrendWindow();
    trendSales = await _repo.getSalesInRange(trendStart, trendEnd);
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

  Future<String?> saveOwnerProfile(OwnerProfile profile) async {
    if (profile.name.trim().isEmpty) {
      return languageCode == 'bn' ? 'নাম দিন' : 'Enter your name';
    }
    await _repo.setSetting('profile_name', profile.name.trim());
    await _repo.setSetting('profile_phone', profile.phone.trim());
    await _repo.setSetting('profile_email', profile.email.trim());
    ownerProfile = OwnerProfile(
      name: profile.name.trim(),
      phone: profile.phone.trim(),
      email: profile.email.trim(),
    );
    notifyListeners();
    return null;
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

  Future<String?> saveStaff(StaffMember member) async {
    if (member.name.trim().isEmpty || member.phone.trim().isEmpty) {
      return languageCode == 'bn'
          ? 'নাম ও ফোন দিন'
          : 'Enter name and phone';
    }
    if (member.id == null) {
      await _repo.insertStaff(
        member.copyWith(
          name: member.name.trim(),
          phone: member.phone.trim(),
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await _repo.updateStaff(
        member.copyWith(
          name: member.name.trim(),
          phone: member.phone.trim(),
        ),
      );
    }
    staff = await _repo.getStaff();
    notifyListeners();
    return null;
  }

  Future<void> deleteStaff(int id) async {
    await _repo.deleteStaff(id);
    staff = await _repo.getStaff();
    notifyListeners();
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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  (DateTime start, DateTime end) _rangeForPreset(ReportPreset preset) {
    final today = _dateOnly(DateTime.now());
    switch (preset) {
      case ReportPreset.today:
        return (today, today);
      case ReportPreset.thisWeek:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return (start, today);
      case ReportPreset.thisMonth:
        return (DateTime(today.year, today.month, 1), today);
      case ReportPreset.previousMonth:
        final firstThis = DateTime(today.year, today.month, 1);
        final end = firstThis.subtract(const Duration(days: 1));
        return (DateTime(end.year, end.month, 1), end);
      case ReportPreset.custom:
        return (reportStart, reportEnd);
    }
  }

  void _applyPreset(ReportPreset preset) {
    reportPreset = preset;
    if (preset == ReportPreset.custom) return;
    final range = _rangeForPreset(preset);
    reportStart = range.$1;
    reportEnd = range.$2;
  }

  Future<void> setReportPreset(ReportPreset preset) async {
    _applyPreset(preset);
    reportSales = await _repo.getSalesInRange(reportStart, reportEnd);
    await _reloadTrendSales();
    notifyListeners();
  }

  Future<void> setReportRange(DateTime start, DateTime end) async {
    reportPreset = ReportPreset.custom;
    reportStart = _dateOnly(start);
    reportEnd = _dateOnly(end);
    if (reportEnd.isBefore(reportStart)) {
      final tmp = reportStart;
      reportStart = reportEnd;
      reportEnd = tmp;
    }
    reportSales = await _repo.getSalesInRange(reportStart, reportEnd);
    await _reloadTrendSales();
    notifyListeners();
  }

  Future<void> setReportDay(DateTime day) async {
    await setReportRange(day, day);
  }

  Future<void> setHistoryPreset(ReportPreset preset) async {
    historyPreset = preset;
    if (preset != ReportPreset.custom) {
      final range = _rangeForPreset(preset);
      historyStart = range.$1;
      historyEnd = range.$2;
    }
    historySales = await _repo.getSalesInRange(historyStart, historyEnd);
    notifyListeners();
  }

  Future<void> setHistoryRange(DateTime start, DateTime end) async {
    historyPreset = ReportPreset.custom;
    historyStart = _dateOnly(start);
    historyEnd = _dateOnly(end);
    if (historyEnd.isBefore(historyStart)) {
      final tmp = historyStart;
      historyStart = historyEnd;
      historyEnd = tmp;
    }
    historySales = await _repo.getSalesInRange(historyStart, historyEnd);
    notifyListeners();
  }

  Future<void> setHistoryDay(DateTime day) async {
    await setHistoryRange(day, day);
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
