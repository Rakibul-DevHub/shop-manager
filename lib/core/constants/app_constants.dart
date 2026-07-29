/// Shared app constants (presentation + domain helpers).
class AppConstants {
  AppConstants._();

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

  /// Days ahead to treat a dated product as “expiring soon”.
  static const expiryWarningDays = 30;

  static const splashDuration = Duration(milliseconds: 1600);
}
