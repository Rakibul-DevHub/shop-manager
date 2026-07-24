import '../../domain/entities/customer.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/shop_repository.dart';
import '../local/app_database.dart';

/// SQLite-backed implementation of [ShopRepository].
class LocalShopRepository implements ShopRepository {
  LocalShopRepository({AppDatabase? database})
      : _db = database ?? AppDatabase.instance;

  final AppDatabase _db;

  @override
  Future<String?> getSetting(String key) => _db.getSetting(key);

  @override
  Future<void> setSetting(String key, String value) =>
      _db.setSetting(key, value);

  @override
  Future<void> removeSetting(String key) => _db.removeSetting(key);

  @override
  Future<bool> getBoolSetting(String key, {bool fallback = false}) =>
      _db.getBoolSetting(key, fallback: fallback);

  @override
  Future<void> setBoolSetting(String key, bool value) =>
      _db.setBoolSetting(key, value);

  @override
  Future<ShopProfile?> getShop() => _db.getShop();

  @override
  Future<void> upsertShop(ShopProfile shop) => _db.upsertShop(shop);

  @override
  Future<int> insertUser(AppUser user) => _db.insertUser(user);

  @override
  Future<AppUser?> findUserByLogin(String login) => _db.findUserByLogin(login);

  @override
  Future<bool> emailOrPhoneExists(String email, String phone) =>
      _db.emailOrPhoneExists(email, phone);

  @override
  Future<List<Product>> getProducts() => _db.getProducts();

  @override
  Future<Product?> getProductByCode(String code) => _db.getProductByCode(code);

  @override
  Future<int> insertProduct(Product product) => _db.insertProduct(product);

  @override
  Future<void> updateProduct(Product product) => _db.updateProduct(product);

  @override
  Future<List<Product>> getLowStock(int threshold) =>
      _db.getLowStock(threshold);

  @override
  Future<void> seedDemoCatalog() => _db.seedDemoCatalog();

  @override
  Future<List<Customer>> getDueCustomers() => _db.getDueCustomers();

  @override
  Future<Customer?> getCustomerByPhone(String phone) =>
      _db.getCustomerByPhone(phone);

  @override
  Future<int> insertCustomer(Customer customer) => _db.insertCustomer(customer);

  @override
  Future<void> updateCustomer(Customer customer) =>
      _db.updateCustomer(customer);

  @override
  Future<void> insertPayment({
    required int customerId,
    required double amount,
  }) =>
      _db.insertPayment(customerId: customerId, amount: amount);

  @override
  Future<int> insertSale(SaleRecord sale) => _db.insertSale(sale);

  @override
  Future<List<SaleRecord>> getSalesForDay(DateTime day) =>
      _db.getSalesForDay(day);

  @override
  Future<List<SaleRecord>> getSalesInRange(DateTime start, DateTime end) =>
      _db.getSalesInRange(start, end);

  @override
  Future<List<DateTime>> getSaleDays({int limit = 14}) =>
      _db.getSaleDays(limit: limit);

  @override
  Future<List<StaffMember>> getStaff() => _db.getStaff();

  @override
  Future<int> insertStaff(StaffMember staff) => _db.insertStaff(staff);

  @override
  Future<void> updateStaff(StaffMember staff) => _db.updateStaff(staff);

  @override
  Future<void> deleteStaff(int id) => _db.deleteStaff(id);

  @override
  Future<int> insertExpense(Expense expense) => _db.insertExpense(expense);

  @override
  Future<List<Expense>> getExpenses() => _db.getExpenses();
}
