/// Phase 1 mock content.
///
/// Everything here is written in the **wire format of `API_SPEC.md`**, not as
/// hand-built model objects. Two reasons: the models' `fromJson` parsers get
/// exercised by every screen, and when the real backend arrives the mock can be
/// swapped for a Dio call without touching the seed.
///
/// Requirements this seed satisfies (SCREENS_AND_FLOWS §6): three crops with
/// Bangla disease names and treatment steps, ~20 products across three vendors
/// including one unverified, six orders in different states, eight news items
/// with two urgent, and an expert review queue.
library;

/// Soil types for the crop recommender (FR-13).
const List<String> kSoilTypes = [
  'এঁটেল মাটি', 'দোআঁশ মাটি', 'বেলে দোআঁশ', 'পলি মাটি', 'বালি মাটি', 'অম্লীয় মাটি',
];

/// Disease classes. The candidate list from `AI_SPEC.md`, which A6 says the
/// agri expert must confirm in Phase 3 — so this is deliberately easy to edit.
const List<Map<String, dynamic>> kDiseaseSeed = [
  {
    'id': 'dis-rice-blast',
    'crop': 'rice',
    'name_bn': 'ধানের ব্লাস্ট',
    'name_en': 'Rice blast',
    'is_healthy': false,
  },
  {
    'id': 'dis-rice-blb',
    'crop': 'rice',
    'name_bn': 'ধানের ব্যাকটেরিয়াল লিফ ব্লাইট',
    'name_en': 'Bacterial leaf blight',
    'is_healthy': false,
  },
  {
    'id': 'dis-rice-brown-spot',
    'crop': 'rice',
    'name_bn': 'ধানের ব্রাউন স্পট',
    'name_en': 'Brown spot',
    'is_healthy': false,
  },
  {
    'id': 'dis-rice-tungro',
    'crop': 'rice',
    'name_bn': 'ধানের টুংরো ভাইরাস',
    'name_en': 'Rice tungro virus',
    'is_healthy': false,
  },
  {
    'id': 'dis-rice-healthy',
    'crop': 'rice',
    'name_bn': 'সুস্থ ধানগাছ',
    'name_en': 'Healthy rice plant',
    'is_healthy': true,
  },
  {
    'id': 'dis-potato-late-blight',
    'crop': 'potato',
    'name_bn': 'আলুর নাবি ধসা (লেট ব্লাইট)',
    'name_en': 'Potato late blight',
    'is_healthy': false,
  },
  {
    'id': 'dis-potato-early-blight',
    'crop': 'potato',
    'name_bn': 'আলুর আগাম ধসা (আর্লি ব্লাইট)',
    'name_en': 'Potato early blight',
    'is_healthy': false,
  },
  {
    'id': 'dis-potato-healthy',
    'crop': 'potato',
    'name_bn': 'সুস্থ আলুগাছ',
    'name_en': 'Healthy potato plant',
    'is_healthy': true,
  },
  {
    'id': 'dis-tomato-late-blight',
    'crop': 'tomato',
    'name_bn': 'টমেটোর নাবি ধসা',
    'name_en': 'Tomato late blight',
    'is_healthy': false,
  },
  {
    'id': 'dis-tomato-leaf-curl',
    'crop': 'tomato',
    'name_bn': 'টমেটোর পাতা কোঁকড়ানো ভাইরাস',
    'name_en': 'Tomato leaf curl virus',
    'is_healthy': false,
  },
  {
    'id': 'dis-tomato-healthy',
    'crop': 'tomato',
    'name_bn': 'সুস্থ টমেটোগাছ',
    'name_en': 'Healthy tomato plant',
    'is_healthy': true,
  },
];

/// Treatment protocols, keyed by disease id.
///
/// Every step names its source, and the pesticide steps carry the safety line
/// the PRD requires. No dose appears here that is not attributed.
const Map<String, List<Map<String, dynamic>>> kTreatmentSeed = {
  'dis-rice-blast': [
    {
      'order': 1,
      'text_bn': 'আক্রান্ত পাতা ও গাছের অবশিষ্টাংশ জমি থেকে সরিয়ে পুড়িয়ে ফেলুন।',
      'source': 'BRRI',
    },
    {
      'order': 2,
      'text_bn': 'ইউরিয়া শেষ বারের মতো না দিয়ে সমপরিমাণ পটাশ সার দিন, এতে গাছ শক্ত হয়।',
      'source': 'BRRI',
    },
    {
      'order': 3,
      'text_bn': 'রোগ বেশি হলে ট্রাইসাইক্লাজল বা আইসোপ্রোথিওলেন গ্রুপের ছত্রাকনাশক ব্যবহার করুন।',
      'source': 'DAE',
    },
    {
      'order': 4,
      'text_bn': 'ওষুধ ছিটানোর সময় মুখে-নাকে কাপড় দিন, শেষে হাত-মুখ ধুয়ে ফেলুন।',
      'source': 'DAE',
    },
  ],
  'dis-rice-blb': [
    {
      'order': 1,
      'text_bn': 'জমিতে পানি নিষ্কাশনের ব্যবস্থা করুন, অতিরিক্ত পানি যেন না থাকে।',
      'source': 'BRRI',
    },
    {
      'order': 2,
      'text_bn': 'নাইট্রোজেন সার বেশি দেবেন না, এতে রোগ ছড়ায়।',
      'source': 'BRRI',
    },
    {
      'order': 3,
      'text_bn': 'রোগমুক্ত বীজ ব্যবহার করুন এবং পরের মৌসুমে প্রতিরোধী জাত বপন করুন।',
      'source': 'BRRI',
    },
    {
      'order': 4,
      'text_bn': 'রোগ প্রতিরোধী ধানের জাত সম্পর্কে আপনার ইউনিয়নের কৃষি কর্মকর্তার পরামর্শ নিন।',
      'source': 'DAE',
    },
  ],
  'dis-potato-late-blight': [
    {
      'order': 1,
      'text_bn': 'আক্রান্ত গাছ ও পাতা সাথে সাথে তুলে মাটির গভীরে পুঁতে ফেলুন, অন্য গাছে যেন না ছড়ায়।',
      'source': 'BARI',
    },
    {
      'order': 2,
      'text_bn': 'ঠান্ডা আর কুয়াশাচ্ছন্ন আবহাওয়ায় এই রোগ দ্রুত ছড়ায়, তাই প্রতিদিন জমি দেখুন।',
      'source': 'BARI',
    },
    {
      'order': 3,
      'text_bn': 'ম্যানকোজেব বা ক্লোরোথালোনিল গ্রুপের ছত্রাকনাশক স্প্রে করুন, ৭-১০ দিন পরপর।',
      'source': 'DAE',
    },
    {
      'order': 4,
      'text_bn': 'স্প্রে করার সময় গ্লাভস ও মাস্ক ব্যবহার করুন এবং শিশুদের দূরে রাখুন।',
      'source': 'DAE',
    },
  ],
  'dis-potato-early-blight': [
    {
      'order': 1,
      'text_bn': 'শুকনো ও আক্রান্ত পাতা জমি থেকে সরিয়ে ফেলুন।',
      'source': 'BARI',
    },
    {
      'order': 2,
      'text_bn': 'সেচ ঠিকমতো দিন, গাছ যেন শুকিয়ে না যায় — দুর্বল গাছে এই রোগ বেশি হয়।',
      'source': 'BARI',
    },
    {
      'order': 3,
      'text_bn': 'প্রয়োজনে ম্যানকোজেব গ্রুপের ছত্রাকনাশক ব্যবহার করুন।',
      'source': 'DAE',
    },
  ],
  'dis-tomato-late-blight': [
    {
      'order': 1,
      'text_bn': 'আক্রান্ত গাছ তুলে ফেলুন এবং জমি পরিষ্কার রাখুন।',
      'source': 'BARI',
    },
    {
      'order': 2,
      'text_bn': 'বাতাস চলাচল ভালো হয় এমন দূরত্বে চারা লাগান, জমিতে পানি জমতে দেবেন না।',
      'source': 'BARI',
    },
    {
      'order': 3,
      'text_bn': 'শুরুতেই ছত্রাকনাশক স্প্রে করুন, রোগ ছড়ানোর পরে কাজ কম হয়।',
      'source': 'DAE',
    },
    {
      'order': 4,
      'text_bn': 'কাটা ফসলের পরের মৌসুমে গাছ পরিবর্তন করে লাগান।',
      'source': 'BARI',
    },
  ],
  'dis-tomato-leaf-curl': [
    {
      'order': 1,
      'text_bn': 'এই রোগ সাদা মাছি থেকে ছড়ায়, তাই সাদা মাছি দমনে জৈব বালাইনাশক ব্যবহার করুন।',
      'source': 'BARI',
    },
    {
      'order': 2,
      'text_bn': 'আক্রমণ বেশি হলে গাছটি তুলে ফেলে দিন, চিকিৎসায় সারে না।',
      'source': 'BARI',
    },
    {
      'order': 3,
      'text_bn': 'জমির আশেপাশে সাদা মাছির আক্রমণকারী গাছ জন্মাতে দেবেন না।',
      'source': 'DAE',
    },
  ],
};

/// Vendors. One is intentionally unverified: nothing from it may appear in
/// Haat_Bazar or in matched products (acceptance criterion, test T-A2).
const List<Map<String, dynamic>> kVendorSeed = [
  {
    'id': 'ven-bhumiputra',
    'shop_name': 'ভূমিপুত্র কৃষি সেবা',
    'verification_status': 'verified',
    'rating': 4.6,
    'district': 'ঢাকা',
  },
  {
    'id': 'ven-krishi-bazar',
    'shop_name': 'কৃষি বাজার এজেন্সি',
    'verification_status': 'verified',
    'rating': 4.2,
    'district': 'গাজীপুর',
  },
  {
    'id': 'ven-not-verified',
    'shop_name': 'নতুন কৃষক ভান্ডার',
    'verification_status': 'pending',
    'rating': null,
    'district': 'নরসিংদী',
  },
  // The demo vendor account (`01711000002`) owns this shop, so the vendor
  // shell has stock, orders and ratings that belong to the user signed in.
  {
    'id': 'ven-rahim',
    'shop_name': 'রহিম কৃষি ভাণ্ডার',
    'verification_status': 'verified',
    'rating': 4.6,
    'district': 'গাজীপুর',
  },
];

/// Listings. `vendor.verified` is derived from [kVendorSeed] when the mock
/// repository serves them, so the unverified vendor's stock is filtered out in
/// one place.
const List<Map<String, dynamic>> kProductSeed = [
  {
    'id': 'prd-1',
    'name': 'Tricyclazole 75% WP',
    'name_bn': 'ট্রাইসাইক্লাজল ৭৫% ডব্লিউপি',
    'category': 'fungicide',
    'price': 480,
    'stock': 24,
    'description': 'ধানের ব্লাস্ট রোগ প্রতিরোধে ব্যবহৃত ছত্রাকনাশক। ১০ গ্রাম প্যাকেট সাপেক্ষে।',
    'active_ingredient': 'Tricyclazole',
    'target_diseases': ['dis-rice-blast'],
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-2',
    'name': 'Mancozeb 80% WP',
    'name_bn': 'ম্যানকোজেব ৮০% ডব্লিউপি',
    'category': 'fungicide',
    'price': 320,
    'stock': 40,
    'description': 'আলু ও টমেটোর ধসা রোগে ব্যবহৃত। ১০০ গ্রাম প্যাকেট।',
    'active_ingredient': 'Mancozeb',
    'target_diseases': [
      'dis-potato-late-blight',
      'dis-potato-early-blight',
      'dis-tomato-late-blight',
    ],
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-3',
    'name': 'Chlorothalonil 75% WP',
    'name_bn': 'ক্লোরোথালোনিল ৭৫% ডব্লিউপি',
    'category': 'fungicide',
    'price': 610,
    'stock': 12,
    'description': 'আলুর নাবি ধসা প্রতিরোধে কার্যকর ছত্রাকনাশক।',
    'active_ingredient': 'Chlorothalonil',
    'target_diseases': ['dis-potato-late-blight'],
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-4',
    'name': 'Brinjal seed',
    'name_bn': 'বেগুনের বীজ',
    'category': 'seed',
    'price': 150,
    'stock': 30,
    'description': 'উন্নত জাতের বেগুনের বীজ, ১০ গ্রাম প্যাকেট।',
    'vendor_id': 'ven-bhumiputra',
  },
  {
    'id': 'prd-5',
    'name': 'Paddy seed (BRRI dhan89)',
    'name_bn': 'ধান বীজ (ব্রি-৪৯/৮৯ জাত)',
    'category': 'seed',
    'price': 260,
    'stock': 18,
    'description': 'ব্লাস্ট প্রতিরোধী ধানের বীজ, ১ কেজি প্যাকেট।',
    'target_diseases': ['dis-rice-blast'],
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-6',
    'name': 'Potato seed (Diamant)',
    'name_bn': 'আলুর বীজ (ডায়মন্ড জাত)',
    'category': 'seed',
    'price': 1200,
    'stock': 8,
    'description': 'রোপণের জন্য প্রত্যয়িত বীজ আলু, ৫০ কেজি বস্তা।',
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-7',
    'name': 'Tomato seed (BARI-14)',
    'name_bn': 'টমেটোর বীজ (বারি-১৪)',
    'category': 'seed',
    'price': 340,
    'stock': 22,
    'description': 'রোগ সহনশীল টমেটোর বীজ, ৫ গ্রাম প্যাকেট।',
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-8',
    'name': 'Muriate of Potash (MOP)',
    'name_bn': 'মিউরেট অব পটাশ (এমওপি)',
    'category': 'fertilizer',
    'price': 850,
    'stock': 15,
    'description': 'পটাশ সার, ৫০ কেজি বস্তা। গাছ শক্ত করতে সহায়ক।',
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-9',
    'name': 'Urea',
    'name_bn': 'ইউরিয়া সার',
    'category': 'fertilizer',
    'price': 1250,
    'stock': 35,
    'description': 'নাইট্রোজেন সার, ৫০ কেজি বস্তা।',
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-10',
    'name': 'TSP fertilizer',
    'name_bn': 'টিএসপি সার',
    'category': 'fertilizer',
    'price': 1100,
    'stock': 20,
    'description': 'ফসফেট সার, ৫০ কেজি বস্তা।',
    'vendor_id': 'ven-bhumiputra',
  },
  {
    'id': 'prd-11',
    'name': 'Organic compost',
    'name_bn': 'জৈব কম্পোস্ট সার',
    'category': 'fertilizer',
    'price': 400,
    'stock': 50,
    'description': 'পচা গোবর ও আবর্জনা থেকে তৈরি জৈব সার, ৪০ কেজি বস্তা।',
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-12',
    'name': 'Imidacloprid',
    'name_bn': 'ইমিডাক্লোপ্রিড',
    'category': 'pesticide',
    'price': 380,
    'stock': 16,
    'description': 'সাদা মাছি ও পোকার দমননাশক।',
    'active_ingredient': 'Imidacloprid',
    'target_diseases': ['dis-tomato-leaf-curl'],
    'vendor_id': 'ven-bhumiputra',
  },
  {
    'id': 'prd-13',
    'name': 'Neem oil spray',
    'name_bn': 'নিম তেল স্প্রে',
    'category': 'pesticide',
    'price': 290,
    'stock': 27,
    'description': 'জৈব বালাইনাশক, সাদা মাছির আক্রমণ কমায়।',
    'target_diseases': ['dis-tomato-leaf-curl'],
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-14',
    'name': 'Pheromone trap',
    'name_bn': 'ফেরোমন ফাঁদ',
    'category': 'pesticide',
    'price': 220,
    'stock': 34,
    'description': 'পোকা ধরার ফাঁদ, কীটপতঙ্গ দমনে সহায়ক।',
    'vendor_id': 'ven-bhumiputra',
  },
  {
    'id': 'prd-15',
    'name': 'Hand sprayer 16L',
    'name_bn': 'হ্যান্ড স্প্রেয়ার ১৬ লিটার',
    'category': 'equipment',
    'price': 1650,
    'stock': 6,
    'description': 'পিঠে নেওয়া স্প্রেয়ার মেশিন, ১৬ লিটার ধারণক্ষম।',
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-16',
    'name': 'Potassium sulphate',
    'name_bn': 'পটাশিয়াম সালফেট',
    'category': 'fertilizer',
    'price': 980,
    'stock': 0,
    'description': 'সালফেট অব পটাশ সার, ৫০ কেজি বস্তা।',
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-17',
    'name': 'Zinc sulphate',
    'name_bn': 'জিংক সালফেট',
    'category': 'fertilizer',
    'price': 760,
    'stock': 11,
    'description': 'দস্তা সার, ধানে দস্তার অভাব পূরণ করে, ৫ কেজি প্যাকেট।',
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-18',
    'name': 'Hexaconazole 5% SC',
    'name_bn': 'হেক্সাকোনাজল ৫% এসসি',
    'category': 'fungicide',
    'price': 540,
    'stock': 9,
    'description': 'ছত্রাকজনিত রোগে ব্যবহৃত, ১০০ মিলি বোতল।',
    'active_ingredient': 'Hexaconazole',
    'target_diseases': ['dis-rice-blast', 'dis-rice-brown-spot'],
    'vendor_id': 'ven-rahim',
  },
  {
    'id': 'prd-19',
    'name': 'Copper oxychloride',
    'name_bn': 'কপার অক্সিক্লোরাইড',
    'category': 'fungicide',
    'price': 430,
    'stock': 14,
    'description': 'ব্যাকটেরিয়া ও ছত্রাক উভয় রোগে ব্যবহৃত।',
    'active_ingredient': 'Copper oxychloride',
    'target_diseases': ['dis-rice-blb'],
    'vendor_id': 'ven-krishi-bazar',
  },
  {
    'id': 'prd-20',
    'name': 'Sprayer nozzle set',
    'name_bn': 'স্প্রেয়ার নোজেল সেট',
    'category': 'equipment',
    'price': 180,
    'stock': 42,
    'description': 'স্প্রে মেশিনের নোজেল সেট, চারটি সাইজ।',
    'vendor_id': 'ven-rahim',
  },
  // Belongs to the unverified vendor. The mock repository must never return it.
  {
    'id': 'prd-hidden',
    'name': 'Unverified shop fungicide',
    'name_bn': 'যাচাই না হওয়া দোকানের ছত্রাকনাশক',
    'category': 'fungicide',
    'price': 200,
    'stock': 99,
    'description': 'এই পণ্যটি যাচাইকৃত নয়, তাই হাট বাজারে দেখানো উচিত নয়।',
    'vendor_id': 'ven-not-verified',
  },
];

/// Diagnosis history. Three confidence bands plus a pending-review case, so
/// every result state the design system specifies can be seen without editing
/// code.
List<Map<String, dynamic>> diagnosisSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int days, [int hours = 0]) =>
      now.subtract(Duration(days: days, hours: hours)).toIso8601String();

  return [
    {
      'id': 'dx-1',
      'client_uuid': '11111111-1111-4111-8111-111111111111',
      'crop': 'rice',
      'status': 'completed',
      'disease': kDiseaseSeed[0],
      'confidence': 0.91,
      'confidence_level': 'high',
      'top3': [
        {'disease_id': 'dis-rice-blast', 'name_bn': 'ধানের ব্লাস্ট', 'name_en': 'Rice blast', 'confidence': 0.91},
        {'disease_id': 'dis-rice-brown-spot', 'name_bn': 'ধানের ব্রাউন স্পট', 'name_en': 'Brown spot', 'confidence': 0.05},
        {'disease_id': 'dis-rice-blb', 'name_bn': 'ধানের ব্যাকটেরিয়াল লিফ ব্লাইট', 'name_en': 'Bacterial leaf blight', 'confidence': 0.04},
      ],
      'treatment_steps': kTreatmentSeed['dis-rice-blast'],
      'show_as_final': true,
      'reviewed_by_expert': false,
      'created_at': ago(2),
    },
    {
      'id': 'dx-2',
      'client_uuid': '22222222-2222-4222-8222-222222222222',
      'crop': 'potato',
      'status': 'completed',
      'disease': kDiseaseSeed[5],
      'confidence': 0.78,
      'confidence_level': 'medium',
      'top3': [
        {'disease_id': 'dis-potato-late-blight', 'name_bn': 'আলুর নাবি ধসা (লেট ব্লাইট)', 'name_en': 'Potato late blight', 'confidence': 0.78},
        {'disease_id': 'dis-potato-early-blight', 'name_bn': 'আলুর আগাম ধসা (আর্লি ব্লাইট)', 'name_en': 'Potato early blight', 'confidence': 0.17},
      ],
      'treatment_steps': kTreatmentSeed['dis-potato-late-blight'],
      'show_as_final': true,
      'reviewed_by_expert': false,
      'created_at': ago(5),
    },
    {
      // Below 0.70: no disease name, no treatment, nothing shown as final.
      'id': 'dx-3',
      'client_uuid': '33333333-3333-4333-8333-333333333333',
      'crop': 'tomato',
      'status': 'pending_review',
      'disease': null,
      'confidence': 0.62,
      'confidence_level': 'low',
      'top3': [],
      'treatment_steps': null,
      'show_as_final': false,
      'reviewed_by_expert': false,
      'created_at': ago(9),
    },
    {
      'id': 'dx-4',
      'client_uuid': '44444444-4444-4444-8444-444444444444',
      'crop': 'rice',
      'status': 'expert_reviewed',
      'disease': kDiseaseSeed[3],
      'confidence': 0.74,
      'confidence_level': 'medium',
      'top3': [
        {'disease_id': 'dis-rice-tungro', 'name_bn': 'ধানের টুংরো ভাইরাস', 'name_en': 'Rice tungro virus', 'confidence': 0.74},
      ],
      'treatment_steps': kTreatmentSeed['dis-rice-blast'],
      'show_as_final': true,
      'reviewed_by_expert': true,
      'expert_note': 'টুংরো ভাইরাস নিশ্চিত। আক্রান্ত গাছ তুলে ফেলুন এবং সবুজ পাতা ফড়িং দমন করুন।',
      'created_at': ago(16),
    },
    {
      'id': 'dx-5',
      'client_uuid': '55555555-5555-4555-8555-555555555555',
      'crop': 'rice',
      'status': 'completed',
      'disease': kDiseaseSeed[4],
      'confidence': 0.96,
      'confidence_level': 'high',
      'top3': [
        {'disease_id': 'dis-rice-healthy', 'name_bn': 'সুস্থ ধানগাছ', 'name_en': 'Healthy rice plant', 'confidence': 0.96},
      ],
      'treatment_steps': null,
      'show_as_final': true,
      'reviewed_by_expert': false,
      'created_at': ago(21),
    },
  ];
}

/// Orders across every state a farmer can see.
List<Map<String, dynamic>> orderSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int days) => now.subtract(Duration(days: days)).toIso8601String();
  String hoursAgo(int hours) =>
      now.subtract(Duration(hours: hours)).toIso8601String();

  Map<String, dynamic> v(int i) => {
        'id': kVendorSeed[i]['id'],
        'shop_name': kVendorSeed[i]['shop_name'],
        'verified': kVendorSeed[i]['verification_status'] == 'verified',
        'rating': kVendorSeed[i]['rating'],
      };

  return [
    {
      'id': 'ord-1',
      'order_no': 'AS-2026-000145',
      'status': 'pending',
      'display_status': 'pending',
      'payment_mode': 'cod',
      'placed_via': 'touch',
      'total_amount': 960,
      'items': [
        {'product_id': 'prd-1', 'name': 'ট্রাইসাইক্লাজল ৭৫% ডব্লিউপি', 'quantity': 2, 'unit_price': 480, 'subtotal': 960},
      ],
      'vendor': v(3),
      'history': [
        {'status': 'pending', 'at': hoursAgo(2)},
      ],
      'created_at': hoursAgo(2),
    },
    {
      'id': 'ord-2',
      'order_no': 'AS-2026-000131',
      'status': 'confirmed',
      'display_status': 'pending',
      'payment_mode': 'cod',
      'placed_via': 'voice',
      'total_amount': 320,
      'items': [
        {'product_id': 'prd-2', 'name': 'ম্যানকোজেব ৮০% ডব্লিউপি', 'quantity': 1, 'unit_price': 320, 'subtotal': 320},
      ],
      'vendor': v(3),
      'history': [
        {'status': 'pending', 'at': ago(3)},
        {'status': 'confirmed', 'at': ago(3)},
      ],
      'created_at': ago(3),
    },
    {
      'id': 'ord-3',
      'order_no': 'AS-2026-000118',
      'status': 'shipped',
      'display_status': 'shipped',
      'payment_mode': 'cod',
      'placed_via': 'touch',
      'total_amount': 2410,
      'items': [
        {'product_id': 'prd-15', 'name': 'হ্যান্ড স্প্রেয়ার ১৬ লিটার', 'quantity': 1, 'unit_price': 1650, 'subtotal': 1650},
        {'product_id': 'prd-17', 'name': 'জিংক সালফেট', 'quantity': 1, 'unit_price': 760, 'subtotal': 760},
      ],
      'vendor': v(1),
      'history': [
        {'status': 'pending', 'at': ago(7)},
        {'status': 'confirmed', 'at': ago(6)},
        {'status': 'shipped', 'at': ago(4)},
      ],
      'created_at': ago(7),
    },
    {
      'id': 'ord-4',
      'order_no': 'AS-2026-000097',
      'status': 'delivered',
      'display_status': 'delivered',
      'payment_mode': 'cod',
      'placed_via': 'touch',
      'total_amount': 1250,
      'items': [
        {'product_id': 'prd-9', 'name': 'ইউরিয়া সার', 'quantity': 1, 'unit_price': 1250, 'subtotal': 1250},
      ],
      'vendor': v(1),
      'history': [
        {'status': 'pending', 'at': ago(14)},
        {'status': 'confirmed', 'at': ago(13)},
        {'status': 'shipped', 'at': ago(12)},
        {'status': 'delivered', 'at': ago(10)},
      ],
      'created_at': ago(14),
    },
    {
      'id': 'ord-5',
      'order_no': 'AS-2026-000076',
      'status': 'rejected',
      'display_status': 'rejected',
      'payment_mode': 'cod',
      'placed_via': 'touch',
      'total_amount': 1200,
      'items': [
        {'product_id': 'prd-6', 'name': 'আলুর বীজ (ডায়মন্ড জাত)', 'quantity': 1, 'unit_price': 1200, 'subtotal': 1200},
      ],
      'vendor': v(3),
      'history': [
        {'status': 'pending', 'at': ago(20)},
        {'status': 'rejected', 'at': ago(19)},
      ],
      'created_at': ago(20),
    },
    {
      'id': 'ord-6',
      'order_no': 'AS-2026-000062',
      'status': 'cancelled',
      'display_status': 'cancelled',
      'payment_mode': 'direct',
      'placed_via': 'voice',
      'total_amount': 290,
      'items': [
        {'product_id': 'prd-13', 'name': 'নিম তেল স্প্রে', 'quantity': 1, 'unit_price': 290, 'subtotal': 290},
      ],
      'vendor': v(1),
      'history': [
        {'status': 'pending', 'at': ago(26)},
        {'status': 'cancelled', 'at': ago(26)},
      ],
      'created_at': ago(26),
    },
    {
      'id': 'ord-7',
      'order_no': 'AS-2026-000151',
      'status': 'shipped',
      'display_status': 'shipped',
      'payment_mode': 'cod',
      'placed_via': 'touch',
      'total_amount': 720,
      'items': [
        {'product_id': 'prd-18', 'name': 'হেক্সাকোনাজল ৫% এসসি', 'quantity': 1, 'unit_price': 540, 'subtotal': 540},
        {'product_id': 'prd-20', 'name': 'স্প্রেয়ার নোজেল সেট', 'quantity': 1, 'unit_price': 180, 'subtotal': 180},
      ],
      'vendor': v(3),
      'history': [
        {'status': 'pending', 'at': ago(4)},
        {'status': 'confirmed', 'at': ago(4)},
        {'status': 'shipped', 'at': ago(2)},
      ],
      'created_at': ago(4),
    },
    {
      'id': 'ord-8',
      'order_no': 'AS-2026-000142',
      'status': 'delivered',
      'display_status': 'delivered',
      'payment_mode': 'cod',
      'placed_via': 'voice',
      'total_amount': 850,
      'items': [
        {'product_id': 'prd-8', 'name': 'মিউরেট অব পটাশ (এমওপি)', 'quantity': 1, 'unit_price': 850, 'subtotal': 850},
      ],
      'vendor': v(3),
      'history': [
        {'status': 'pending', 'at': ago(9)},
        {'status': 'confirmed', 'at': ago(9)},
        {'status': 'shipped', 'at': ago(7)},
        {'status': 'delivered', 'at': ago(5)},
      ],
      'created_at': ago(9),
    },
  ];
}

/// Buyer details for each seeded order.
///
/// Only the vendor involved in an order may see these (API_SPEC §6/§7); the
/// vendor screens read them from here, the farmer's own order screens never do.
const Map<String, Map<String, dynamic>> kOrderBuyerSeed = {
  'ord-1': {
    'name': 'সেলিনা বেগম',
    'mobile': '01712000451',
    'district': 'টাঙ্গাইল',
    'note': 'বিকেল ৪টার পরে ফোন করবেন।',
  },
  'ord-2': {
    'name': 'মোঃ হাসান আলী',
    'mobile': '01715000933',
    'district': 'কিশোরগঞ্জ',
    'note': '',
  },
  'ord-3': {
    'name': 'আবু বকর সিদ্দিক',
    'mobile': '01819000712',
    'district': 'চট্টগ্রাম',
    'note': 'গ্রামের বাজার, মসজিদের পাশে।',
  },
  'ord-4': {
    'name': 'রুবেল হোসেন',
    'mobile': '01913000488',
    'district': 'ময়মনসিংহ',
    'note': '',
  },
  'ord-5': {
    'name': 'শাহানারা খাতুন',
    'mobile': '01614000291',
    'district': 'রংপুর',
    'note': 'বীজের প্যাকেট ফাটা যেন না হয়।',
  },
  'ord-6': {
    'name': 'জাহিদুল ইসলাম',
    'mobile': '01717000654',
    'district': 'বরিশাল',
    'note': '',
  },
  'ord-7': {
    'name': 'নাসরিন আক্তার',
    'mobile': '01816000540',
    'district': 'গাজীপুর',
    'note': 'বাড়ির পাশে দোকানে রেখে যাবেন।',
  },
  'ord-8': {
    'name': 'আব্দুল করিম',
    'mobile': '01711000001',
    'district': 'ঢাকা',
    'note': '',
  },
};

/// Ratings a vendor sees read-only (SCREENS_AND_FLOWS §2).
const List<Map<String, dynamic>> kVendorRatingSeed = [
  {
    'rating': 5,
    'comment': 'ওষুধ ঠিক সময়ে পেয়েছি, দামও ঠিক ছিল।',
    'farmer_name': 'সেলিনা বেগম',
    'vendor_id': 'ven-rahim',
    'days_ago': 6,
  },
  {
    'rating': 4,
    'comment': 'পণ্য ভালো, তবে ডেলিভারিতে এক দিন দেরি হয়েছে।',
    'farmer_name': 'মোঃ হাসান আলী',
    'vendor_id': 'ven-rahim',
    'days_ago': 12,
  },
  {
    'rating': 5,
    'comment': 'বীজের অঙ্কুর ভালো হয়েছে।',
    'farmer_name': 'আব্দুল করিম',
    'vendor_id': 'ven-rahim',
    'days_ago': 21,
  },
];

/// Krishi Barta. Eight items, two urgent, across all four categories.
List<Map<String, dynamic>> newsSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int hours) => now.subtract(Duration(hours: hours)).toIso8601String();

  Map<String, dynamic> src(String name, String url) => {'name': name, 'url': url};

  return [
    {
      'id': 'news-1',
      'title_bn': 'সতর্কতা: উত্তরাঞ্চলে আলুর নাবি ধসা দ্রুত ছড়াচ্ছে',
      'title_en': 'Alert: potato late blight spreading fast in the north',
      'summary_bn': 'ঠান্ডা আর কুয়াশাচ্ছন্ন আবহাওয়ার কারণে রংপুর ও দিনাজপুরে আলুর নাবি ধসা দ্রুত ছড়াচ্ছে। আক্রান্ত গাছ সাথে সাথে তুলে ফেলার পরামর্শ দিয়েছে কৃষি সম্প্রসারণ অধিদপ্তর।',
      'symptoms_bn': 'পাতার কিনারায় পানি ভেজা দাগ, পরে সাদা ছত্রাকের আস্তরণ; গোটা গাছ কয়েক দিনেই কালো হয়ে শুকিয়ে যায়।',
      'advised_action_bn': 'প্রতিদিন জমি পরিদর্শন করুন, আক্রান্ত গাছ তুলে মাটির গভীরে পুঁতে ফেলুন এবং ছত্রাকনাশক স্প্রে করুন।',
      'category': 'disease',
      'crop': 'potato',
      'severity': 'urgent',
      'affected_districts': ['রংপুর', 'দিনাজপুর', 'বগুড়া'],
      'source': src('কৃষি সম্প্রসারণ অধিদপ্তর (DAE)', 'https://dae.gov.bd'),
      'verified_by': 'ড. মাহবুবুর রহমান',
      'published_at': ago(5),
      'is_urgent': true,
      'read': false,
      'images': [],
    },
    {
      'id': 'news-2',
      'title_bn': 'ধানে ব্লাস্ট প্রতিরোধে নতুন জাতের সুপারিশ',
      'title_en': 'New rice varieties recommended against blast',
      'summary_bn': 'বাংলাদেশ ধান গবেষণা ইনস্টিটিউট ব্লাস্ট প্রতিরোধী দুটি নতুন ধানের জাত সুপারিশ করেছে, যা চলতি মৌসুমে চাষ করা যাবে।',
      'symptoms_bn': null,
      'advised_action_bn': 'রোগ প্রতিরোধী জাতের বীজ ব্যবহার করুন এবং ইউরিয়া সারের শেষ কিস্তি কমিয়ে দিন।',
      'category': 'disease',
      'crop': 'rice',
      'severity': 'medium',
      'affected_districts': ['সিলেট', 'মৌলভীবাজার'],
      'source': src('বাংলাদেশ ধান গবেষণা ইনস্টিটিউট (BRRI)', 'https://brri.gov.bd'),
      'verified_by': 'কৃষিবিদ রুবিনা আক্তার',
      'published_at': ago(20),
      'is_urgent': false,
      'read': false,
      'images': [],
    },
    {
      'id': 'news-3',
      'title_bn': 'সাদা মাছির আক্রমণ বাড়ছে টমেটো খেতে',
      'title_en': 'Whitefly attack rising in tomato fields',
      'summary_bn': 'কুমিল্লা ও নোয়াখালীর টমেটো খেতে সাদা মাছির আক্রমণ বেড়েছে, যা থেকে পাতা কোঁকড়ানো ভাইরাস ছড়ায়। জৈব বালাইনাশক ব্যবহারের পরামর্শ দেওয়া হয়েছে।',
      'symptoms_bn': 'পাতা কুঁকড়ে যাওয়া, গাছ খাটো হয়ে যাওয়া এবং পাতার নিচে ছোট সাদা পোকা।',
      'advised_action_bn': 'আক্রান্ত গাছ তুলে ফেলুন এবং নিম তেল বা অনুমোদিত বালাইনাশক স্প্রে করুন।',
      'category': 'pest',
      'crop': 'tomato',
      'severity': 'high',
      'affected_districts': ['কুমিল্লা', 'নোয়াখালী', 'ফেনী'],
      'source': src('বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI)', 'https://bari.gov.bd'),
      'verified_by': 'ড. মাহবুবুর রহমান',
      'published_at': ago(30),
      'is_urgent': false,
      'read': false,
      'images': [],
    },
    {
      'id': 'news-4',
      'title_bn': 'জরুরি: উপকূলীয় জেলায় লবণাক্ততা বাড়ছে',
      'title_en': 'Urgent: salinity rising in coastal districts',
      'summary_bn': 'সাতক্ষীরা ও পটুয়াখালীতে জমির লবণাক্ততা অস্বাভাবিকভাবে বেড়েছে। ধান ও সবজিতে এর প্রভাব পড়তে পারে বলে জানিয়েছে এসআরডিআই।',
      'symptoms_bn': null,
      'advised_action_bn': 'লবণাক্ততা সহনশীল জাত বেছে নিন এবং মাটি পরীক্ষা করিয়ে নিন।',
      'category': 'nutrient_deficiency',
      'crop': 'rice',
      'severity': 'urgent',
      'affected_districts': ['সাতক্ষীরা', 'পটুয়াখালী', 'খুলনা'],
      'source': src('মৃত্তিকা সম্পদ উন্নয়ন ইনস্টিটিউট (SRDI)', 'https://srdi.gov.bd'),
      'verified_by': 'কৃষিবিদ রুবিনা আক্তার',
      'published_at': ago(48),
      'is_urgent': true,
      'read': false,
      'images': [],
    },
    {
      'id': 'news-5',
      'title_bn': 'ধানে দস্তার অভাব দেখা দিচ্ছে',
      'title_en': 'Zinc deficiency appearing in paddy',
      'summary_bn': 'কিছু এলাকায় ধানের পাতায় বাদামি দাগ ও গাছ খাটো হয়ে যাওয়ার খবর পাওয়া গেছে, যা দস্তার অভাবের লক্ষণ।',
      'symptoms_bn': 'কচি পাতার গোড়ায় বাদামি দাগ, গাছ বাড়তে না চাওয়া।',
      'advised_action_bn': 'জিংক সালফেট সার প্রয়োগ করুন এবং কৃষি কর্মকর্তার পরামর্শ নিন।',
      'category': 'nutrient_deficiency',
      'crop': 'rice',
      'severity': 'low',
      'affected_districts': ['ময়মনসিংহ', 'জামালপুর'],
      'source': src('বাংলাদেশ ধান গবেষণা ইনস্টিটিউট (BRRI)', 'https://brri.gov.bd'),
      'verified_by': 'ড. মাহবুবুর রহমান',
      'published_at': ago(70),
      'is_urgent': false,
      'read': true,
      'images': [],
    },
    {
      'id': 'news-6',
      'title_bn': 'পোকার আক্রমণ কমাতে ফেরোমন ফাঁদ',
      'title_en': 'Pheromone traps to cut pest attack',
      'summary_bn': 'রাসায়নিক ব্যবহার কমাতে ফেরোমন ফাঁদ ব্যবহারের পরামর্শ দিয়েছে কৃষি সম্প্রসারণ অধিদপ্তর। প্রতি বিঘায় দুটি ফাঁদ যথেষ্ট।',
      'symptoms_bn': null,
      'advised_action_bn': 'প্রতি বিঘায় দুটি ফেরোমন ফাঁদ বসান এবং নিয়মিত পরীক্ষা করুন।',
      'category': 'pest',
      'crop': 'tomato',
      'severity': 'low',
      'affected_districts': ['ঢাকা', 'গাজীপুর'],
      'source': src('কৃষি সম্প্রসারণ অধিদপ্তর (DAE)', 'https://dae.gov.bd'),
      'verified_by': 'কৃষিবিদ রুবিনা আক্তার',
      'published_at': ago(96),
      'is_urgent': false,
      'read': true,
      'images': [],
    },
    {
      'id': 'news-7',
      'title_bn': 'টমেটোতে ভাইরাস প্রতিরোধে বীজ শোধন',
      'title_en': 'Seed treatment to prevent tomato virus',
      'summary_bn': 'রোপণের আগে বীজ শোধন করলে টমেটোর ভাইরাসজনিত রোগ অনেক কম হয় বলে জানিয়েছে বারি।',
      'symptoms_bn': null,
      'advised_action_bn': 'বপন বা রোপণের আগে অনুমোদিত পদ্ধতিতে বীজ শোধন করুন।',
      'category': 'virus',
      'crop': 'tomato',
      'severity': 'medium',
      'affected_districts': ['রাজশাহী', 'নাটোর'],
      'source': src('বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI)', 'https://bari.gov.bd'),
      'verified_by': 'ড. মাহবুবুর রহমান',
      'published_at': ago(120),
      'is_urgent': false,
      'read': false,
      'images': [],
    },
    {
      'id': 'news-8',
      'title_bn': 'আলুতে আগাম ধসা দেখা দিতে পারে',
      'title_en': 'Early blight may appear in potato',
      'summary_bn': 'কুয়াশা কমে গিয়ে গরম বাড়লে আলুতে আগাম ধসা দেখা দিতে পারে। সেচ ঠিক রাখার পরামর্শ দেওয়া হয়েছে।',
      'symptoms_bn': 'নিচের দিকের পুরোনো পাতায় গাঢ় বাদামি বৃত্তাকার দাগ।',
      'advised_action_bn': 'সেচ ও পুষ্টি ঠিক রাখুন; দাগ দেখা দিলে ছত্রাকনাশক ব্যবহার করুন।',
      'category': 'disease',
      'crop': 'potato',
      'severity': 'medium',
      'affected_districts': ['বগুড়া', 'রাজশাহী', 'পাবনা'],
      'source': src('বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI)', 'https://bari.gov.bd'),
      'verified_by': 'কৃষিবিদ রুবিনা আক্তার',
      'published_at': ago(150),
      'is_urgent': false,
      'read': false,
      'images': [],
    },
  ];
}

/// Weather for the farmer's district, including one active alert so the alert
/// path is visible without faking a failure.
Map<String, dynamic> weatherSeed(String nowIso, String district) {
  final now = DateTime.parse(nowIso);
  String day(int offset) =>
      now.add(Duration(days: offset)).toIso8601String().substring(0, 10);

  return {
    'district': district,
    'current': {
      'temp_c': 31.5,
      'condition': 'আংশিক মেঘলা',
      'humidity': 74,
      'wind_kph': 12.5,
      'icon': 'partly_cloudy',
    },
    'forecast': [
      {'date': day(1), 'min_c': 24.0, 'max_c': 33.0, 'condition': 'রোদ', 'rain_mm': 0.0, 'icon': 'sunny'},
      {'date': day(2), 'min_c': 25.0, 'max_c': 32.0, 'condition': 'মেঘলা', 'rain_mm': 1.2, 'icon': 'cloudy'},
      {'date': day(3), 'min_c': 23.5, 'max_c': 29.0, 'condition': 'ভারী বৃষ্টি', 'rain_mm': 42.5, 'icon': 'rainy'},
      {'date': day(4), 'min_c': 23.0, 'max_c': 28.5, 'condition': 'বৃষ্টি', 'rain_mm': 18.0, 'icon': 'rainy'},
      {'date': day(5), 'min_c': 24.5, 'max_c': 31.0, 'condition': 'আংশিক মেঘলা', 'rain_mm': 2.0, 'icon': 'partly_cloudy'},
    ],
    'alerts': [
      {
        'id': 'alert-1',
        'type': 'heavy_rain',
        'message_bn': 'আগামী ৩ দিন ভারী বৃষ্টির সম্ভাবনা। ধান কাটার কাজ এখনই সেরে ফেলুন এবং জমিতে পানি নিষ্কাশনের ব্যবস্থা রাখুন।',
        'created_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
      },
    ],
    'updated_at': now.subtract(const Duration(minutes: 25)).toIso8601String(),
  };
}

/// The expert review queue (SCREENS_AND_FLOWS §6 asks for five cases).
List<Map<String, dynamic>> expertQueueSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int hours) => now.subtract(Duration(hours: hours)).toIso8601String();

  Map<String, dynamic> caseItem(
    String id,
    String crop,
    double confidence,
    int hours,
    String? aiGuessBn,
  ) =>
      {
        'id': id,
        'crop': crop,
        'confidence': confidence,
        'confidence_level': 'low',
        'ai_guess_bn': aiGuessBn,
        'created_at': ago(hours),
        'status': 'pending',
      };

  return [
    caseItem('rev-1', 'tomato', 0.62, 9, 'টমেটোর নাবি ধসা'),
    caseItem('rev-2', 'rice', 0.58, 14, 'ধানের ব্রাউন স্পট'),
    caseItem('rev-3', 'potato', 0.66, 22, 'আলুর আগাম ধসা'),
    caseItem('rev-4', 'rice', 0.41, 30, null),
    caseItem('rev-5', 'tomato', 0.69, 40, 'টমেটোর পাতা কোঁকড়ানো ভাইরাস'),
  ];
}

/// Treatment-to-product matching table (FR-16), used when the mock cannot score
/// by itself.
const Map<String, List<String>> kDiseaseProductMap = {
  'dis-rice-blast': ['prd-1', 'prd-18', 'prd-5'],
  'dis-rice-blb': ['prd-19'],
  'dis-rice-brown-spot': ['prd-18'],
  'dis-rice-tungro': ['prd-12', 'prd-14'],
  'dis-potato-late-blight': ['prd-2', 'prd-3'],
  'dis-potato-early-blight': ['prd-2'],
  'dis-tomato-late-blight': ['prd-2', 'prd-3'],
  'dis-tomato-leaf-curl': ['prd-13', 'prd-12', 'prd-14'],
};

/// Voice command scripts, including the failure cases the state machine must
/// handle (VOICE_UX §4 and §8). Used by the mock voice repository.
const List<Map<String, dynamic>> kVoiceScriptSeed = [
  {'transcript': 'বাজারে যাও', 'intent': 'navigate', 'screen': 'haat_bazar', 'confidence': 0.94},
  {'transcript': 'আজকের আবহাওয়া কেমন?', 'intent': 'get_weather', 'confidence': 0.92},
  {'transcript': 'ছত্রাকনাশক দেখাও', 'intent': 'search_product', 'confidence': 0.88},
  {'transcript': 'এই কীটনাশকটা অর্ডার করো', 'intent': 'order_product', 'confidence': 0.90},
  {'transcript': 'কৃষি বার্তা খোলো', 'intent': 'navigate', 'screen': 'krishi_barta', 'confidence': 0.91},
  {'transcript': 'ফসল দেখাও', 'intent': 'navigate', 'screen': 'diagnosis', 'confidence': 0.93},
  {'transcript': 'ধানে পাতা পোড়া রোগে কী করব?', 'intent': 'ask', 'confidence': 0.87},
  // Failure cases: low confidence must clarify, unknown must refuse.
  {'transcript': 'ওই যে জিনিসটা', 'intent': 'unknown', 'confidence': 0.35},
  {'transcript': 'গান চালাও', 'intent': 'unknown', 'confidence': 0.80},
  {'transcript': 'আমার অ্যাকাউন্ট মুছে দাও', 'intent': 'unknown', 'confidence': 0.86},
];
