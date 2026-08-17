import '../entities/customer.dart';
import '../entities/expense.dart';
import '../entities/payment.dart';
import '../entities/product.dart';
import '../entities/sale.dart';
import '../entities/staff.dart';
import '../entities/user.dart';

/// Domain contract for all shop persistence (offline SQLite).
abstract class ShopRepository {
  // Settings / session
  Future<String?> getSetting(String key);
  Future<void> setSetting(String key, String value);
  Future<void> removeSetting(String key);
  Future<bool> getBoolSetting(String key, {bool fallback = false});
  Future<void> setBoolSetting(String key, bool value);

  // Shop
  Future<ShopProfile?> getShop();
  Future<void> upsertShop(ShopProfile shop);

  // Auth (optional / future)
  Future<int> insertUser(AppUser user);
  Future<AppUser?> findUserByLogin(String login);
  Future<bool> emailOrPhoneExists(String email, String phone);

  // Catalog
  Future<List<Product>> getProducts();
  Future<Product?> getProductByCode(String code);
  Future<int> insertProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<List<Product>> getLowStock(int threshold);
  Future<void> seedDemoCatalog();

  // Customers / dues
  Future<List<Customer>> getDueCustomers();
  Future<Customer?> getCustomerByPhone(String phone);
  Future<int> insertCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> insertPayment({
    required int customerId,
    required double amount,
    required DateTime paidAt,
  });
  Future<List<Payment>> getPaymentsForCustomer(int customerId);

  // Sales
  Future<int> insertSale(SaleRecord sale);
  Future<List<SaleRecord>> getSalesForDay(DateTime day);
  Future<List<SaleRecord>> getSalesInRange(DateTime start, DateTime end);
  Future<List<DateTime>> getSaleDays({int limit = 14});

  // Staff
  Future<List<StaffMember>> getStaff();
  Future<int> insertStaff(StaffMember staff);
  Future<void> updateStaff(StaffMember staff);
  Future<void> deleteStaff(int id);

  // Expenses
  Future<int> insertExpense(Expense expense);
  Future<List<Expense>> getExpenses();
}
