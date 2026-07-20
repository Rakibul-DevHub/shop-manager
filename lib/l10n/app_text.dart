class AppText {
  AppText(this.code);

  final String code;
  bool get isBn => code == 'bn';

  String get appName => 'Shop Manager';
  String get splashTagline => isBn
      ? 'ছোট দোকানের সহজ ম্যানেজমেন্ট'
      : 'Small Store Management System';

  String get next => isBn ? 'পরবর্তী' : 'Next';
  String get skip => isBn ? 'এড়িয়ে যান' : 'Skip';
  String get continueLabel => isBn ? 'চালিয়ে যান' : 'Continue';
  String get save => isBn ? 'সেভ করুন' : 'Save';
  String get offline => isBn ? 'অফলাইন' : 'Offline';

  String get languageTitle => isBn ? 'ভাষা নির্বাচন' : 'Language Selection';
  String get chooseLanguage =>
      isBn ? 'অ্যাপের ভাষা বেছে নিন' : 'Choose your app language';

  String get signIn => isBn ? 'সাইন ইন' : 'Sign In';
  String get signUp => isBn ? 'সাইন আপ' : 'Sign Up';
  String get signInHint =>
      isBn ? 'সাইন ইন করে ব্যবহার করুন' : 'Sign in and use';
  String get signUpHint =>
      isBn ? 'সাইন আপ করে ব্যবহার করুন' : 'Sign up and use';
  String get emailPhone => isBn ? 'ইমেইল / ফোন' : 'Email / Phone Number';
  String get password => isBn ? 'পাসওয়ার্ড' : 'Password';
  String get confirmPassword =>
      isBn ? 'পাসওয়ার্ড নিশ্চিত করুন' : 'Confirm Password';
  String get userName => isBn ? 'ইউজার নাম' : 'User Name';
  String get email => isBn ? 'ইমেইল' : 'Email';
  String get phone => isBn ? 'ফোন নম্বর' : 'Phone Number';
  String get otp => 'OTP';
  String get demoOtpHint =>
      isBn ? 'ডেমো OTP: 1234' : 'Demo OTP: 1234';
  String get newUser => isBn ? 'নতুন ব্যবহারকারী?' : 'New user?';
  String get haveAccount =>
      isBn ? 'অ্যাকাউন্ট আছে?' : 'Already have an account?';

  String get shopSetup => isBn ? 'দোকান সেটআপ' : 'Shop Setup';
  String get shopSetupHint =>
      isBn ? 'মাত্র ১ মিনিটে শুরু করুন' : 'Start in just 1 minute';
  String get shopName => isBn ? 'দোকানের নাম' : 'Shop name';
  String get shopType => isBn ? 'দোকানের ধরন' : 'Shop type';
  String get startNow => isBn ? 'এখনই শুরু করুন' : 'Start now';

  String get home => isBn ? 'হোম' : 'Home';
  String get sell => isBn ? 'বিক্রি' : 'Sell';
  String get products => isBn ? 'পণ্য' : 'Products';
  String get dues => isBn ? 'বাকি' : 'Due';
  String get more => isBn ? 'আরও' : 'More';

  String get homeTitle => isBn ? 'হোম ড্যাশবোর্ড' : 'Home Dashboard';
  String get todaySummary => isBn ? 'আজকের সারাংশ' : "Today's summary";
  String get todaySales => isBn ? 'আজকের বিক্রি' : "Today's sales";
  String get profit => isBn ? 'লাভ' : 'Profit';
  String get due => isBn ? 'বাকি' : 'Due';
  String get lowStock => isBn ? 'কম স্টক' : 'Low stock';
  String get quickSell => isBn ? 'দ্রুত বিক্রি' : 'Quick Sell';
  String get quickActions => isBn ? 'দ্রুত অ্যাকশন' : 'Quick actions';

  String get quickSellTitle => isBn ? 'দ্রুত বিক্রি' : 'Quick Sell';
  String get quickSellHint =>
      isBn ? 'কোড দিন, বিক্রি শেষ করুন' : 'Enter code, finish sale';
  String get productCode => isBn ? 'পণ্য কোড' : 'Product code';
  String get flexiblePrice =>
      isBn ? 'দাম পরিবর্তন' : 'Flexible price';
  String get flexiblePriceHint => isBn
      ? 'বিক্রির সময় দাম কম/বেশি করা যাবে, কিন্তু ক্রয় দামের নিচে নয়'
      : 'Edit price at sale, but not below cost';
  String get qty => isBn ? 'পরিমাণ' : 'Quantity';
  String get total => isBn ? 'মোট' : 'Total';
  String get completeSale => isBn ? 'বিক্রি সম্পন্ন' : 'Complete sale';
  String get saleDone => isBn ? 'বিক্রি সম্পন্ন' : 'Sale completed';
  String get cash => isBn ? 'নগদ' : 'Cash';
  String get dueSale => isBn ? 'বাকি' : 'Due';
  String get customerName => isBn ? 'কাস্টমার নাম' : 'Customer name';
  String get customerPhone => isBn ? 'কাস্টমার ফোন' : 'Customer phone';
  String get ok => isBn ? 'ঠিক আছে' : 'OK';
  String get productNotFound =>
      isBn ? 'পণ্য পাওয়া যায়নি' : 'Product not found';

  String get productsTitle => isBn ? 'পণ্য / স্টক' : 'Products / Stock';
  String get searchProducts =>
      isBn ? 'কোড বা নাম লিখুন' : 'Search by code or name';
  String get addProduct =>
      isBn ? 'নতুন পণ্য যোগ করুন' : 'Add new product';
  String get stock => isBn ? 'স্টক' : 'Stock';
  String get cost => isBn ? 'ক্রয়' : 'Cost';
  String get sellPrice => isBn ? 'বিক্রি' : 'Sell';

  String get addProductTitle => isBn ? 'নতুন পণ্য যোগ' : 'Add product';
  String get productName => isBn ? 'পণ্যের নাম' : 'Product name';
  String get variant => isBn ? 'সাইজ/ধরন' : 'Size/Type';
  String get codeLabel => isBn ? 'কোড' : 'Code';
  String get costPrice => isBn ? 'ক্রয় দাম' : 'Cost price';
  String get sellPriceField => isBn ? 'বিক্রি দাম' : 'Sell price';
  String get stockCount => isBn ? 'স্টক সংখ্যা' : 'Stock count';
  String get saveProduct => isBn ? 'পণ্য সেভ করুন' : 'Save product';

  String get dueBook => isBn ? 'বাকি খাতা' : 'Due book';
  String get dueBookHint =>
      isBn ? 'কার কাছে কত টাকা আছে' : 'Who owes how much';
  String get collectMoney => isBn ? 'টাকা আদায়' : 'Collect payment';
  String get noDues => isBn ? 'কোনো বাকি নেই' : 'No dues';
  String get paymentTitle => isBn ? 'টাকা আদায়' : 'Collect payment';
  String get howMuchReceived =>
      isBn ? 'কত টাকা পেয়েছেন?' : 'How much received?';
  String get savePayment =>
      isBn ? 'পেমেন্ট সেভ করুন' : 'Save payment';
  String get totalDueLabel => isBn ? 'মোট বাকি' : 'Total due';

  String get expenseTitle => isBn ? 'খরচ যোগ করুন' : 'Add expense';
  String get expenseHint =>
      isBn ? 'আজকের খরচ লিখুন' : "Log today's expense";
  String get expenseType => isBn ? 'খরচের ধরন' : 'Expense type';
  String get amount => isBn ? 'টাকার পরিমাণ' : 'Amount';
  String get note => isBn ? 'নোট' : 'Note';
  String get saveExpense => isBn ? 'খরচ সেভ করুন' : 'Save expense';

  String get reportTitle => isBn ? 'ডেইলি রিপোর্ট' : 'Daily report';
  String get reportHint =>
      isBn ? 'তারিখ সিলেক্ট করে বিক্রি দেখুন' : 'Select date to view sales';
  String get pieces => isBn ? 'পিস' : 'Pcs';
  String get noSales =>
      isBn ? 'এই তারিখে কোনো বিক্রি নেই' : 'No sales on this date';

  String get lowStockTitle => isBn ? 'কম স্টক' : 'Low stock';
  String get lowStockHint =>
      isBn ? 'যেগুলো দ্রুত কিনতে হবে' : 'Items to restock soon';

  String get moreTitle => isBn ? 'আরও' : 'More';
  String get moreHint => isBn ? 'অন্য অপশনগুলো' : 'Other options';
  String get report => isBn ? 'রিপোর্ট' : 'Reports';
  String get expense => isBn ? 'খরচ' : 'Expense';
  String get settings => isBn ? 'সেটিংস' : 'Settings';
  String get settingsHint =>
      isBn ? 'ভাষা ও দোকান তথ্য' : 'Language and shop info';
  String get logout => isBn ? 'লগ আউট' : 'Log out';
  String get settingsSaved =>
      isBn ? 'সেটিংস সেভ হয়েছে' : 'Settings saved';
}
