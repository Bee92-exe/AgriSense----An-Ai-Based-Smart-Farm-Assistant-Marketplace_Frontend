/// Seed content for the vendor, expert and admin shells (task F8).
///
/// Same rule as `mock_seed.dart`: every entry is written in the wire shape of
/// `API_SPEC.md` so the model parsers are exercised by the staff screens too.
library;

import 'mock_seed.dart';

/// Expert review queue.
///
/// A case is a diagnosis below the 0.70 confidence floor that the farmer sent
/// on (or that the server auto-queued). The AI guess is visible to the expert
/// only — never to the farmer — which is why it lives here and not on the
/// farmer-facing diagnosis.
List<Map<String, dynamic>> expertReviewSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int hours) =>
      now.subtract(Duration(hours: hours)).toIso8601String();

  Map<String, dynamic> guess(String id, double confidence) {
    final d = kDiseaseSeed.firstWhere((e) => e['id'] == id);
    return {
      'disease_id': d['id'],
      'name_bn': d['name_bn'],
      'name_en': d['name_en'],
      'confidence': confidence,
    };
  }

  return [
    {
      'id': 'rev-1',
      'diagnosis_id': 'dx-3',
      'farmer_name': 'সেলিনা বেগম',
      'farmer_district': 'টাঙ্গাইল',
      'crop': 'tomato',
      'confidence': 0.62,
      'created_at': ago(9),
      'status': 'pending',
      'ai_top3': [
        guess('dis-tomato-late-blight', 0.62),
        guess('dis-tomato-leaf-curl', 0.24),
      ],
    },
    {
      'id': 'rev-2',
      'farmer_name': 'মোঃ হাসান আলী',
      'farmer_district': 'কিশোরগঞ্জ',
      'crop': 'rice',
      'confidence': 0.58,
      'created_at': ago(14),
      'status': 'pending',
      'ai_top3': [
        guess('dis-rice-brown-spot', 0.58),
        guess('dis-rice-blast', 0.31),
      ],
    },
    {
      'id': 'rev-3',
      'farmer_name': 'শাহানারা খাতুন',
      'farmer_district': 'রংপুর',
      'crop': 'potato',
      'confidence': 0.66,
      'created_at': ago(22),
      'status': 'pending',
      'ai_top3': [
        guess('dis-potato-early-blight', 0.66),
        guess('dis-potato-late-blight', 0.22),
      ],
    },
    {
      'id': 'rev-4',
      'farmer_name': 'জাহিদুল ইসলাম',
      'farmer_district': 'বরিশাল',
      'crop': 'rice',
      'confidence': 0.41,
      'created_at': ago(30),
      'status': 'pending',
      'ai_top3': const [],
    },
    {
      'id': 'rev-5',
      'farmer_name': 'নাসরিন আক্তার',
      'farmer_district': 'গাজীপুর',
      'crop': 'tomato',
      'confidence': 0.69,
      'created_at': ago(40),
      'status': 'pending',
      'ai_top3': [
        guess('dis-tomato-leaf-curl', 0.69),
        guess('dis-tomato-late-blight', 0.18),
      ],
    },
    {
      'id': 'rev-6',
      'farmer_name': 'আবু বকর সিদ্দিক',
      'farmer_district': 'চট্টগ্রাম',
      'crop': 'rice',
      'confidence': 0.64,
      'created_at': ago(52),
      'status': 'resolved',
      'resolution_disease_id': 'dis-rice-blast',
      'note':
          'দাগের আকৃতি ও রঙ ব্লাস্টের সঙ্গে মিলছে। ছত্রাকনাশক দেওয়ার আগে আক্রান্ত পাতা সরিয়ে ফেলতে বলেছি।',
      'ai_top3': [guess('dis-rice-blast', 0.64)],
    },
    {
      'id': 'rev-7',
      'farmer_name': 'রুবেল হোসেন',
      'farmer_district': 'ময়মনসিংহ',
      'crop': 'potato',
      'confidence': 0.52,
      'created_at': ago(70),
      'status': 'resolved',
      'needs_retake': true,
      'note':
          'ছবি ঝাপসা, রোগ বোঝা যাচ্ছে না। দিনের আলোতে একটি পরিষ্কার পাতা আবার তুলতে বলেছি।',
      'ai_top3': [guess('dis-potato-late-blight', 0.52)],
    },
  ];
}

/// Krishi Barta drafts waiting for an expert. Four statuses so every tab of the
/// review queue has content.
List<Map<String, dynamic>> newsDraftSeed(String nowIso) {
  final now = DateTime.parse(nowIso);
  String ago(int hours) =>
      now.subtract(Duration(hours: hours)).toIso8601String();

  return [
    {
      'id': 'draft-1',
      'status': 'needs_expert_writing',
      'title_bn': 'বগুড়ায় আলুর নাবি ধসা দেখা দিয়েছে',
      'summary_bn':
          'বগুড়ার কয়েকটি ব্লকে আলুর নাবি ধসা শনাক্ত হয়েছে। ঠান্ডা ও কুয়াশাচ্ছন্ন আবহাওয়ায় এটি দ্রুত ছড়ায়।',
      'symptoms_bn': 'পাতার কিনারায় পানি ভেজা দাগ, পরে সাদা ছত্রাকের আস্তরণ।',
      'advised_action_bn': 'আক্রান্ত গাছ তুলে ফেলুন এবং জমি পরিদর্শন বাড়ান।',
      'category': 'disease',
      'crop': 'potato',
      'severity': 'high',
      'affected_districts': ['বগুড়া', 'রাজশাহী'],
      'source_name': 'কৃষি সম্প্রসারণ অধিদপ্তর (DAE)',
      'source_url': 'https://dae.gov.bd',
      'source_excerpt':
          'বগুড়া অঞ্চলে আলুর নাবি ধসার প্রাদুর্ভাবের খবর পাওয়া গেছে। কৃষকদের দ্রুত ব্যবস্থা নিতে বলা হয়েছে।',
      'ai_tags': ['potato', 'late_blight', 'bogura'],
      'ai_confidence': 0.71,
      'is_urgent': false,
      'updated_at': ago(3),
    },
    {
      'id': 'draft-2',
      'status': 'draft',
      'title_bn': 'টমেটো খেতে সাদা মাছির আক্রমণ বাড়ছে',
      'summary_bn':
          'কুমিল্লা ও নোয়াখালীর টমেটো খেতে সাদা মাছির আক্রমণ বেড়েছে, যা থেকে পাতা কোঁকড়ানো ভাইরাস ছড়ায়।',
      'symptoms_bn': 'পাতা কুঁকড়ে যাওয়া এবং পাতার নিচে ছোট সাদা পোকা।',
      'advised_action_bn':
          'জৈব বালাইনাশক ব্যবহার করুন এবং আক্রান্ত গাছ সরিয়ে ফেলুন।',
      'category': 'pest',
      'crop': 'tomato',
      'severity': 'high',
      'affected_districts': ['কুমিল্লা', 'নোয়াখালী'],
      'source_name': 'বাংলাদেশ কৃষি গবেষণা ইনস্টিটিউট (BARI)',
      'source_url': 'https://bari.gov.bd',
      'source_excerpt':
          'সাদা মাছির আক্রমণে টমেটোর ফলন কমে যেতে পারে বলে জানিয়েছেন গবেষকরা।',
      'ai_tags': ['tomato', 'whitefly', 'virus'],
      'ai_confidence': 0.84,
      'is_urgent': false,
      'updated_at': ago(11),
    },
    {
      'id': 'draft-3',
      'status': 'published',
      'title_bn': 'ধানে ব্লাস্ট প্রতিরোধে নতুন জাতের সুপারিশ',
      'summary_bn':
          'বাংলাদেশ ধান গবেষণা ইনস্টিটিউট ব্লাস্ট প্রতিরোধী দুটি নতুন ধানের জাত সুপারিশ করেছে।',
      'symptoms_bn': null,
      'advised_action_bn': 'রোগ প্রতিরোধী জাতের বীজ ব্যবহার করুন।',
      'category': 'disease',
      'crop': 'rice',
      'severity': 'medium',
      'affected_districts': ['সিলেট', 'মৌলভীবাজার'],
      'source_name': 'বাংলাদেশ ধান গবেষণা ইনস্টিটিউট (BRRI)',
      'source_url': 'https://brri.gov.bd',
      'source_excerpt': 'নতুন দুটি জাত ব্লাস্ট রোগে ভালো ফলন দিয়েছে।',
      'ai_tags': ['rice', 'blast', 'variety'],
      'ai_confidence': 0.92,
      'is_urgent': false,
      'published_at': ago(20),
      'updated_at': ago(20),
    },
    {
      'id': 'draft-4',
      'status': 'rejected',
      'title_bn': 'সার দেওয়ার নতুন পদ্ধতি নিয়ে গুজব',
      'summary_bn':
          'সোশ্যাল মিডিয়ায় ছড়ানো একটি পোস্টে দাবি করা হয়েছে সার দেওয়ার নতুন পদ্ধতি ফসলের ফলন তিনগুণ করবে।',
      'symptoms_bn': null,
      'advised_action_bn': null,
      'category': 'nutrient_deficiency',
      'crop': 'rice',
      'severity': 'low',
      'affected_districts': ['ঢাকা'],
      'source_name': 'ফেসবুক পোস্ট',
      'source_url': 'https://example.com/post/1',
      'source_excerpt': 'কোনো প্রতিষ্ঠিত সূত্র ছাড়া দাবিটি করা হয়েছে।',
      'ai_tags': ['fertilizer', 'claim'],
      'ai_confidence': 0.33,
      'is_urgent': false,
      'reject_reason': 'কোনো নির্ভরযোগ্য সূত্র নেই, তথ্যটি যাচাই করা যায়নি।',
      'updated_at': ago(36),
    },
    {
      'id': 'draft-5',
      'status': 'needs_expert_writing',
      'title_bn': 'উপকূলীয় জেলায় লবণাক্ততা বাড়ছে',
      'summary_bn': 'সাতক্ষীরা ও পটুয়াখালীতে জমির লবণাক্ততা বেড়েছে।',
      'symptoms_bn': null,
      'advised_action_bn': 'লবণাক্ততা সহনশীল জাত বেছে নিন।',
      'category': 'nutrient_deficiency',
      'crop': 'rice',
      'severity': 'urgent',
      'affected_districts': ['সাতক্ষীরা', 'পটুয়াখালী'],
      'source_name': 'মৃত্তিকা সম্পদ উন্নয়ন ইনস্টিটিউট (SRDI)',
      'source_url': 'https://srdi.gov.bd',
      'source_excerpt':
          'উপকূলীয় অঞ্চলে লবণাক্ততার মাত্রা স্বাভাবিকের চেয়ে বেশি পাওয়া গেছে।',
      'ai_tags': ['salinity', 'coastal', 'rice'],
      'ai_confidence': 0.79,
      'is_urgent': true,
      'updated_at': ago(48),
    },
  ];
}

/// Knowledge-base entries (FR-7/25). Every protocol names its source.
const List<Map<String, dynamic>> kKnowledgeSeed = [
  {
    'id': 'kb-1',
    'disease_id': 'dis-rice-blast',
    'crop': 'rice',
    'protocol_bn':
        'আক্রান্ত পাতা ও গাছের অবশিষ্টাংশ সরিয়ে পুড়িয়ে ফেলুন। ইউরিয়ার শেষ কিস্তি না দিয়ে পটাশ সার দিন। রোগ বেশি হলে ট্রাইসাইক্লাজল বা আইসোপ্রোথিওলেন গ্রুপের ছত্রাকনাশক ব্যবহার করুন।',
    'source': 'BRRI Bulletin 2025',
    'safety_note_bn':
        'ওষুধ ছিটানোর সময় মুখে-নাকে কাপড় দিন, শেষে হাত-মুখ ধুয়ে ফেলুন।',
    'version': 3,
    'updated_days_ago': 4,
  },
  {
    'id': 'kb-2',
    'disease_id': 'dis-potato-late-blight',
    'crop': 'potato',
    'protocol_bn':
        'আক্রান্ত গাছ তুলে মাটির গভীরে পুঁতে ফেলুন। ঠান্ডা ও কুয়াশাচ্ছন্ন আবহাওয়ায় প্রতিদিন জমি দেখুন। ম্যানকোজেব বা ক্লোরোথালোনিল গ্রুপের ছত্রাকনাশক স্প্রে করুন।',
    'source': 'BARI Krishi Projukti Hatboi',
    'safety_note_bn':
        'স্প্রে করার সময় গ্লাভস ও মাস্ক ব্যবহার করুন এবং শিশুদের দূরে রাখুন।',
    'version': 2,
    'updated_days_ago': 15,
  },
  {
    'id': 'kb-3',
    'disease_id': 'dis-tomato-leaf-curl',
    'crop': 'tomato',
    'protocol_bn':
        'এই রোগ সাদা মাছি থেকে ছড়ায়, তাই জৈব বালাইনাশক দিয়ে সাদা মাছি দমন করুন। আক্রমণ বেশি হলে গাছ তুলে ফেলুন।',
    'source': 'BARI Plant Protection Wing',
    'safety_note_bn':
        'বালাইনাশক ব্যবহারের আগে লেবেল পড়ুন এবং নির্দেশিত মাত্রার বেশি ব্যবহার করবেন না।',
    'version': 1,
    'updated_days_ago': 30,
  },
];
