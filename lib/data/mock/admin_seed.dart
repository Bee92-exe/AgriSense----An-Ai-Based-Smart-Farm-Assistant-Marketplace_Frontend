/// Seed content for the admin shell (task F8): vendor approvals, users, news
/// sources, the collection schedule and log lines. Wire shape per
/// `API_SPEC.md` §9–§11.
library;

/// Vendor records the admin reviews. The first four mirror `kVendorSeed`; the
/// last two exist only here so pending/rejected/suspended states are visible.
List<Map<String, dynamic>> adminVendorSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int days) => now.subtract(Duration(days: days)).toIso8601String();

  return [
    {
      'id': 'ven-not-verified',
      'shop_name': 'নতুন কৃষক ভান্ডার',
      'owner_name': 'মোঃ শফিকুল ইসলাম',
      'owner_mobile': '01718000321',
      'district': 'নরসিংদী',
      'license_no': 'TRAD/DNCC/07841/2025',
      'status': 'pending',
      'submitted_at': ago(2),
    },
    {
      'id': 'ven-rahim',
      'shop_name': 'রহিম কৃষি ভাণ্ডার',
      'owner_name': 'রহিম মিয়া',
      'owner_mobile': '01711000002',
      'district': 'গাজীপুর',
      'license_no': 'TRAD/DNCC/01207/2023',
      'status': 'verified',
      'submitted_at': ago(240),
    },
    {
      'id': 'ven-bhumiputra',
      'shop_name': 'ভূমিপুত্র কৃষি সেবা',
      'owner_name': 'আনোয়ার হোসেন',
      'owner_mobile': '01815000674',
      'district': 'ঢাকা',
      'license_no': 'TRAD/DNCC/03318/2022',
      'status': 'verified',
      'submitted_at': ago(310),
    },
    {
      'id': 'ven-krishi-bazar',
      'shop_name': 'কৃষি বাজার এজেন্সি',
      'owner_name': 'ফরিদা ইয়াসমিন',
      'owner_mobile': '01912000417',
      'district': 'গাজীপুর',
      'license_no': 'TRAD/DNCC/05103/2024',
      'status': 'verified',
      'submitted_at': ago(180),
    },
    {
      'id': 'ven-suspended',
      'shop_name': 'মেসার্স কৃষক সহায়ক',
      'owner_name': 'দেলোয়ার হোসেন',
      'owner_mobile': '01614000982',
      'district': 'কুষ্টিয়া',
      'license_no': 'TRAD/DNCC/00914/2021',
      'status': 'suspended',
      'reason': 'মেয়াদোত্তীর্ণ ওষুধ বিক্রির অভিযোগ যাচাই হয়েছে।',
      'submitted_at': ago(400),
    },
    {
      'id': 'ven-rejected',
      'shop_name': 'শাহীন বীজ ঘর',
      'owner_name': 'শাহীন আলম',
      'owner_mobile': '01819000455',
      'district': 'পাবনা',
      'license_no': 'অনুলিপি জমা দেওয়া হয়নি',
      'status': 'rejected',
      'reason': 'ট্রেড লাইসেন্সের কপি স্পষ্ট নয়, আবার জমা দিতে বলা হয়েছে।',
      'submitted_at': ago(35),
    },
  ];
}

/// Platform users for the admin list.
List<Map<String, dynamic>> adminUserSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int days) => now.subtract(Duration(days: days)).toIso8601String();

  return [
    {
      'id': 'usr-0001',
      'name': 'আব্দুল করিম',
      'mobile': '01711000001',
      'role': 'farmer',
      'status': 'active',
      'district': 'ঢাকা',
      'joined_at': ago(210),
    },
    {
      'id': 'usr-0002',
      'name': 'রহিম মিয়া',
      'mobile': '01711000002',
      'role': 'vendor',
      'status': 'active',
      'district': 'গাজীপুর',
      'joined_at': ago(240),
    },
    {
      'id': 'usr-0003',
      'name': 'ড. মাহবুবুর রহমান',
      'mobile': '01711000003',
      'role': 'expert',
      'status': 'active',
      'district': 'ঢাকা',
      'joined_at': ago(300),
    },
    {
      'id': 'usr-0004',
      'name': 'AgriSense প্রশাসক',
      'mobile': '01711000004',
      'role': 'admin',
      'status': 'active',
      'district': 'ঢাকা',
      'joined_at': ago(320),
    },
    {
      'id': 'usr-7831',
      'name': 'কৃষিবিদ নাফিসা রহমান',
      'mobile': '01716000783',
      'role': 'expert',
      'status': 'pending',
      'district': 'বগুড়া',
      'joined_at': ago(3),
    },
    {
      'id': 'usr-9022',
      'name': 'মোঃ জসিম উদ্দিন',
      'mobile': '01913000902',
      'role': 'farmer',
      'status': 'suspended',
      'district': 'কুমিল্লা',
      'reason': 'বারবার ভুয়া পর্যালোচনা পাঠানোর অভিযোগ।',
      'joined_at': ago(120),
    },
  ];
}

/// News sources and their last collection run (API_SPEC §9/§10).
List<Map<String, dynamic>> newsSourceSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int hours) =>
      now.subtract(Duration(hours: hours)).toIso8601String();

  return [
    {
      'id': 'src-dae',
      'name': 'কৃষি সম্প্রসারণ অধিদপ্তর (DAE)',
      'url': 'https://dae.gov.bd/notice',
      'type': 'government',
      'active': true,
      'last_run_at': ago(2),
      'last_run_ok': true,
      'items_last_run': 3,
    },
    {
      'id': 'src-brri',
      'name': 'বাংলাদেশ ধান গবেষণা ইনস্টিটিউট (BRRI)',
      'url': 'https://brri.gov.bd/news',
      'type': 'research',
      'active': true,
      'last_run_at': ago(2),
      'last_run_ok': true,
      'items_last_run': 1,
    },
    {
      'id': 'src-bari',
      'name': 'বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI)',
      'url': 'https://bari.gov.bd/notice',
      'type': 'research',
      'active': true,
      'last_run_at': ago(8),
      'last_run_ok': false,
      'last_error': 'পেজটি লোড হতে ৩০ সেকেন্ডের বেশি সময় নিয়েছে।',
      'items_last_run': 0,
    },
    {
      'id': 'src-srdi',
      'name': 'মৃত্তিকা সম্পদ উন্নয়ন ইনস্টিটিউট (SRDI)',
      'url': 'https://srdi.gov.bd',
      'type': 'government',
      'active': false,
      'last_run_at': ago(96),
      'last_run_ok': true,
      'items_last_run': 0,
    },
  ];
}

/// System, collection, voice, AI-fallback and audit log lines.
List<Map<String, dynamic>> opsLogSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int minutes) =>
      now.subtract(Duration(minutes: minutes)).toIso8601String();

  return [
    {
      'id': 'log-1',
      'type': 'collection',
      'message': 'DAE সূত্র থেকে ৩টি নতুন খবর পাওয়া গেছে, ২টি যাচাইয়ের অপেক্ষায়।',
      'at': ago(18),
    },
    {
      'id': 'log-2',
      'type': 'ai_fallback',
      'message':
          'AI সেবা উত্তর দিচ্ছিল না, ২টি ছবি বিশেষজ্ঞের তালিকায় পাঠানো হয়েছে।',
      'at': ago(42),
    },
    {
      'id': 'log-3',
      'type': 'system',
      'message': 'নাইটলি ব্যাকআপ সফল হয়েছে।',
      'at': ago(90),
    },
    {
      'id': 'log-4',
      'type': 'voice',
      'message': 'রহিম মিয়া “বাজারে যাও” কমান্ডটি ব্যবহার করেছেন (৯৪% নিশ্চিত)।',
      'at': ago(120),
    },
    {
      'id': 'log-5',
      'type': 'audit',
      'message': 'অ্যাডমিন “মেসার্স কৃষক সহায়ক” বিক্রেতাকে সাসপেন্ড করেছেন।',
      'at': ago(180),
    },
    {
      'id': 'log-6',
      'type': 'collection',
      'message': 'BARI সূত্র লোড হয়নি — ৩০ সেকেন্ডের বেশি সময় লেগেছে।',
      'at': ago(240),
    },
    {
      'id': 'log-7',
      'type': 'voice',
      'message':
          '“ওই যে জিনিসটা” কমান্ডটি বোঝা যায়নি, ব্যবহারকারীকে আবার বলতে বলা হয়েছে।',
      'at': ago(300),
    },
    {
      'id': 'log-8',
      'type': 'system',
      'message': 'ডেটাবেসে ধীর কুয়েরি শনাক্ত হয়েছে (১.২ সেকেন্ড)।',
      'at': ago(420),
    },
  ];
}
