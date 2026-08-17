class AppText {
  AppText(this.code);

  final String code;
  bool get isBn => code == 'bn';

  String get appName => 'Shop Manager';
  String get splashTagline => 'Small Business\nSmall Store Management System';
  String get splashSubtitle => 'Small Business';
  String get splashSystem => 'Small Store Management System';

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
  String get shopSummary => isBn ? 'দোকানের সারাংশ' : 'Shop summary';
  String get todaySales => isBn ? 'আজকের বিক্রি' : "Today's sales";
  String get profit => isBn ? 'লাভ' : 'Profit';
  String get due => isBn ? 'বাকি' : 'Due';
  String get lowStock => isBn ? 'কম স্টক' : 'Low stock';
  String get stockValue => isBn ? 'স্টকের মূল্য' : 'Stock value';
  String get stockItems => isBn ? 'মোট স্টক' : 'Total stock';
  String get todayExpense => isBn ? 'আজকের খরচ' : "Today's expense";
  String get todayReturns => isBn ? 'আজকের রিটার্ন' : "Today's returns";
  String get todayReturnsHint =>
      isBn ? 'রিটার্ন সংখ্যা ও টাকা' : 'Return count and amount';
  String get returnsListTitle => isBn ? 'রিটার্ন তালিকা' : 'Returns';
  String get noReturns => isBn ? 'কোনো রিটার্ন নেই' : 'No returns';
  String get returnAmount => isBn ? 'রিটার্ন টাকা' : 'Return amount';
  String get itemsUnit => isBn ? 'পিস' : 'pcs';
  String get viewReport => isBn ? 'রিপোর্ট দেখুন' : 'View report';
  String get saleHistory => isBn ? 'বিক্রির ইতিহাস' : 'Sale history';
  String get saleHistoryHint =>
      isBn ? 'তারিখ বেছে নিয়ে বিক্রি দেখুন' : 'Filter and review each sale';
  String get noSaleHistory =>
      isBn ? 'এই সময়ে কোনো বিক্রি নেই' : 'No sales in this period';
  String get salesTrend => isBn ? 'বিক্রি ট্রেন্ড' : 'Sales trend';
  String get salesTrendHint => isBn
      ? 'প্রতিদিনের বিক্রি ও লাভ (কমপক্ষে শেষ ৭ দিন)'
      : 'Daily sales & profit (at least last 7 days)';
  String get salesTrendEmpty => isBn
      ? 'এই সময়ে বিক্রি নেই — দিনগুলো ০ হিসেবে দেখানো হয়েছে'
      : 'No sales in this window — days show as zero';
  String get topProductsChart =>
      isBn ? 'টপ পণ্য (লাভ)' : 'Top products (profit)';
  String get composition => isBn ? 'বিক্রি ভাঙ্গন' : 'Sales mix';
  String get quickSell => isBn ? 'দ্রুত বিক্রি' : 'Quick Sell';
  String get quickActions => isBn ? 'দ্রুত অ্যাকশন' : 'Quick actions';

  String get quickSellTitle => isBn ? 'দ্রুত বিক্রি' : 'Quick Sell';
  String get quickSellHint =>
      isBn ? 'কোড দিন, বিক্রি শেষ করুন' : 'Enter code, finish sale';
  String get scanCodeTitle => isBn ? 'কোড স্ক্যান' : 'Scan code';
  String get scanCodeHint => isBn
      ? 'পণ্যের QR / বারকোড ক্যামেরায় ধরুন'
      : 'Point the rear camera at the QR / barcode';
  String get cameraUnavailable => isBn
      ? 'ক্যামেরা ব্যবহার করা যাচ্ছে না'
      : 'Camera is not available';
  String get torch => isBn ? 'ফ্ল্যাশ' : 'Flash';
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
  String get addToCart => isBn ? 'কার্টে যোগ' : 'Add to cart';
  String get cart => isBn ? 'কার্ট' : 'Cart';
  String get cartEmpty => isBn ? 'কার্ট খালি' : 'Cart is empty';
  String get checkout => isBn ? 'চেকআউট' : 'Checkout';
  String get remove => isBn ? 'সরান' : 'Remove';
  String get holdBill => isBn ? 'বিল হোল্ড' : 'Hold bill';
  String get heldBills => isBn ? 'হোল্ড করা বিল' : 'Held bills';
  String get resumeBill => isBn ? 'আবার নিন' : 'Resume';
  String get discardBill => isBn ? 'ফেলে দিন' : 'Discard';
  String get noHeldBills => isBn ? 'কোনো হোল্ড বিল নেই' : 'No held bills';
  String get billHeld => isBn ? 'বিল হোল্ড হয়েছে' : 'Bill held';
  String get discount => isBn ? 'ছাড়' : 'Discount';
  String get discountNone => isBn ? 'ছাড় নেই' : 'No discount';
  String get discountPercent => isBn ? 'শতাংশ %' : 'Percent %';
  String get discountAmount => isBn ? 'টাকায়' : 'Amount ৳';
  String get discountReason => isBn ? 'ছাড়ের কারণ' : 'Discount reason';
  String get itemDiscount => isBn ? 'আইটেম ছাড়' : 'Item offer';
  String get billDiscount => isBn ? 'বিল ছাড়' : 'Bill discount';
  String get productDiscount => isBn ? 'পণ্যের ছাড়' : 'Product offer';
  String get productDiscountHint => isBn
      ? 'দোকান/স্টোরের সাধারণ ছাড় (বিক্রির সময় আগে থেকে আসবে)'
      : 'Common shop offer (pre-fills at sell)';
  String get youSave => isBn ? 'ছাড়' : 'You save';
  String get afterDiscount => isBn ? 'ছাড়ের পর' : 'After discount';
  String get subtotal => isBn ? 'সাবটোটাল' : 'Subtotal';
  String get payable => isBn ? 'পরিশোধযোগ্য' : 'Payable';
  String get sellMode => isBn ? 'বিক্রি' : 'Sell';
  String get returnMode => isBn ? 'রিটার্ন' : 'Return';
  String get returnStock => isBn ? 'স্টকে ফেরত' : 'Return to stock';
  String get returnDone => isBn ? 'রিটার্ন সম্পন্ন' : 'Return completed';
  String get weightMode => isBn ? 'ওজন (কেজি)' : 'Weight (kg)';
  String get pieceMode => isBn ? 'পিস' : 'Pieces';
  String get weightQty => isBn ? 'ওজন (কেজি)' : 'Weight (kg)';
  String get invalidWeight => isBn ? 'সঠিক ওজন দিন' : 'Enter a valid weight';
  String get cartAdded => isBn ? 'কার্টে যোগ হয়েছে' : 'Added to cart';

  String get productsTitle => isBn ? 'স্টোর / স্টক' : 'Store / Stock';
  String get productsTitleSimple => isBn ? 'পণ্য' : 'Products';
  String get storeTab => isBn ? 'স্টোর (দোকান)' : 'Store (shop)';
  String get stockTab => isBn ? 'স্টক (ওয়্যারহাউস)' : 'Stock (warehouse)';
  String get storeHint => isBn
      ? 'দোকানের পণ্য — অফার সেট করুন, স্টোর পরিমাণ দেখুন'
      : 'Shop floor — set offers and see store qty';
  String get storeHintSimple => isBn
      ? 'পণ্য যোগ করুন, অফার সেট করুন, বিক্রি করুন'
      : 'Add products, set offers, and sell';
  String get stockHint => isBn
      ? 'মূল ওয়্যারহাউস — পণ্য যোগ ও স্টোরে পাঠান'
      : 'Main warehouse — add products and send to store';
  String get setProductOffer =>
      isBn ? 'অফার সেট করুন' : 'Set product offer';
  String get saveOffer => isBn ? 'অফার সেভ' : 'Save offer';
  String get offerSaved => isBn ? 'অফার সেভ হয়েছে' : 'Offer saved';
  String get searchProducts =>
      isBn ? 'কোড বা নাম লিখুন' : 'Search by code or name';
  String get addProduct =>
      isBn ? 'নতুন পণ্য যোগ করুন' : 'Add new product';
  String get stock => isBn ? 'স্টক' : 'Stock';
  String get storeQty => isBn ? 'স্টোর পরিমাণ' : 'Store qty';
  String get warehouseQty => isBn ? 'ওয়্যারহাউস পরিমাণ' : 'Warehouse qty';
  String get totalQty => isBn ? 'মোট পরিমাণ' : 'Total qty';
  String get sendToStore => isBn ? 'স্টোরে পাঠান' : 'Send to store';
  String get returnToWarehouse =>
      isBn ? 'ওয়্যারহাউসে ফেরত' : 'Back to warehouse';
  String get transferQty => isBn ? 'পাঠানোর পরিমাণ' : 'Transfer qty';
  String get transferDone => isBn ? 'ট্রান্সফার হয়েছে' : 'Transfer done';
  String get cost => isBn ? 'ক্রয়' : 'Cost';
  String get sellPrice => isBn ? 'বিক্রি' : 'Sell';
  String get noOffer => isBn ? 'কোনো অফার নেই' : 'No offer';
  String get editOffer => isBn ? 'অফার এডিট' : 'Edit offer';
  String get notEnoughStore =>
      isBn ? 'স্টোরে যথেষ্ট নেই' : 'Not enough store stock';

  String get addProductTitle => isBn ? 'নতুন পণ্য যোগ' : 'Add product';
  String get productName => isBn ? 'পণ্যের নাম' : 'Product name';
  String get variant => isBn ? 'সাইজ/ধরন' : 'Size/Type';
  String get codeLabel => isBn ? 'কোড' : 'Code';
  String get costPrice => isBn ? 'ক্রয় দাম' : 'Cost price';
  String get sellPriceField => isBn ? 'বিক্রি দাম' : 'Sell price';
  String get stockCount => isBn ? 'স্টক সংখ্যা' : 'Stock count';
  String get saveProduct => isBn ? 'পণ্য সেভ করুন' : 'Save product';
  String get fillAllFields =>
      isBn ? 'সব ঘর পূরণ করুন' : 'Please fill all fields';
  String get invalidPrice =>
      isBn ? 'সঠিক দাম দিন' : 'Enter a valid price';
  String get invalidStockQty =>
      isBn ? 'সঠিক স্টক সংখ্যা দিন' : 'Enter a valid stock quantity';
  String get expiryRequired =>
      isBn ? 'মেয়াদ তারিখ দিন' : 'Please set expiry date';
  String get discountValueRequired =>
      isBn ? 'ছাড়ের মান দিন' : 'Enter discount value';
  String get expiryDate => isBn ? 'মেয়াদ উত্তীর্ণের তারিখ' : 'Expiry date';
  String get expiryDateOptional =>
      isBn ? 'ঐচ্ছিক (খাবার ইত্যাদি)' : 'Optional (food / perishable)';
  String get expiryDateHint => isBn
      ? 'শুধু খাবার বা মেয়াদযুক্ত পণ্যের জন্য'
      : 'Only for food or dated products';
  String get setExpiryDate => isBn ? 'মেয়াদ তারিখ দিন' : 'Set expiry date';
  String get clearExpiryDate => isBn ? 'মেয়াদ সরান' : 'Clear expiry';
  String get noExpiry => isBn ? 'মেয়াদ নেই' : 'No expiry';
  String get expired => isBn ? 'মেয়াদ শেষ' : 'Expired';
  String get expiringSoon => isBn ? 'শীঘ্রই শেষ' : 'Expiring soon';
  String get expiresOn => isBn ? 'মেয়াদ' : 'Expires';
  String get expiryAlerts => isBn ? 'মেয়াদ সতর্কতা' : 'Expiry alerts';
  String get expiryAlertsHint => isBn
      ? 'মেয়াদ শেষ বা শীঘ্রই শেষ হওয়া পণ্য'
      : 'Expired or soon-to-expire products';
  String get noExpiryAlerts =>
      isBn ? 'মেয়াদ সতর্কতার পণ্য নেই' : 'No expiry alerts';
  String get daysLeft => isBn ? 'দিন বাকি' : 'days left';
  String get expiredAgo => isBn ? 'দিন আগে শেষ' : 'days overdue';
  String get sellExpiredWarning => isBn
      ? 'সতর্কতা: এই পণ্যের মেয়াদ শেষ হয়ে গেছে'
      : 'Warning: this product is past expiry';
  String get sellExpiringWarning => isBn
      ? 'সতর্কতা: মেয়াদ শীঘ্রই শেষ হচ্ছে'
      : 'Warning: this product expires soon';

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

  String get reportTitle => isBn ? 'রিপোর্ট' : 'Reports';
  String get reportHint =>
      isBn ? 'তারিখ বেছে নিয়ে বিক্রি দেখুন' : 'Pick dates to view sales';
  String get pieces => isBn ? 'পিস' : 'Pcs';
  String get noSales =>
      isBn ? 'এই সময়ে কোনো বিক্রি নেই' : 'No sales in this period';
  String get today => isBn ? 'আজ' : 'Today';
  String get thisWeek => isBn ? 'এই সপ্তাহ' : 'This week';
  String get thisMonth => isBn ? 'এই মাস' : 'This month';
  String get previousMonth => isBn ? 'আগের মাস' : 'Previous month';
  String get customRange => isBn ? 'কাস্টম রেঞ্জ' : 'Custom range';
  String get startDate => isBn ? 'শুরুর তারিখ' : 'Start date';
  String get endDate => isBn ? 'শেষ তারিখ' : 'End date';
  String get pickDate => isBn ? 'তারিখ বাছুন' : 'Pick date';
  String get deepInsights => isBn ? 'গভীর বিশ্লেষণ' : 'Deep insights';
  String get marginHealth => isBn ? 'মার্জিন স্বাস্থ্য' : 'Margin health';
  String get marginHealthHint => isBn
      ? 'বিক্রির পর কত % লাভ থাকছে'
      : 'How much of sales stays as profit';
  String get grossMargin => isBn ? 'গ্রস মার্জিন' : 'Gross margin';
  String get cogs => isBn ? 'পণ্য খরচ (COGS)' : 'Cost of goods';
  String get avgPerLine => isBn ? 'গড় বিক্রি/লাইন' : 'Avg per sale line';
  String get avgProfitPiece => isBn ? 'গড় লাভ/পিস' : 'Avg profit / pc';

  String get cashVsDue => isBn ? 'নগদ বনাম বাকি' : 'Cash vs due';
  String get cashVsDueHint => isBn
      ? 'কত টাকা হাতে, কত বাকিতে'
      : 'Money in hand vs outstanding credit';
  String get cashSales => isBn ? 'নগদ বিক্রি' : 'Cash sales';
  String get dueSales => isBn ? 'বাকি বিক্রি' : 'Due sales';
  String get dueShare => isBn ? 'বাকির অংশ' : 'Due share';

  String get thinMarginWatch =>
      isBn ? 'কম মার্জিন সতর্কতা' : 'Thin margin watch';
  String get thinMarginHint => isBn
      ? '১০%-এর নিচে, শূন্য বা লসের বিক্রি — ট্যাপ করে তালিকা দেখুন'
      : 'Sold under 10% margin, zero, or at a loss — tap to view list';
  String get thinMarginListTitle =>
      isBn ? 'কম মার্জিনের পণ্য' : 'Thin-margin products';
  String get thinMarginSaleCount => isBn ? 'বিক্রি' : 'sales';
  String get saleDetails => isBn ? 'বিক্রির বিবরণ' : 'Sale details';
  String get tapForDetails =>
      isBn ? 'বিস্তারিত দেখতে ট্যাপ করুন' : 'Tap to expand details';
  String get noThinMargin =>
      isBn ? 'কম মার্জিনের বিক্রি নেই' : 'No thin-margin sales';
  String get marginLabel => isBn ? 'মার্জিন' : 'Margin';
  String get salesmanOptional =>
      isBn ? 'সেলসম্যান আইডি (ঐচ্ছিক)' : 'Salesman ID (optional)';
  String get salesmanId => isBn ? 'সেলসম্যান আইডি' : 'Salesman ID';
  String get salesmanLabel => isBn ? 'সেলসম্যান' : 'Salesman';

  String get topByProfit => isBn ? 'সবচেয়ে লাভজনক' : 'Top by profit';
  String get topByProfitHint =>
      isBn ? 'এই সময়ে সবচেয়ে বেশি লাভ' : 'Highest profit in this period';
  String get topByQty => isBn ? 'সবচেয়ে বেশি বিক্রি' : 'Top by quantity';
  String get topByQtyHint =>
      isBn ? 'পিস অনুযায়ী সেরা পণ্য' : 'Best movers by pieces sold';
  String get topByRevenue => isBn ? 'সবচেয়ে বেশি আয়' : 'Top by revenue';
  String get topByRevenueHint =>
      isBn ? 'টাকা অনুযায়ী সেরা পণ্য' : 'Highest revenue products';
  String get noProductInsight =>
      isBn ? 'এখনো কোনো পণ্য বিক্রি নেই' : 'No product sales yet';

  String get lossSales => isBn ? 'লসে বিক্রি' : 'Loss sales';
  String get lossSalesHint => isBn
      ? 'যে বিক্রিতে লাভ নেগেটিভ'
      : 'Sales sold below cost (negative profit)';
  String get breakEvenSales =>
      isBn ? 'লাভ/লস ছাড়া বিক্রি' : 'No profit / no loss';
  String get breakEvenHint => isBn
      ? 'ক্রয় দামেই বিক্রি হয়েছে'
      : 'Sold at cost — zero margin';
  String get noLossSales =>
      isBn ? 'কোনো লসের বিক্রি নেই' : 'No loss sales';
  String get noBreakEvenSales =>
      isBn ? 'কোনো ব্রেক-ইভেন বিক্রি নেই' : 'No break-even sales';
  String get periodExpense => isBn ? 'সময়ের খরচ' : 'Period expense';
  String get netEstimate => isBn ? 'আনুমানিক নেট' : 'Est. net';

  String get lowStockTitle => isBn ? 'কম স্টক' : 'Low stock';
  String get lowStockHint =>
      isBn ? 'যেগুলো দ্রুত কিনতে হবে' : 'Items to restock soon';

  String get moreTitle => isBn ? 'আরও' : 'More';
  String get moreHint =>
      isBn ? 'প্রোফাইল, স্টাফ ও সেটিংস' : 'Profile, staff and settings';
  String get report => isBn ? 'রিপোর্ট' : 'Reports';
  String get expense => isBn ? 'খরচ' : 'Expense';
  String get settings => isBn ? 'সেটিংস' : 'Settings';
  String get settingsHint =>
      isBn ? 'ভাষা ও দোকান তথ্য' : 'Language and shop info';
  String get featureOptions => isBn ? 'ফিচার অপশন' : 'Feature options';
  String get warehouseInventory =>
      isBn ? 'স্টক (ওয়্যারহাউস)' : 'Stock (warehouse)';
  String get warehouseInventoryHint => isBn
      ? 'চালু করলে স্টোর ও ওয়্যারহাউস আলাদা থাকবে'
      : 'When on, store and warehouse stock are separate';
  String get expiryTracking => isBn ? 'মেয়াদ ট্র্যাকিং' : 'Expiry tracking';
  String get expiryTrackingHint => isBn
      ? 'চালু করলে পণ্যে মেয়াদ তারিখ ও সতর্কতা পাবেন'
      : 'When on, products can have expiry dates and alerts';
  String get logout => isBn ? 'লগ আউট' : 'Log out';
  String get settingsSaved =>
      isBn ? 'সেটিংস সেভ হয়েছে' : 'Settings saved';

  String get profile => isBn ? 'ইউজার প্রোফাইল' : 'User profile';
  String get profileHint =>
      isBn ? 'মালিকের নাম ও যোগাযোগ' : 'Owner name and contact';
  String get profileSaved =>
      isBn ? 'প্রোফাইল সেভ হয়েছে' : 'Profile saved';
  String get ownerRole => isBn ? 'মালিক' : 'Owner';

  String get addStaff => isBn ? 'স্টাফ যোগ করুন' : 'Add staff';
  String get addStaffHint =>
      isBn ? 'নতুন কর্মী যোগ করুন' : 'Add a new team member';
  String get manageStaff => isBn ? 'স্টাফ ম্যানেজ' : 'Manage staff';
  String get manageStaffHint =>
      isBn ? 'কর্মী দেখুন, এডিট বা সরিয়ে দিন' : 'View, edit or remove staff';
  String get accessLevels => isBn ? 'অ্যাক্সেস লেভেল' : 'Access levels';
  String get accessLevelsHint => isBn
      ? 'কোন ফিচার কে ব্যবহার করতে পারবে'
      : 'Control which features each staff can use';
  String get staffName => isBn ? 'স্টাফের নাম' : 'Staff name';
  String get staffPhone => isBn ? 'স্টাফের ফোন' : 'Staff phone';
  String get staffRole => isBn ? 'রোল' : 'Role';
  String get staffActive => isBn ? 'সক্রিয়' : 'Active';
  String get noStaff => isBn ? 'কোনো স্টাফ নেই' : 'No staff yet';
  String get saveStaff => isBn ? 'স্টাফ সেভ করুন' : 'Save staff';
  String get editStaff => isBn ? 'স্টাফ এডিট' : 'Edit staff';
  String get deleteStaff => isBn ? 'স্টাফ মুছুন' : 'Delete staff';
  String get staffSaved =>
      isBn ? 'স্টাফ সেভ হয়েছে' : 'Staff saved';
  String get permissions => isBn ? 'পারমিশন' : 'Permissions';
  String get roleCashier => isBn ? 'ক্যাশিয়ার' : 'Cashier';
  String get roleManager => isBn ? 'ম্যানেজার' : 'Manager';
  String get roleAdmin => isBn ? 'অ্যাডমিন' : 'Admin';
  String get roleCustom => isBn ? 'কাস্টম' : 'Custom';
  String get permSell => isBn ? 'বিক্রি' : 'Sell';
  String get permProducts => isBn ? 'পণ্য' : 'Products';
  String get permDues => isBn ? 'বাকি' : 'Dues';
  String get permExpenses => isBn ? 'খরচ' : 'Expenses';
  String get permReports => isBn ? 'রিপোর্ট' : 'Reports';
  String get permSettings => isBn ? 'সেটিংস' : 'Settings';
  String get permManageStaff => isBn ? 'স্টাফ ম্যানেজ' : 'Manage staff';
  String get deleteConfirm =>
      isBn ? 'এই স্টাফ মুছে ফেলবেন?' : 'Delete this staff member?';
  String get cancel => isBn ? 'বাতিল' : 'Cancel';
  String get delete => isBn ? 'মুছুন' : 'Delete';
}
