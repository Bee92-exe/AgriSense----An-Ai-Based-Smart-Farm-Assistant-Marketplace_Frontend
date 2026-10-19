import '../models/growth.dart';

/// Seed content for the console screens added after F8.
///
/// Written as plain model values rather than JSON: these features do not have
/// an `API_SPEC` section yet, so inventing a wire shape here would be a contract
/// nobody agreed to. The repository interfaces are the seam the real client
/// will replace, exactly as the earlier mock repositories are.

DateTime _daysAgo(int days, {int hour = 10}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour)
      .subtract(Duration(days: days));
}

/// Seven days of revenue ending today, in taka.
List<TrendPoint> vendorWeekSeed() {
  const values = [4200.0, 6100.0, 3800.0, 7400.0, 5200.0, 8900.0, 6600.0];
  return [
    for (var i = 0; i < values.length; i++)
      TrendPoint(
        day: _daysAgo(values.length - 1 - i),
        value: values[i],
      ),
  ];
}

List<VendorCustomer> vendorCustomerSeed() => [
      VendorCustomer(
        id: 'cus-1',
        name: 'সেলিনা বেগম',
        mobile: '01712000451',
        district: 'টাঙ্গাইল',
        orders: 4,
        totalSpent: 4280,
        lastOrderAt: _daysAgo(1),
        segment: 'loyal',
        note: 'ধানের ছত্রাকনাশক নিয়মিত নেন। বিকেল ৪টার পরে ফোন করতে বলেন।',
        followUp: true,
      ),
      VendorCustomer(
        id: 'cus-2',
        name: 'মোঃ হাসান আলী',
        mobile: '01715000933',
        district: 'কিশোরগঞ্জ',
        orders: 2,
        totalSpent: 1940,
        lastOrderAt: _daysAgo(2),
        segment: 'repeat',
        note: 'স্প্রেয়ার মেরামতের জন্য খোঁজ নিয়েছিলেন।',
      ),
      VendorCustomer(
        id: 'cus-3',
        name: 'আবু বকর সিদ্দিক',
        mobile: '01819000712',
        district: 'চট্টগ্রাম',
        orders: 6,
        totalSpent: 8120,
        lastOrderAt: _daysAgo(1),
        segment: 'loyal',
        note: 'বড় বাগান, একসাথে বেশি পরিমাণ নেন।',
      ),
      VendorCustomer(
        id: 'cus-4',
        name: 'রুবেল হোসেন',
        mobile: '01913000488',
        district: 'ময়মনসিংহ',
        orders: 1,
        totalSpent: 760,
        lastOrderAt: _daysAgo(9),
        segment: 'new',
        note: 'প্রথম অর্ডার — ফলোআপ করুন।',
        followUp: true,
      ),
      VendorCustomer(
        id: 'cus-5',
        name: 'নাসরিন আক্তার',
        mobile: '01617000221',
        district: 'গাজীপুর',
        orders: 3,
        totalSpent: 2650,
        lastOrderAt: _daysAgo(24),
        segment: 'atRisk',
        note: '২৪ দিন ধরে অর্ডার নেই।',
      ),
      VendorCustomer(
        id: 'cus-6',
        name: 'শাহানারা খাতুন',
        mobile: '01733000654',
        district: 'রংপুর',
        orders: 2,
        totalSpent: 1310,
        lastOrderAt: _daysAgo(16),
        segment: 'repeat',
      ),
    ];

List<VendorPayout> vendorPayoutSeed() => [
      VendorPayout(
        id: 'pay-1',
        amount: 18400,
        at: _daysAgo(3),
        status: 'paid',
      ),
      VendorPayout(
        id: 'pay-2',
        amount: 12650,
        at: _daysAgo(10),
        status: 'paid',
      ),
      VendorPayout(
        id: 'pay-3',
        amount: 9200,
        at: _daysAgo(17),
        status: 'paid',
      ),
    ];

VendorBusiness vendorBusinessSeed() => VendorBusiness(
      week: vendorWeekSeed(),
      revenue30: 186400,
      profit30: 51200,
      commission30: 9320,
      pendingPayout: 14850,
      storeVisits: 2140,
      orders30: 96,
      payouts: vendorPayoutSeed(),
      topProducts: const [
        (name: 'ট্রাইসাইক্লাজল ৭৫% ডব্লিউপি', units: 84, revenue: 40320),
        (name: 'ম্যানকোজেব ৮০% ডব্লিউপি', units: 61, revenue: 19520),
        (name: 'হ্যান্ড স্প্রেয়ার ১৬ লিটার', units: 18, revenue: 29700),
        (name: 'জিংক সালফেট', units: 42, revenue: 31920),
      ],
      customers: vendorCustomerSeed(),
    );

/// The expert's feed. One article is the signed-in expert's own, the rest come
/// from peers so the feed feels like a network from the first frame.
List<ExpertArticle> expertArticleSeed() => [
      ExpertArticle(
        id: 'art-1',
        title: 'ধানের ব্লাস্ট: দাগ দেখেই কীভাবে বুঝবেন',
        summary:
            'পাতার মাঝখানে নৌকা-আকৃতির দাগ আর গিঁটের কালো হয়ে যাওয়া — এই দুই লক্ষণ একসাথে দেখলে ব্লাস্টের সম্ভাবনা বেশি।',
        body:
            'ব্লাস্টের প্রথম লক্ষণ সাধারণত পাতার উপর ছোট বাদামি দাগ। দাগ বড় হয়ে মাঝখানে ধূসর আর কিনারায় বাদামি হয়। '
            'গিঁট বা শীষের গোড়া কালো হয়ে ভেঙে পড়লে রোগটি অনেক দূর এগিয়েছে।\n\n'
            'প্রথমে জমির পানি নিষ্কাশন করুন এবং নাইট্রোজেন সারের শেষ কিস্তি কমান। আক্রান্ত পাতা সরিয়ে '
            'জমির বাইরে পুড়িয়ে ফেলুন। কোন ছত্রাকনাশক কত মাত্রায় দেবেন, তা উপ-সহকাारী কৃষি কর্মকর্তার '
            'সঙ্গে মিলে ঠিক করুন — অ্যাপ নিজে থেকে মাত্রা বলে না।',
        authorName: 'ড. মাহবুবুর রহমান',
        authorTitle: 'ধান ও সবজির রোগ বিশেষজ্ঞ',
        crop: 'ধান',
        publishedAt: _daysAgo(1, hour: 8),
        likes: 128,
        views: 1740,
        rating: 4.8,
        ratingCount: 46,
        comments: [
          ArticleComment(
            id: 'cm-1',
            authorName: 'আব্দুল করিম',
            body: 'আমার জমিতে ঠিক এই দাগই দেখছি। পানি নিষ্কাশন শুরু করেছি।',
            at: _daysAgo(1, hour: 11),
            likes: 4,
          ),
          ArticleComment(
            id: 'cm-2',
            authorName: 'ড. ফেরদৌসী আক্তার',
            body: 'ভালো পরামর্শ। শেষ কিস্তির আগে মাটি পরীক্ষা করলে আরও নিশ্চিত হওয়া যায়।',
            at: _daysAgo(1, hour: 13),
            isExpert: true,
            likes: 12,
          ),
        ],
        coverTone: 0,
        mine: true,
      ),
      ExpertArticle(
        id: 'art-2',
        title: 'টমেটোতে সাদা মাছি: জৈব দমন কীভাবে শুরু করবেন',
        summary:
            'হলুদ আঠালো ফাঁদ আর নিমের নির্যাস — রাসায়নিকের আগে এই দুটি ধাপ খেতে রাখলে ভাইরাস ছড়ানো কমে।',
        body:
            'সাদা মাছি পাতাের নিচে বসে রস শোষণ করে এবং পাতা কোঁকড়ানো ভাইরাস বহন করে। '
            'প্রতি একক জমিতে ৮–১০টি হলুদ আঠালো ফাঁদ বসান, সপ্তাহে একবার ফাঁদ বদলান। '
            'আক্রমণ বেশি হলে আক্রান্ত গাছ তুলে ফেলুন এবং জৈব বালাইনাশক ব্যবহার করুন।',
        authorName: 'ড. ফেরদৌসী আক্তার',
        authorTitle: 'কীটতত্ত্ববিদ, BARI',
        crop: 'টমেটো',
        publishedAt: _daysAgo(3, hour: 9),
        likes: 86,
        views: 1120,
        rating: 4.6,
        ratingCount: 31,
        comments: [
          ArticleComment(
            id: 'cm-3',
            authorName: 'নাসরিন আক্তার',
            body: 'ফাঁদ কোথায় কিনতে পাব?',
            at: _daysAgo(2, hour: 10),
            likes: 2,
          ),
        ],
        coverTone: 1,
      ),
      ExpertArticle(
        id: 'art-3',
        title: 'আলুর নাবি ধসা: কুয়াশার আগেই প্রস্তুতি',
        summary:
            'তাপমাত্রা নেমে আসার আগে বীজ শোধন আর জমিতে পানি জমতে না দেওয়া — এই দুটোই সবচেয়ে বড় প্রতিরোধ।',
        body:
            'নাবি ধসা ঠান্ডা ও আর্দ্র আবহাওয়ায় দ্রুত ছড়ায়। জমিতে পানি জমতে দেবেন না এবং '
            'সেচ কমিয়ে দিন। আক্রান্ত গাছ তুলে মাটির গভীরে পুঁতে ফেলুন। '
            'প্রতিদিন জমি পরিদর্শন করুন; এক রাতের মধ্যেও সংক্রমণ বাড়তে পারে।',
        authorName: 'ড. মাহবুবুর রহমান',
        authorTitle: 'ধান ও সবজির রোগ বিশেষজ্ঞ',
        crop: 'আলু',
        publishedAt: _daysAgo(6, hour: 14),
        likes: 74,
        views: 980,
        rating: 4.7,
        ratingCount: 27,
        comments: const [],
        coverTone: 2,
        mine: true,
      ),
      ExpertArticle(
        id: 'art-4',
        title: 'সার দেওয়ার আগে মাটি পরীক্ষা কেন জরুরি',
        summary:
            'একই জমিতে প্রতি বছর একই সার দিলে ফলন বাড়ে না — মাটির নিজস্ব ঘাটতিটা জানতে হয়।',
        body:
            'মাটি পরীক্ষার রিপোর্ট দেখে সার নির্ধারণ করলে ইউরিয়া ও পটাশের অপচয় কমে। '
            'প্রতি দুই বছর অন্তর নিকটস্থ কৃষি অফিস থেকে পরীক্ষা করিয়ে নিন। '
            'জৈব পদার্থ বাড়ানোর জন্য গোবর বা কম্পোস্ট নিয়মিত দিন।',
        authorName: 'ড. আনিসুর রহমান',
        authorTitle: 'মৃত্তিকা বিজ্ঞানী, SRDI',
        crop: 'সব ফসল',
        publishedAt: _daysAgo(9, hour: 11),
        likes: 59,
        views: 760,
        rating: 4.4,
        ratingCount: 18,
        comments: const [],
        coverTone: 3,
      ),
    ];

List<ExpertQuestion> expertQuestionSeed() => [
      ExpertQuestion(
        id: 'q-1',
        farmerName: 'সেলিনা বেগম',
        farmerDistrict: 'টাঙ্গাইল',
        crop: 'টমেটো',
        question:
            'টমেটোর পাতা কুঁকড়ে যাচ্ছে আর নিচে সাদা পোকা দেখছি। কী করব?',
        mode: 'video',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        urgent: true,
      ),
      ExpertQuestion(
        id: 'q-2',
        farmerName: 'আব্দুল করিম',
        farmerDistrict: 'ঢাকা',
        crop: 'ধান',
        question:
            'ধান গাছের গোড়া কালো হয়ে যাচ্ছে। এটা কি ব্লাস্ট নাকি অন্য কিছু?',
        mode: 'message',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ExpertQuestion(
        id: 'q-3',
        farmerName: 'রুবেল হোসেন',
        farmerDistrict: 'ময়মনসিংহ',
        crop: 'আলু',
        question:
            'আলুর জমিতে পানি জমেছে। এখনই সেচ বন্ধ করব, নাকি অপেক্ষা করব?',
        mode: 'call',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ExpertQuestion(
        id: 'q-4',
        farmerName: 'শাহানারা খাতুন',
        farmerDistrict: 'রংপুর',
        crop: 'আলু',
        question: 'নাবি ধসার জন্য কোন ছত্রাকনাশক ভালো?',
        mode: 'message',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
      ExpertQuestion(
        id: 'q-5',
        farmerName: 'নাসরিন আক্তার',
        farmerDistrict: 'গাজীপুর',
        crop: 'টমেটো',
        question: 'হলুদ আঠালো ফাঁদ কোথা থেকে পাওয়া যায়?',
        mode: 'message',
        createdAt: _daysAgo(1, hour: 16),
        answered: true,
        reply:
            'নিকটস্থ কৃষি উপকরণের দোকানে পাওয়া যায়। না পেলে উপ-সহকারী কৃষি কর্মকর্তার সাথে যোগাযোগ করুন।',
      ),
      ExpertQuestion(
        id: 'q-6',
        farmerName: 'মোঃ হাসান আলী',
        farmerDistrict: 'কিশোরগঞ্জ',
        crop: 'ধান',
        question: 'বোরো ধানে ইউরিয়ার শেষ কিস্তি কখন দেব?',
        mode: 'call',
        createdAt: _daysAgo(2, hour: 12),
        answered: true,
        reply: 'শীষ বেরোনোর ১০–১২ দিন আগে দিতে হবে। জমিতে পানি থাকতে হবে।',
      ),
    ];

List<ConsultationPlan> consultationPlanSeed() => const [
      ConsultationPlan(
        id: 'plan-1',
        title: 'মাসিক পরামর্শ',
        period: 'মাস',
        price: 299,
        subscribers: 34,
        perks: [
          'মাসে ৪টি প্রশ্নের উত্তর',
          'রোগের ছবি পাঠানোর সুযোগ',
          'সাপ্তাহিক ফসল টিপস',
        ],
      ),
      ConsultationPlan(
        id: 'plan-2',
        title: 'সিজন প্যাকেজ',
        period: 'মৌসুম',
        price: 1499,
        subscribers: 12,
        perks: [
          'পুরো মৌসুমে আনলিমিটেড প্রশ্ন',
          'মাসে ১টি ভিডিও কল',
          'জমি পরিদর্শনের অগ্রাধিকার',
        ],
      ),
      ConsultationPlan(
        id: 'plan-3',
        title: 'ফার্ম প্যাকেজ',
        period: 'মাস',
        price: 999,
        subscribers: 5,
        perks: [
          'বাগান/খামারের জন্য নির্ধারিত পরামর্শ',
          'সপ্তাহে ১টি ভিডিও কল',
          'রাসায়নিক ব্যবহারের লিখিত পরামর্শ',
        ],
        active: false,
      ),
    ];

List<ConsultationBooking> consultationBookingSeed() => [
      ConsultationBooking(
        id: 'bk-1',
        farmerName: 'সেলিনা বেগম',
        topic: 'টমেটো পাতা কুঁকড়ানো',
        mode: 'video',
        at: DateTime.now().add(const Duration(hours: 3)),
        minutes: 20,
        status: 'upcoming',
      ),
      ConsultationBooking(
        id: 'bk-2',
        farmerName: 'আবু বকর সিদ্দিক',
        topic: 'বড় বাগানের রোগ প্রতিরোধ',
        mode: 'call',
        at: DateTime.now().add(const Duration(days: 1)),
        minutes: 15,
        status: 'upcoming',
      ),
      ConsultationBooking(
        id: 'bk-3',
        farmerName: 'রুবেল হোসেন',
        topic: 'আলুর জমিতে পানি নিষ্কাশন',
        mode: 'call',
        at: _daysAgo(1, hour: 15),
        minutes: 15,
        status: 'done',
      ),
    ];

List<ExpertPeer> expertPeerSeed() => const [
      ExpertPeer(
        id: 'peer-1',
        name: 'ড. ফেরদৌসী আক্তার',
        specialization: 'কীটতত্ত্ব',
        district: 'ঢাকা',
        rating: 4.9,
        followers: 1840,
        connected: true,
      ),
      ExpertPeer(
        id: 'peer-2',
        name: 'ড. আনিসুর রহমান',
        specialization: 'মৃত্তিকা ও সার',
        district: 'বগুড়া',
        rating: 4.7,
        followers: 1320,
      ),
      ExpertPeer(
        id: 'peer-3',
        name: 'কৃষিবিদ সাবিনা ইয়াসমিন',
        specialization: 'সবজি রোগ',
        district: 'রংপুর',
        rating: 4.8,
        followers: 2100,
        connected: true,
      ),
      ExpertPeer(
        id: 'peer-4',
        name: 'ড. তানভীর হাসান',
        specialization: 'ধান ও সেচ',
        district: 'সিলেট',
        rating: 4.5,
        followers: 890,
      ),
    ];

ExpertDesk expertDeskSeed() => ExpertDesk(
      articles: expertArticleSeed(),
      questions: expertQuestionSeed(),
      plans: consultationPlanSeed(),
      bookings: consultationBookingSeed(),
      peers: expertPeerSeed(),
      rating: 4.8,
      followers: 1840,
      subscribers: 51,
      earnings: 28640,
      responseMinutes: 42,
    );

/// Platform health for the admin home.
AdminOverview adminOverviewSeed(int pendingApprovals, int openIssues) {
  const values = [92000.0, 118000.0, 76000.0, 154000.0, 132000.0, 171000.0, 146000.0];
  return AdminOverview(
    gmv30: 1842500,
    commission30: 92125,
    activeUsers: 4820,
    newUsers7: 214,
    orders30: 1364,
    pendingApprovals: pendingApprovals,
    openIssues: openIssues,
    vendors: 36,
    week: [
      for (var i = 0; i < values.length; i++)
        TrendPoint(day: _daysAgo(values.length - 1 - i), value: values[i]),
    ],
  );
}

List<AdminProduct> adminProductSeed() => const [
      AdminProduct(
        id: 'adm-prd-1',
        name: 'ট্রাইসাইক্লাজল ৭৫% ডব্লিউপি',
        shopName: 'রহিম কৃষি ভান্ডার',
        category: 'fungicide',
        price: 480,
        stock: 24,
      ),
      AdminProduct(
        id: 'adm-prd-2',
        name: 'ম্যানকোজেব ৮০% ডব্লিউপি',
        shopName: 'রহিম কৃষি ভান্ডার',
        category: 'fungicide',
        price: 320,
        stock: 8,
      ),
      AdminProduct(
        id: 'adm-prd-3',
        name: 'হ্যান্ড স্প্রেয়ার ১৬ লিটার',
        shopName: 'রহিম কৃষি ভান্ডার',
        category: 'equipment',
        price: 1650,
        stock: 3,
      ),
      AdminProduct(
        id: 'adm-prd-4',
        name: 'জিংক সালফেট',
        shopName: 'রহিম কৃষি ভান্ডার',
        category: 'fertilizer',
        price: 760,
        stock: 0,
      ),
      AdminProduct(
        id: 'adm-prd-5',
        name: 'ব্রি ধান-২৮ বীজ',
        shopName: 'নতুন কৃষক ভান্ডার',
        category: 'seed',
        price: 120,
        stock: 60,
      ),
      AdminProduct(
        id: 'adm-prd-6',
        name: 'নিম তেল',
        shopName: 'সবুজ কৃষি কেন্দ্র',
        category: 'pesticide',
        price: 350,
        stock: 14,
      ),
      AdminProduct(
        id: 'adm-prd-7',
        name: 'ইউরিয়া সার (৫০ কেজি)',
        shopName: 'সবুজ কৃষি কেন্দ্র',
        category: 'fertilizer',
        price: 1350,
        stock: 22,
        hidden: true,
      ),
    ];

List<AdminContent> adminContentSeed() => [
      AdminContent(
        id: 'cnt-1',
        title: 'ধানে ব্লাস্ট প্রতিরোধে নতুন জাতের সুপারিশ',
        author: 'ড. মাহবুবুর রহমান',
        kind: 'news',
        status: 'published',
        publishedAt: _daysAgo(1, hour: 9),
      ),
      AdminContent(
        id: 'cnt-2',
        title: 'টমেটো খেতে সাদা মাছির আক্রমণ বাড়ছে',
        author: 'ড. ফেরদৌসী আক্তার',
        kind: 'news',
        status: 'published',
        publishedAt: _daysAgo(2, hour: 14),
      ),
      AdminContent(
        id: 'cnt-3',
        title: 'আলুর নাবি ধসা: কুয়াশার আগেই প্রস্তুতি',
        author: 'ড. মাহবুবুর রহমান',
        kind: 'article',
        status: 'published',
        publishedAt: _daysAgo(6, hour: 14),
      ),
      AdminContent(
        id: 'cnt-4',
        title: 'সার দেওয়ার আগে মাটি পরীক্ষা কেন জরুরি',
        author: 'ড. আনিসুর রহমান',
        kind: 'article',
        status: 'published',
        publishedAt: _daysAgo(9, hour: 11),
      ),
    ];

AdminSettings adminSettingsSeed() => const AdminSettings(
      commissionPercent: 5,
      autoApproveFarmers: false,
      maintenance: false,
      supportPhone: '09612-333444',
      broadcastBanner: '',
    );
