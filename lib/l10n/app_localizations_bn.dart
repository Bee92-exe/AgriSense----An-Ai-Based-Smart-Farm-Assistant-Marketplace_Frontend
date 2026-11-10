// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppL10nBn extends AppL10n {
  AppL10nBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'AgriSense';

  @override
  String get appTagline => 'পকেটে আপনার কৃষি উপদেষ্টা';

  @override
  String get actionRetry => 'আবার চেষ্টা করুন';

  @override
  String get actionCancel => 'বাতিল করুন';

  @override
  String get actionConfirm => 'নিশ্চিত করুন';

  @override
  String get actionSave => 'সংরক্ষণ করুন';

  @override
  String get actionNext => 'পরবর্তী';

  @override
  String get actionBack => 'পিছনে যান';

  @override
  String get actionClose => 'বন্ধ করুন';

  @override
  String get actionSearch => 'খুঁজুন';

  @override
  String get actionSeeAll => 'সব দেখুন';

  @override
  String get actionReadAloud => 'পড়ে শোনান';

  @override
  String get actionStopReading => 'পড়া থামান';

  @override
  String get stateLoading => 'একটু অপেক্ষা করুন…';

  @override
  String get stateEmptyTitle => 'এখন কিছু নেই';

  @override
  String get stateEmptyBody => 'নতুন কিছু এলে এখানে দেখা যাবে।';

  @override
  String get stateErrorTitle => 'কিছু একটা ভুল হয়েছে';

  @override
  String get stateErrorBody =>
      'আবার চেষ্টা করুন। সমস্যা থেকে গেলে পরে আবার দেখুন।';

  @override
  String get statePermissionTitle => 'অনুমতি দরকার';

  @override
  String get statePermissionBody => 'সেটিংসে গিয়ে অনুমতিটি চালু করে দিন।';

  @override
  String get statePermissionAction => 'সেটিংস খুলুন';

  @override
  String get offlineBanner => 'ইন্টারনেট নেই। ছবিগুলো পরে পাঠানো হবে।';

  @override
  String offlineQueued(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countTextটি ছবি অপেক্ষায় আছে',
      one: '১টি ছবি অপেক্ষায় আছে',
    );
    return '$_temp0';
  }

  @override
  String get aiBadge => 'AI';

  @override
  String get aiDisclaimer => 'এটি পরামর্শ, চূড়ান্ত রোগনির্ণয় নয়।';

  @override
  String get aiMarksNotice => 'সোনালি রঙের অংশগুলো AI তৈরি করেছে।';

  @override
  String get languageTitle => 'আপনার ভাষা বেছে নিন';

  @override
  String get languageSubtitle => 'যে ভাষায় আপনি সহজে বুঝতে পারেন';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageContinue => 'চালিয়ে যান';

  @override
  String get languageSwitchLabel => 'ভাষা বদলান';

  @override
  String get consentTitle => 'আপনার অনুমতি দরকার';

  @override
  String get consentSubtitle =>
      'আপনি যেটিতে রাজি, সেটিই নেওয়া হবে। যেকোনো সময় বন্ধ করতে পারবেন।';

  @override
  String get consentPhotosTitle => 'ফসলের ছবি';

  @override
  String get consentPhotosBody =>
      'রোগ খুঁজতে ছবি ব্যবহার হবে। ছবি শুধু আপনি, বিশেষজ্ঞ আর প্রশাসক দেখতে পাবেন।';

  @override
  String get consentLocationTitle => 'জেলা';

  @override
  String get consentLocationBody =>
      'আবহাওয়া আর খবর আপনার জেলার মতো করে দেখাতে দরকার। শুধু জেলা নেওয়া হয়, ঠিকানা নয়।';

  @override
  String get consentPhoneTitle => 'মোবাইল নম্বর';

  @override
  String get consentPhoneBody =>
      'অ্যাকাউন্ট চালাতে আর অর্ডারের খবর জানাতে দরকার।';

  @override
  String get consentVoiceTitle => 'ভয়েস কমান্ড';

  @override
  String get consentVoiceBody =>
      'বাংলায় কথা বলে অ্যাপ চালাতে পারবেন। রেকর্ডিং কমান্ড বোঝার পরে মুছে ফেলা হয়।';

  @override
  String get consentAccept => 'রাজি আছি';

  @override
  String get consentDecline => 'এখন নয়';

  @override
  String get obAccountTitle => 'অ্যাকাউন্ট';

  @override
  String get obAccountSubtitle =>
      'আগে থেকে অ্যাকাউন্ট থাকলে লগইন করুন, নাহলে নতুন খুলুন।';

  @override
  String get obLogin => 'লগইন করুন';

  @override
  String get obRegister => 'নতুন অ্যাকাউন্ট খুলুন';

  @override
  String get loginTitle => 'লগইন করুন';

  @override
  String get loginSubtitle => 'মোবাইল নম্বর আর পাসওয়ার্ড দিয়ে ঢুকুন';

  @override
  String get loginMobileLabel => 'মোবাইল নম্বর';

  @override
  String get loginMobileHint => '০১XXXXXXXXX';

  @override
  String get loginPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get loginPasswordHint => 'পাসওয়ার্ড লিখুন';

  @override
  String get loginSubmit => 'লগইন';

  @override
  String get loginForgot => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get loginFailed => 'নম্বর বা পাসওয়ার্ড ঠিক নেই।';

  @override
  String get roleTitle => 'আপনি কে?';

  @override
  String get roleSubtitle => 'আপনার কাজ অনুযায়ী সঠিকটি বেছে নিন';

  @override
  String get roleFarmer => 'কৃষক';

  @override
  String get roleFarmerHint => 'ফসল দেখানো আর পরামর্শ নেওয়ার জন্য';

  @override
  String get roleVendor => 'বিক্রেতা';

  @override
  String get roleVendorHint => 'বীজ, সার আর ওষুধ বিক্রি করতে';

  @override
  String get roleExpert => 'কৃষি বিশেষজ্ঞ';

  @override
  String get roleExpertHint => 'পরামর্শ আর খবর যাচাই করতে';

  @override
  String get registerTitle => 'নতুন অ্যাকাউন্ট';

  @override
  String registerAs(String role) {
    return 'আপনি নিবন্ধন করছেন: $role';
  }

  @override
  String get registerNameLabel => 'আপনার নাম';

  @override
  String get registerNameHint => 'পুরো নাম লিখুন';

  @override
  String get registerDistrictLabel => 'জেলা';

  @override
  String get registerDistrictHint => 'জেলা বেছে নিন';

  @override
  String get registerPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get registerPasswordHint => 'কমপক্ষে ৮টি অক্ষর';

  @override
  String get registerPasswordRule => 'কমপক্ষে ৮টি অক্ষর দিতে হবে।';

  @override
  String get registerPasswordWeak =>
      'পাসওয়ার্ড শুধু সংখ্যা দিয়ে হবে না। অক্ষর ও সংখ্যা মিলিয়ে দিন।';

  @override
  String get registerPasswordCommon =>
      'এই পাসওয়ার্ডটি অনেক সহজ। আরও কঠিন কিছু দিন।';

  @override
  String get registerPasswordHasMobile =>
      'পাসওয়ার্ডে মোবাইল নম্বর রাখা যাবে না।';

  @override
  String get registerNameRequired => 'নাম লিখতে হবে।';

  @override
  String get registerMobileRequired => 'সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন।';

  @override
  String get registerDistrictRequired => 'জেলা বেছে নিন।';

  @override
  String get registerSubmit => 'অ্যাকাউন্ট খুলুন';

  @override
  String get registerShopNameLabel => 'দোকানের নাম';

  @override
  String get registerLicenseLabel => 'ট্রেড লাইসেন্স নম্বর';

  @override
  String get registerSpecializationLabel => 'কোন বিষয়ে বিশেষজ্ঞ';

  @override
  String get registerCertificationLabel => 'সার্টিফিকেট নম্বর';

  @override
  String get registerAlreadyHave => 'আগে থেকেই অ্যাকাউন্ট আছে?';

  @override
  String get otpTitle => 'কোডটি লিখুন';

  @override
  String otpBody(String mobile) {
    return '$mobile নম্বরে পাঠানো ৬ সংখ্যার কোড দিন';
  }

  @override
  String get otpLabel => 'কোড';

  @override
  String get otpHint => '৬ সংখ্যার কোড';

  @override
  String get otpSubmit => 'যাচাই করুন';

  @override
  String get otpResend => 'আবার কোড পাঠান';

  @override
  String get otpInvalid => 'কোডটি ঠিক নেই। আবার দেখুন।';

  @override
  String get phoneRegistered => 'এই নম্বর দিয়ে আগে থেকেই অ্যাকাউন্ট আছে।';

  @override
  String get resetRequestBody =>
      'আপনার মোবাইল নম্বর দিন। ডেভেলপমেন্টে রিসেট কোডটি API সার্ভার লগে দেখা যাবে।';

  @override
  String get resetRequestAction => 'রিসেট কোড চান';

  @override
  String resetCodeSent(String mobile) {
    return '$mobile নম্বরের জন্য একটি রিসেট কোড তৈরি হয়েছে';
  }

  @override
  String get resetCodeLabel => 'রিসেট কোড';

  @override
  String get resetCodeHint => 'API সার্ভার লগে দেওয়া কোড';

  @override
  String get resetSubmit => 'পাসওয়ার্ড বদলান';

  @override
  String get resetInvalid => 'কোডটি ভুল বা মেয়াদোত্তীর্ণ।';

  @override
  String get resetRequestFailed => 'রিসেট কোড চাওয়া যায়নি। আবার চেষ্টা করুন।';

  @override
  String get resetDoneTitle => 'পাসওয়ার্ড বদলানো হয়েছে';

  @override
  String get resetDoneBody => 'নতুন পাসওয়ার্ড দিয়ে লগইন করুন।';

  @override
  String get resetDevNote =>
      'ডেভেলপমেন্টে রিসেট কোডটি API সার্ভার লগে দেখা যাবে।';

  @override
  String get pendingTitle => 'অনুমতির অপেক্ষায়';

  @override
  String get pendingBody =>
      'আপনার আবেদন পরীক্ষা করা হচ্ছে। অনুমোদন পেলে জানানো হবে।';

  @override
  String get pendingCheckStatus => 'অবস্থা দেখুন';

  @override
  String get accountStatusSuspendedTitle => 'অ্যাকাউন্ট বন্ধ আছে';

  @override
  String get accountStatusSuspendedBody =>
      'বিস্তারিত জানতে সহায়তা কেন্দ্রে যোগাযোগ করুন।';

  @override
  String get navHome => 'হোম';

  @override
  String get navMarket => 'হাট বাজার';

  @override
  String get navHistory => 'ইতিহাস';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get navDiagnosis => 'ফসল দেখুন';

  @override
  String get navDashboard => 'ড্যাশবোর্ড';

  @override
  String get navProducts => 'পণ্য';

  @override
  String get navOrders => 'অর্ডার';

  @override
  String get navReviews => 'পর্যালোচনা';

  @override
  String get navNews => 'কৃষি বার্তা';

  @override
  String get navKnowledge => 'জ্ঞানভাণ্ডার';

  @override
  String get navVendors => 'বিক্রেতা';

  @override
  String get navUsers => 'ব্যবহারকারী';

  @override
  String get navSources => 'সূত্র';

  @override
  String get navLogs => 'লগ';

  @override
  String homeGreeting(String name) {
    return 'স্বাগতম, $name';
  }

  @override
  String get homeGreetingAnonymous => 'স্বাগতম';

  @override
  String get homeSubtitle => 'আজ কী করতে চান?';

  @override
  String get homeWeatherUnavailable => 'আবহাওয়া আনা যায়নি';

  @override
  String get homeWeatherReadAloud => 'আবহাওয়া পড়ে শোনান';

  @override
  String get homeUrgentTitle => 'জরুরি খবর';

  @override
  String get homeUrgentBody => 'আপনার ফসলের জন্য জরুরি একটি বার্তা আছে।';

  @override
  String get homeUrgentAction => 'খবরটি দেখুন';

  @override
  String get homeTileCheckCrop => 'ফসল দেখুন';

  @override
  String get homeTileCheckCropHint => 'পাতার ছবি তুলে রোগ জানুন';

  @override
  String get homeTileAsk => 'কথা বলে জিজ্ঞাসা';

  @override
  String get homeTileAskHint => 'মুখে প্রশ্ন করুন, উত্তর শুনুন';

  @override
  String get homeTileAdvice => 'ফসল পরামর্শ';

  @override
  String get homeTileAdviceHint => 'মাটি আর মৌসুম অনুযায়ী';

  @override
  String get homeTileWeather => 'আবহাওয়া';

  @override
  String get homeTileWeatherHint => 'বৃষ্টি আর গরমের খবর';

  @override
  String get homeTileNews => 'কৃষি বার্তা';

  @override
  String get homeTileNewsHint => 'নতুন রোগ আর পোকার খবর';

  @override
  String get homeTileMarket => 'হাট বাজার';

  @override
  String get homeTileMarketHint => 'যাচাই করা বিক্রেতার পণ্য';

  @override
  String get homeContrastToggle => 'স্পষ্ট মোড';

  @override
  String get homeContrastToggleHint => 'রোদে ভালো দেখতে';

  @override
  String get homeRecentTitle => 'সাম্প্রতিক দেখা';

  @override
  String get defaultUserName => 'কৃষক';

  @override
  String get diagnosisCaptureTitle => 'পাতার ছবি তুলুন';

  @override
  String get diagnosisCaptureSubtitle => 'আক্রান্ত পাতাটি ছবির মাঝখানে রাখুন';

  @override
  String get diagnosisTipLight => 'ভালো আলোতে ছবি তুলুন';

  @override
  String get diagnosisTipCenter => 'একটি পাতা, মাঝখানে';

  @override
  String get diagnosisTipFocus => 'ঝাপসা হলে আবার তুলুন';

  @override
  String get diagnosisOpenCamera => 'ক্যামেরা খুলুন';

  @override
  String get diagnosisFromGallery => 'গ্যালারি থেকে নিন';

  @override
  String get diagnosisSelectCrop => 'কোন ফসল?';

  @override
  String get diagnosisCropRice => 'ধান';

  @override
  String get diagnosisCropPotato => 'আলু';

  @override
  String get diagnosisCropTomato => 'টমেটো';

  @override
  String get diagnosisCropUnknown => 'জানি না';

  @override
  String get diagnosisPreviewTitle => 'ছবিটি দেখে নিন';

  @override
  String get diagnosisPreviewBody =>
      'ছবি স্পষ্ট হলে পাঠিয়ে দিন, নাহলে আবার তুলুন।';

  @override
  String get diagnosisUsePhoto => 'এই ছবি পাঠান';

  @override
  String get diagnosisRetake => 'আবার তুলুন';

  @override
  String get diagnosisProcessingTitle => 'AI ছবি দেখছে…';

  @override
  String get diagnosisProcessingBody => 'একটু সময় লাগবে। অ্যাপ বন্ধ করবেন না।';

  @override
  String get diagnosisQueuedTitle => 'ছবি সংরক্ষণ করা হয়েছে';

  @override
  String get diagnosisQueuedBody => 'ইন্টারনেট এলে ছবিটি নিজে থেকে পাঠানো হবে।';

  @override
  String get diagnosisResultTitle => 'ফলাফল';

  @override
  String get diagnosisConfidenceLabel => 'নিশ্চয়তা';

  @override
  String get diagnosisConfidenceHigh => 'বেশ নিশ্চিত';

  @override
  String get diagnosisConfidenceMedium => 'মোটামুটি নিশ্চিত';

  @override
  String get diagnosisConfidenceLow => 'নিশ্চিত নই';

  @override
  String get diagnosisTreatmentTitle => 'কী করবেন';

  @override
  String get diagnosisReadAll => 'সব পড়ে শোনান';

  @override
  String get diagnosisOrderMedicine => 'ওষুধ অর্ডার করুন';

  @override
  String get diagnosisAskQuestion => 'প্রশ্ন করুন';

  @override
  String get diagnosisSendToExpert => 'বিশেষজ্ঞকে পাঠান';

  @override
  String get diagnosisSentToExpert =>
      'আপনার ছবিটি বিশেষজ্ঞের কাছে পাঠানো হয়েছে।';

  @override
  String get diagnosisExpertReviewed => 'বিশেষজ্ঞ যাচাই করেছেন';

  @override
  String get diagnosisLowTitle => 'নিশ্চিত হওয়া যায়নি';

  @override
  String get diagnosisNotLeafTitle => 'এটি ফসলের পাতা নয়';

  @override
  String get diagnosisNotLeafBody =>
      'ছবিতে ফসলের পাতা শনাক্ত করা যায়নি। আক্রান্ত পাতার কাছে গিয়ে, ভালো আলোতে, ঝাপসা ছাড়া ছবি তুলুন।';

  @override
  String get diagnosisLowBody =>
      'ছবিটি দেখে সঠিক রোগ বোঝা যাচ্ছে না, তাই রোগের নাম দেখানো হচ্ছে না। নতুন ছবি নিন বা বিশেষজ্ঞকে পাঠান।';

  @override
  String get diagnosisMediumCaution =>
      'আমি পুরোপুরি নিশ্চিত নই। সন্দেহ থাকলে বিশেষজ্ঞকে দেখান।';

  @override
  String get diagnosisHealthyTitle => 'গাছটি সুস্থ';

  @override
  String get diagnosisSafetyTitle => 'নিরাপত্তা';

  @override
  String get diagnosisSafetyBody =>
      'ওষুধ ব্যবহারের সময় মুখে-নাকে কাপড় দিন, পরে হাত-মুখ ধুয়ে ফেলুন। শিশুদের নাগালের বাইরে রাখুন।';

  @override
  String get diagnosisHistoryTitle => 'আপনার আগের ছবি';

  @override
  String get diagnosisHistoryEmptyTitle => 'এখনো কোনো ছবি নেই';

  @override
  String get diagnosisHistoryEmptyBody =>
      'প্রথম পাতা দেখতে ক্যামেরা বাটনে চাপ দিন।';

  @override
  String get diagnosisShowTop3 => 'AI-এর সন্দেহের তালিকা';

  @override
  String get diagnosisFeedbackThanks =>
      'ধন্যবাদ! আপনার মতামত শেখাতে সাহায্য করবে।';

  @override
  String get weatherTitle => 'আবহাওয়া';

  @override
  String get weatherHumidity => 'আর্দ্রতা';

  @override
  String get weatherWind => 'বাতাস';

  @override
  String get weatherRain => 'বৃষ্টি';

  @override
  String get weatherForecastTitle => 'আগামী দিনগুলো';

  @override
  String get weatherAlertsTitle => 'সতর্কতা';

  @override
  String get weatherNoAlerts => 'এখন কোনো সতর্কতা নেই';

  @override
  String weatherUpdated(String time) {
    return 'সর্বশেষ হালনাগাদ: $time';
  }

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get profileSettings => 'সেটিংস';

  @override
  String get profileEditTitle => 'তথ্য সম্পাদনা';

  @override
  String get profileLanguage => 'ভাষা';

  @override
  String get profileContrast => 'স্পষ্ট মোড';

  @override
  String get profileVoiceMode => 'ভয়েস মোড';

  @override
  String get profileVoiceModeHint => 'ফলাফল নিজে থেকে পড়ে শোনানো হবে';

  @override
  String get profileNotifications => 'খবরের বিজ্ঞপ্তি';

  @override
  String get profileConsent => 'আপনার অনুমতিপত্র';

  @override
  String get profileLogout => 'লগ আউট';

  @override
  String get profileLogoutConfirm => 'আপনি কি লগ আউট করতে চান?';

  @override
  String get profileDeleteAccount => 'অ্যাকাউন্ট মুছতে বলুন';

  @override
  String get profileDeleteAccountConfirm =>
      'আপনার তথ্য মুছে ফেলার অনুরোধ পাঠানো হবে। নিশ্চিত?';

  @override
  String profileVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get profileSaved => 'সংরক্ষণ হয়েছে';

  @override
  String get voiceListening => 'বলুন, আমি শুনছি';

  @override
  String get voiceProcessing => 'বুঝছি…';

  @override
  String voiceUnderstood(String text) {
    return 'আপনি বলেছেন: $text';
  }

  @override
  String get voiceCouldNotUnderstand => 'আমি বুঝতে পারিনি';

  @override
  String get voiceAskAgain => 'আবার বলুন';

  @override
  String get voiceCancel => 'থামান';

  @override
  String get voiceUseTouch => 'হাতে চালান';

  @override
  String get voiceNoInternet =>
      'ইন্টারনেট নেই, তাই কথা শোনা যাচ্ছে না। হাতেই চালাতে পারবেন।';

  @override
  String get voiceMicLabel => 'কথা বলে অ্যাপ চালান';

  @override
  String get voiceConfirmationTitle => 'নিশ্চিত করুন';

  @override
  String get voiceConfirmationBody => 'আমি এই অর্ডারটি দিতে যাচ্ছি';

  @override
  String get productDescription => 'পণ্যের বিবরণ';

  @override
  String get selectQuantity => 'কতটি লাগবে';

  @override
  String get orderConfirmTitle => 'অর্ডার নিশ্চিত করুন';

  @override
  String get orderTotal => 'সর্বমোট';

  @override
  String get orderServerTotalNote => 'চূড়ান্ত হিসাব সার্ভার থেকে আসবে।';

  @override
  String get orderPaymentMode => 'পরিশোধের ধরন';

  @override
  String get orderPaymentCod => 'হাতে পেয়ে টাকা';

  @override
  String get orderPaymentDirect => 'সরাসরি বিক্রেতাকে';

  @override
  String get orderPlaced => 'অর্ডার দেওয়া হয়েছে';

  @override
  String get orderCannotCancel => 'এই অর্ডারটি আর বাতিল করা যাবে না।';

  @override
  String get orderCancelTitle => 'অর্ডার বাতিল করবেন?';

  @override
  String get orderOneVendorOnly => 'একটি অর্ডারে একই বিক্রেতার পণ্য থাকতে হবে।';

  @override
  String get marketAllCategories => 'সব ধরনের';

  @override
  String get marketInStockOnly => 'শুধু মজুদ থাকা পণ্য';

  @override
  String get marketOutOfStock => 'মজুদ নেই';

  @override
  String marketStockCount(String count) {
    return 'মজুদ: $count';
  }

  @override
  String get categorySeed => 'বীজ';

  @override
  String get categoryFertilizer => 'সার';

  @override
  String get categoryPesticide => 'কীটনাশক';

  @override
  String get categoryFungicide => 'ছত্রাকনাশক';

  @override
  String get categoryEquipment => 'যন্ত্রপাতি';

  @override
  String get categoryOther => 'অন্যান্য';

  @override
  String get vendorVerified => 'যাচাইকৃত বিক্রেতা';

  @override
  String get vendorNotVerified => 'এখনো যাচাই হয়নি';

  @override
  String get severityLow => 'কম';

  @override
  String get severityMedium => 'মাঝারি';

  @override
  String get severityHigh => 'বেশি';

  @override
  String get severityUrgent => 'জরুরি';

  @override
  String get orderStatusPending => 'অপেক্ষায়';

  @override
  String get orderStatusConfirmed => 'নিশ্চিত হয়েছে';

  @override
  String get orderStatusShipped => 'পাঠানো হয়েছে';

  @override
  String get orderStatusDelivered => 'পৌঁছে দেওয়া হয়েছে';

  @override
  String get orderStatusRejected => 'বাতিল করা হয়েছে';

  @override
  String get orderStatusCancelled => 'বাতিল';

  @override
  String get syncQueued => 'অপেক্ষায় আছে';

  @override
  String get syncUploading => 'পাঠানো হচ্ছে';

  @override
  String get syncSynced => 'পাঠানো হয়েছে';

  @override
  String get syncFailed => 'পাঠানো যায়নি';

  @override
  String get newsCategoryDisease => 'রোগ';

  @override
  String get newsCategoryPest => 'পোকা';

  @override
  String get newsCategoryVirus => 'ভাইরাস';

  @override
  String get newsCategoryNutrient => 'পুষ্টির অভাব';

  @override
  String get newsCategoryWeather => 'আবহাওয়া';

  @override
  String get newsCategoryMarket => 'বাজারদর';

  @override
  String get newsCategoryAdvisory => 'পরামর্শ';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get comingSoonBody => 'এই অংশটি এখনো তৈরি হচ্ছে।';

  @override
  String get homeTileOrdersHint => 'কেনা-বেচার হিসাব দেখুন';

  @override
  String get homeTileHistoryHint => 'আগের ছবি আর পরামর্শ';

  @override
  String get homeFieldPrompt => 'আজ মাঠে কী সমস্যা?';

  @override
  String get homeFieldPromptHint => 'পাতার ছবি তুলুন — কয়েক সেকেন্ডেই পরামর্শ';

  @override
  String get homeScanAction => 'ছবি তুলুন';

  @override
  String get homeRecentEmpty => 'এখনো কোনো পাতা দেখা হয়নি';

  @override
  String get filterAll => 'সব';

  @override
  String get filterUncertain => 'নিশ্চিত নয়';

  @override
  String get profileAnimation => 'অ্যানিমেশন';

  @override
  String get profileAnimationHint => 'আকাশ আর ফসল ধীরে নড়বে';

  @override
  String get homeAnimationOn => 'অ্যানিমেশন চালু';

  @override
  String get homeAnimationOff => 'অ্যানিমেশন বন্ধ';

  @override
  String get homeSkyRain => 'আজ বৃষ্টির আকাশ';

  @override
  String get voiceNoSpeech =>
      'এই ফোনে কথা শোনা যাচ্ছে না। নিচে লিখে বলুন, অথবা বোতাম দিয়েই সব কাজ করুন।';

  @override
  String get voiceTypeInstead => 'কথা বলতে না পারলে এখানে লিখুন';

  @override
  String voiceOpening(String screen) {
    return '$screen খুলছি';
  }

  @override
  String get voiceAnswerTitle => 'AI-এর উত্তর';

  @override
  String get voiceChooseProduct => 'কোন পণ্যটি দরকার? নিচে থেকে বেছে নিন';

  @override
  String voiceFound(String term, String count) {
    return '$term: $countটি পাওয়া গেছে';
  }

  @override
  String voiceWeatherSummary(String district, String temp, String condition) {
    return 'আজ $district-এ $temp ডিগ্রি, $condition';
  }

  @override
  String voicePriceLine(String name, String price) {
    return '$name, $price';
  }

  @override
  String voicePlaceOrder(String product, String qty) {
    return 'আমি $product, $qtyটি অর্ডার করব। ঠিক থাকলে নিশ্চিত করুন।';
  }

  @override
  String get voiceConfirmYes => 'হ্যাঁ, অর্ডার করুন';

  @override
  String get adviceTitle => 'ফসল পরামর্শ';

  @override
  String get adviceIntro =>
      'মাটি আর মৌসুম বলুন — আপনার জেলার আবহাওয়া মিলিয়ে তিনটি ফসলের পরামর্শ দেব।';

  @override
  String get adviceSoil => 'মাটির ধরন';

  @override
  String get adviceSeason => 'মৌসুম';

  @override
  String get adviceSeasonAuto => 'এই মাসের মৌসুম';

  @override
  String get adviceDistrict => 'জেলা';

  @override
  String get adviceAction => 'পরামর্শ দিন';

  @override
  String get adviceResultsTitle => 'আপনার জন্য তিনটি ফসল';

  @override
  String get adviceWeatherIncluded => 'আবহাওয়া মিলিয়ে দেখা হয়েছে';

  @override
  String get adviceWeatherMissing =>
      'আবহাওয়া মেলানো যায়নি — শুধু মাটি আর মৌসুম দেখে';

  @override
  String adviceRank(String rank) {
    return 'ক্রম $rank';
  }

  @override
  String get adviceCalendar => 'মৌসুমি ক্যালেন্ডার';

  @override
  String get adviceSavedTitle => 'আগের পরামর্শ';

  @override
  String get adviceSavedEmpty => 'এখনো কোনো পরামর্শ নেওয়া হয়নি।';

  @override
  String get adviceIntroShort => 'মাটি বেছে নিন, তারপর পরামর্শ দিন।';

  @override
  String get calendarTitle => 'মৌসুমি ক্যালেন্ডার';

  @override
  String get calendarPlanting => 'বপন / রোপণ';

  @override
  String get calendarHarvest => 'কাটা / সংগ্রহ';

  @override
  String get calendarLegend => 'রঙিন মাসে কাজ আছে — নিচে কোন মাসে কী';

  @override
  String get calendarEmpty => 'এই ফসলের ক্যালেন্ডার এখনো যোগ করা হয়নি।';

  @override
  String calendarMonth(String month) {
    return '$month মাস';
  }

  @override
  String get assistantTitle => 'কৃষি সহায়ক';

  @override
  String get assistantIntro =>
      'ফসলের রোগ, সার বা পোকার যেকোনো প্রশ্ন করতে পারেন। উত্তর যাচাই করা জ্ঞানভাণ্ডার থেকে আসে।';

  @override
  String get assistantAsk => 'প্রশ্ন লিখুন';

  @override
  String get assistantMicHint => 'প্রশ্ন বলুন';

  @override
  String get assistantListening => 'শুনছি…';

  @override
  String get assistantThinking => 'উত্তর খুঁজছি…';

  @override
  String get assistantSources => 'সূত্র';

  @override
  String get assistantNoAnswerTitle => 'এই উত্তর আমার কাছে নেই';

  @override
  String get assistantNoAnswerBody =>
      'আন্দাজে কিছু বলছি না। বিশেষজ্ঞকে পাঠালে কৃষিবিদ উত্তর দেবেন।';

  @override
  String get assistantOfferExpert => 'বিশেষজ্ঞকে পাঠান';

  @override
  String get assistantSentToExpert =>
      'আপনার প্রশ্নটি বিশেষজ্ঞের কাছে পাঠানো হয়েছে।';

  @override
  String get assistantHistoryTitle => 'আগের প্রশ্ন';

  @override
  String get assistantHistoryEmpty => 'এখনো কোনো প্রশ্ন করা হয়নি।';

  @override
  String assistantYouAsked(String question) {
    return 'আপনি জিজ্ঞেস করেছিলেন: $question';
  }

  @override
  String get adviceDisclaimer =>
      'এটি একটি পরামর্শ — চূড়ান্ত সুপারিশ নয়। জমির মাটি পরীক্ষা করে শেষ সিদ্ধান্ত নিন।';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get vendorAddProduct => 'নতুন পণ্য যোগ করুন';

  @override
  String get vendorEditProduct => 'পণ্য সম্পাদনা';

  @override
  String get vendorProductName => 'পণ্যের নাম';

  @override
  String get vendorProductNameBn => 'নাম (বাংলা)';

  @override
  String get vendorProductCategory => 'ধরন';

  @override
  String get vendorProductPrice => 'দাম (টাকা)';

  @override
  String get vendorProductStock => 'স্টকে পরিমাণ';

  @override
  String get vendorProductDescription => 'বিবরণ';

  @override
  String get vendorProductSaved => 'পণ্য সংরক্ষণ হয়েছে';

  @override
  String get vendorProductDeleted => 'পণ্য মোছা হয়েছে';

  @override
  String get vendorFieldRequired => 'এই ঘরটি পূরণ করুন।';

  @override
  String get vendorPriceInvalid => 'দাম শূন্যের বেশি হতে হবে।';

  @override
  String get vendorStockInvalid => 'স্টক শূন্য বা তার বেশি হতে হবে।';

  @override
  String get vendorLowStock => 'স্টক কম';

  @override
  String get vendorOutOfStock => 'স্টক শেষ';

  @override
  String get vendorStockMinus => 'একটি কমান';

  @override
  String get vendorStockPlus => 'একটি বাড়ান';

  @override
  String get vendorStockFine => 'সব পণ্যের স্টক ঠিক আছে।';

  @override
  String get vendorLowStockTitle => 'স্টক দেখুন';

  @override
  String get vendorNoProducts => 'এখনো কোনো পণ্য যোগ করা হয়নি';

  @override
  String get vendorNoProductsBody =>
      'প্রথম পণ্যটি যোগ করলে কৃষকেরা হাট বাজারে দেখতে পাবেন।';

  @override
  String get vendorVerifiedHint =>
      'আপনার দোকান যাচাই হয়েছে — পণ্য যোগ করতে পারবেন।';

  @override
  String get vendorBlockedBody =>
      'অ্যাডমিন যাচাই করার পরেই পণ্য যোগ বা অর্ডার নিশ্চিত করা যাবে।';

  @override
  String get vendorInvalidTransition => 'এই ধাপটি এখন করা যাবে না।';

  @override
  String get vendorTodayOrders => 'আজকের অর্ডার';

  @override
  String get vendorTodayRevenue => 'আজকের আয়';

  @override
  String get vendorPendingOrders => 'অপেক্ষারত অর্ডার';

  @override
  String get vendorRatingsTitle => 'ক্রেতার রেটিং';

  @override
  String get vendorRecentOrders => 'সাম্প্রতিক অর্ডার';

  @override
  String get vendorNoOrders => 'এখনো অর্ডার আসেনি';

  @override
  String get vendorNoOrdersBody => 'কৃষক অর্ডার করলে এখানে দেখা যাবে।';

  @override
  String get vendorOrderUpdated => 'অর্ডারের অবস্থা বদলেছে';

  @override
  String get vendorAcceptOrder => 'অর্ডার নিশ্চিত করুন';

  @override
  String get vendorRejectOrder => 'বাতিল করুন';

  @override
  String get vendorShipOrder => 'পাঠিয়ে দিন';

  @override
  String get vendorDeliverOrder => 'পৌঁছে দেওয়া হয়েছে';

  @override
  String get vendorRejectTitle => 'অর্ডার বাতিলের কারণ';

  @override
  String get vendorRejectHint => 'যেমন: পণ্যটি স্টকে নেই';

  @override
  String expertTabPending(String count) {
    return 'অপেক্ষায় ($count)';
  }

  @override
  String expertTabResolved(String count) {
    return 'সম্পন্ন ($count)';
  }

  @override
  String get expertQueueEmpty => 'পর্যালোচনার অপেক্ষায় কিছু নেই';

  @override
  String get expertQueueEmptyBody => 'নিশ্চিত নয় এমন ছবি এলে এখানে দেখা যাবে।';

  @override
  String get expertResolved => 'সম্পন্ন';

  @override
  String get expertNeedsRetake => 'নতুন ছবি দরকার';

  @override
  String get expertAiGuess => 'AI-এর অনুমান (কৃষক দেখেন না)';

  @override
  String get expertConfirmDisease => 'রোগ নিশ্চিত করুন';

  @override
  String get expertPickDisease => 'কোন রোগটি?';

  @override
  String get expertHealthy => 'সুস্থ';

  @override
  String get expertNote => 'কৃষকের জন্য নোট';

  @override
  String get expertCropUnknown => 'ফসল অজানা';

  @override
  String get expertRetakeTitle => 'কৃষককে কী জানাবেন?';

  @override
  String get expertRetakeHint => 'যেমন: দিনের আলোতে একটি পরিষ্কার পাতা তুলুন';

  @override
  String get expertSend => 'পাঠান';

  @override
  String get expertRequestSent => 'কৃষককে জানানো হয়েছে';

  @override
  String get expertNewsEmpty => 'এই তালিকায় কিছু নেই';

  @override
  String get expertNewsEmptyBody => 'নতুন খসড়া এলে এখানে দেখা যাবে।';

  @override
  String get draftNeedsWriting => 'লেখা দরকার';

  @override
  String get draftInProgress => 'খসড়া';

  @override
  String get draftPublished => 'প্রকাশিত';

  @override
  String get draftRejected => 'প্রত্যাখ্যাত';

  @override
  String get expertAddManual => 'নিজে খবর লিখুন';

  @override
  String get expertDraftCreated => 'খসড়া তৈরি হয়েছে';

  @override
  String get expertSuggestSource => 'নতুন সূত্রের প্রস্তাব';

  @override
  String get expertSourceSuggested => 'প্রস্তাব অ্যাডমিনের কাছে পাঠানো হয়েছে';

  @override
  String get expertSourceName => 'সূত্রের নাম';

  @override
  String get expertSourceUrl => 'ওয়েবসাইট';

  @override
  String get expertSourceNote => 'কেন দরকার (নোট)';

  @override
  String get expertSendSuggestion => 'প্রস্তাব পাঠান';

  @override
  String get expertUrgent => 'জরুরি';

  @override
  String get expertEditNews => 'খবর সম্পাদনা';

  @override
  String get expertNewsTitle => 'শিরোনাম';

  @override
  String get expertNewsSummary => 'সারসংক্ষেপ';

  @override
  String get expertNewsSymptoms => 'লক্ষণ';

  @override
  String get expertNewsAction => 'কৃষক কী করবেন';

  @override
  String get expertNewsSource => 'সূত্র';

  @override
  String get expertNewsCrop => 'ফসল';

  @override
  String get expertNewsCategory => 'ধরন';

  @override
  String get expertNewsSeverity => 'গুরুত্ব';

  @override
  String get expertSaveDraft => 'খসড়া সংরক্ষণ করুন';

  @override
  String get expertPublish => 'প্রকাশ করুন';

  @override
  String get expertPublishUrgent => 'জরুরি হিসেবে প্রকাশ';

  @override
  String get expertPublishTitle => 'কীভাবে প্রকাশ করবেন?';

  @override
  String get expertPublishBody =>
      'জরুরি খবর কৃষকের ফোনে বিজ্ঞপ্তি হিসেবে যায়।';

  @override
  String get expertPublished => 'প্রকাশিত হয়েছে';

  @override
  String get expertReject => 'প্রত্যাখ্যান';

  @override
  String get expertRejectTitle => 'প্রত্যাখ্যানের কারণ';

  @override
  String get expertRejectHint => 'যেমন: সূত্রে তথ্যটি নেই';

  @override
  String get expertRejected => 'প্রত্যাখ্যান করা হয়েছে';

  @override
  String get expertKnowledgeSearch => 'রোগ বা নির্দেশনা খুঁজুন';

  @override
  String get expertKnowledgeEmpty => 'জ্ঞানভাণ্ডারে কিছু নেই';

  @override
  String get expertKnowledgeEmptyBody =>
      'অন্য শব্দ দিয়ে খুঁজুন, অথবা নতুন রোগ যোগ হবে।';

  @override
  String get expertKnowledgeEditTitle => 'জ্ঞানভাণ্ডার সম্পাদনা';

  @override
  String get expertKnowledgeProtocol => 'চিকিৎসার ধাপ';

  @override
  String get expertKnowledgeSource => 'সূত্র (BRRI, DAE…)';

  @override
  String get expertKnowledgeSafety => 'নিরাপত্তা নোট';

  @override
  String get expertKnowledgeReindex =>
      'সংরক্ষণ হয়েছে — নতুন তথ্য খোঁজার তালিকায় যোগ করা হচ্ছে।';

  @override
  String get accountStatusActive => 'সক্রিয়';

  @override
  String get accountStatusPending => 'অনুমোদনের অপেক্ষায়';

  @override
  String get accountStatusSuspended => 'স্থগিত';

  @override
  String get accountStatusRemoved => 'মুছে ফেলা';

  @override
  String get vendorPendingReview => 'অনুমোদনের অপেক্ষায়';

  @override
  String get vendorRejected => 'প্রত্যাখ্যাত';

  @override
  String get vendorSuspended => 'স্থগিত';

  @override
  String get adminLicense => 'ট্রেড লাইসেন্স';

  @override
  String get adminVerify => 'যাচাই করুন';

  @override
  String get adminReject => 'প্রত্যাখ্যান';

  @override
  String get adminSuspend => 'স্থগিত করুন';

  @override
  String get adminResetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get adminResetPasswordBody =>
      'এই অস্থায়ী পাসওয়ার্ডটি একবারই দেখা যাবে। ব্যবহারকারীকে জানিয়ে দিন, এবং লগইনের পর যেন অবশ্যই পাসওয়ার্ড বদলান।';

  @override
  String get adminReinstate => 'আবার চালু করুন';

  @override
  String get adminRejectTitle => 'প্রত্যাখ্যানের কারণ';

  @override
  String get adminSuspendTitle => 'স্থগিত করার কারণ';

  @override
  String get adminReasonHint => 'কারণটি ব্যবহারকারীকে জানানো হবে';

  @override
  String get adminVendorUpdated => 'বিক্রেতার অবস্থা বদলেছে';

  @override
  String get adminVendorEmpty => 'এই তালিকায় বিক্রেতা নেই';

  @override
  String get adminVendorEmptyBody => 'অন্য অবস্থা বেছে দেখুন।';

  @override
  String get adminUserSearch => 'নাম, মোবাইল বা জেলা';

  @override
  String get adminUserEmpty => 'এই শর্তে কেউ নেই';

  @override
  String get adminUserEmptyBody => 'খোঁজ বা ছাঁকনি বদলে দেখুন।';

  @override
  String get adminActivate => 'সক্রিয় করুন';

  @override
  String get adminUserUpdated => 'ব্যবহারকারীর অবস্থা বদলেছে';

  @override
  String get adminSourceEmpty => 'কোনো সূত্র যোগ করা হয়নি';

  @override
  String get adminSourceEmptyBody => 'সংবাদ সূত্র যোগ করলে সংগ্রহ শুরু হবে।';

  @override
  String get adminAddSource => 'নতুন সূত্র';

  @override
  String get adminEditSource => 'সূত্র সম্পাদনা';

  @override
  String get adminSourceName => 'সূত্রের নাম';

  @override
  String get adminSourceUrl => 'ওয়েবসাইটের ঠিকানা';

  @override
  String get adminSourceUrlInvalid => 'ঠিকানাটি http দিয়ে শুরু হতে হবে।';

  @override
  String get adminSourceType => 'সূত্রের ধরন';

  @override
  String get adminSourceSaved => 'সূত্র সংরক্ষণ হয়েছে';

  @override
  String get adminSourceOn => 'সংগ্রহ চালু';

  @override
  String get adminSourceOff => 'সংগ্রহ বন্ধ';

  @override
  String get adminSourceNeverRun => 'এখনো সংগ্রহ হয়নি';

  @override
  String get adminSourceFailed => 'সর্বশেষ সংগ্রহ ব্যর্থ';

  @override
  String get adminSourceDeleteTitle => 'সূত্রটি মুছে ফেলবেন?';

  @override
  String get adminSourceRemoved => 'সূত্র মোছা হয়েছে';

  @override
  String get adminScheduleTitle => 'সংগ্রহের সময়সূচি';

  @override
  String get adminScheduleEnabled => 'নিজে থেকে সংগ্রহ করবে';

  @override
  String get adminScheduleSaved => 'সময়সূচি সংরক্ষণ হয়েছে';

  @override
  String get adminIntervalUp => 'সময় বাড়ান';

  @override
  String get adminIntervalDown => 'সময় কমান';

  @override
  String get adminRunNow => 'এখনই সংগ্রহ করুন';

  @override
  String get adminRunDone => 'সংগ্রহ শেষ হয়েছে';

  @override
  String get adminLogsEmpty => 'এই ধরনের লগ নেই';

  @override
  String get adminLogsEmptyBody => 'অন্য ধরন বেছে দেখুন।';

  @override
  String get logTypeSystem => 'সিস্টেম';

  @override
  String get logTypeCollection => 'সংগ্রহ';

  @override
  String get logTypeVoice => 'ভয়েস';

  @override
  String get logTypeAiFallback => 'AI ফলব্যাক';

  @override
  String get logTypeAudit => 'নিরীক্ষা';

  @override
  String get sourceTypeGovernment => 'সরকারি';

  @override
  String get sourceTypeResearch => 'গবেষণা';

  @override
  String get sourceTypeNewsPortal => 'সংবাদমাধ্যম';

  @override
  String get vendorDeleteTitle => 'পণ্য মুছে ফেলবেন?';

  @override
  String vendorStockLeft(String count) {
    return 'স্টক $count';
  }

  @override
  String vendorRatingAverage(String rating, String count) {
    return 'গড় $rating · $count জনের রেটিং';
  }

  @override
  String expertKnowledgeVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String adminSubmitted(String date) {
    return 'জমা $date';
  }

  @override
  String adminSourceLastRun(String time) {
    return 'সর্বশেষ সংগ্রহ $time';
  }

  @override
  String adminSourceDeleteConfirm(String name) {
    return '$name আর সংগ্রহ করা হবে না।';
  }

  @override
  String adminScheduleInterval(String hours) {
    return 'প্রতি $hours ঘণ্টা পর';
  }

  @override
  String adminScheduleNext(String time) {
    return 'পরবর্তী সংগ্রহ $time';
  }

  @override
  String vendorDeleteConfirm(String name) {
    return '$name মুছে ফেলা হবে। পুরনো অর্ডারে এর হিসাব থেকে যাবে।';
  }

  @override
  String get pendingPromise =>
      'আপনার অনুরোধ যাচাই করা হচ্ছে — ২৪ ঘণ্টার মধ্যে জানিয়ে দেওয়া হবে।';

  @override
  String get pendingStepSubmitted => 'আবেদন জমা হয়েছে';

  @override
  String get pendingStepReview => 'অ্যাডমিন যাচাই করছেন';

  @override
  String get pendingStepReviewBody => 'সাধারণত ২৪ ঘণ্টার মধ্যে।';

  @override
  String get pendingStepLive => 'অ্যাকাউন্ট চালু হবে';

  @override
  String get registerApprovalNote =>
      'প্রতিটি নতুন অ্যাকাউন্ট চালু হওয়ার আগে অ্যাডমিন যাচাই করেন। সাধারণত ২৪ ঘণ্টার কম সময় লাগে।';

  @override
  String get staffQuickActions => 'দ্রুত কাজ';

  @override
  String get staffComingSoon =>
      'ইন্টারফেস প্রস্তুত — ব্যাকএন্ড এলে কল চালু হবে।';

  @override
  String get staffCall => 'কল';

  @override
  String get staffMessage => 'বার্তা';

  @override
  String get staffVideo => 'ভিডিও কল';

  @override
  String get staffCompleted => 'সম্পন্ন';

  @override
  String get staffNeedsAction => 'ব্যবস্থা নিন';

  @override
  String get vendorConsoleEyebrow => 'বিক্রেতা কনসোল';

  @override
  String get vendorConsoleSubtitle =>
      'আজকের অর্ডার, স্টক আর গ্রাহক — সব এক জায়গায়।';

  @override
  String get vendorProductsSubtitle => 'প্রতিটি পণ্যের দাম, স্টক ও ছবি।';

  @override
  String get vendorOrdersSubtitle =>
      'গ্রহণ, পাঠানো ও ডেলিভারি — শুধু পরের সঠিক ধাপ।';

  @override
  String get vendorBusiness => 'ব্যবসা';

  @override
  String get vendorBusinessSubtitle => 'বিক্রি, লাভ, পেমেন্ট আর গ্রাহক খাতা।';

  @override
  String get vendorCustomerBook => 'গ্রাহক';

  @override
  String get vendorCustomers => 'মোট গ্রাহক';

  @override
  String get vendorRepeatCustomers => 'ফিরে আসা ক্রেতা';

  @override
  String get vendorCustomerSearch => 'নাম, মোবাইল বা জেলা খুঁজুন';

  @override
  String vendorFollowUpCount(String count) {
    return '$count জন গ্রাহকের ফলোআপ দরকার';
  }

  @override
  String get vendorFollowUpBody =>
      'একটি ছোট কলই ক্রেতাকে অন্য দোকানে যাওয়া থেকে ধরে রাখে।';

  @override
  String get vendorFollowUpHint => 'এই গ্রাহককে ফলোআপ তালিকায় দেখান।';

  @override
  String get vendorMarkFollowUp => 'ফলোআপ দরকার';

  @override
  String get vendorNoCustomers => 'এখনো কোনো গ্রাহক নেই';

  @override
  String get vendorNoCustomersBody =>
      'প্রথম অর্ডার ডেলিভারি হলে গ্রাহক এখানে দেখা যাবে।';

  @override
  String get vendorCustomerNote => 'ব্যক্তিগত নোট';

  @override
  String get vendorNoteHint => 'এই গ্রাহক সম্পর্কে দোকান কী মনে রাখবে?';

  @override
  String get vendorNoteSaved => 'গ্রাহকের নোট সংরক্ষিত হয়েছে';

  @override
  String get vendorLifetimeValue => 'মোট কেনাকাটা';

  @override
  String get vendorLastOrder => 'শেষ অর্ডার';

  @override
  String vendorOrdersCount(String count) {
    return '$countটি অর্ডার';
  }

  @override
  String get vendorSegmentNew => 'নতুন';

  @override
  String get vendorSegmentRepeat => 'ফিরে আসা';

  @override
  String get vendorSegmentLoyal => 'নিয়মিত';

  @override
  String get vendorSegmentAtRisk => 'ঝুঁকিতে';

  @override
  String get vendorMoney => 'হিসাব';

  @override
  String get vendorRevenue30 => 'বিক্রি (৩০ দিন)';

  @override
  String get vendorProfit30 => 'লাভ (৩০ দিন)';

  @override
  String get vendorCommission => 'প্ল্যাটফর্ম কমিশন';

  @override
  String get vendorPendingPayout => 'পাওনা টাকা';

  @override
  String get vendorPayouts => 'পেমেন্ট ইতিহাস';

  @override
  String get vendorPayoutPaid => 'পরিশোধিত';

  @override
  String get vendorTopProducts => 'সবচেয়ে বিক্রি হওয়া পণ্য';

  @override
  String vendorUnits(String units) {
    return '$unitsটি ইউনিট';
  }

  @override
  String get vendorWeekSales => 'এই সপ্তাহের বিক্রি';

  @override
  String get vendorStoreVisits => 'দোকান ভিজিট';

  @override
  String get vendorConversion => 'কনভার্শন';

  @override
  String get vendorOrders30 => 'অর্ডার (৩০ দিন)';

  @override
  String get vendorReviewPending =>
      'আপনার দোকান অনুমোদনের অপেক্ষায়। পণ্য প্রস্তুত করতে পারেন, তবে লাইসেন্স যাচাই না হলে কিছু প্রকাশ হবে না।';

  @override
  String get vendorPhotoLink => 'ছবির লিংক';

  @override
  String get vendorPhotoHint => 'https://… (ঐচ্ছিক)';

  @override
  String get vendorPhotoSoon =>
      'ক্যামেরা আপলোড ব্যাকএন্ড এলে আসবে; এখন লিংক দিয়ে প্রিভিউ দেখা যায়।';

  @override
  String get vendorPhotoRemove => 'ছবি সরান';

  @override
  String get expertHome => 'হোম';

  @override
  String get expertConsoleEyebrow => 'বিশেষজ্ঞ স্টুডিও';

  @override
  String get expertConsoleSubtitle =>
      'আপনার লেখা, উত্তর আর পরামর্শই আপনার পরিচয় গড়ে।';

  @override
  String get expertFeed => 'ফিড';

  @override
  String get expertQuestions => 'প্রশ্ন';

  @override
  String get expertConsultations => 'পরামর্শ';

  @override
  String get expertStudio => 'স্টুডিও';

  @override
  String get expertStudioSubtitle => 'রিভিউ, কৃষি বার্তা ও জ্ঞানভাণ্ডার।';

  @override
  String get expertQuestionsSubtitle =>
      'কৃষকরা মানুষের উত্তর চাইছেন, লেখা নয়।';

  @override
  String get expertConsultationsSubtitle =>
      'প্ল্যান, বুকিং আর বিশেষজ্ঞ নেটওয়ার্ক।';

  @override
  String get expertReviewsSubtitle =>
      'কম আত্মবিশ্বাসের রোগ নির্ণয় আপনার কাছে।';

  @override
  String get expertNewsSubtitle => 'কৃষি বার্তা যাচাই, সম্পাদনা ও প্রকাশ।';

  @override
  String get expertKnowledgeSubtitle =>
      'প্রতিটি উত্তরের পেছনের যাচাই করা নির্দেশনা।';

  @override
  String get expertWrite => 'লেখা লিখুন';

  @override
  String get expertArticleTitle => 'শিরোনাম';

  @override
  String get expertArticleSummary => 'এক লাইনের সারসংক্ষেপ';

  @override
  String get expertArticleBody => 'পুরো লেখা';

  @override
  String get expertArticleCrop => 'ফসল';

  @override
  String get expertArticlePublished => 'লেখাটি কৃষকের ফিডে প্রকাশিত হয়েছে';

  @override
  String get expertMine => 'আপনার';

  @override
  String get expertAllArticles => 'সব';

  @override
  String get expertMyArticles => 'আমার লেখা';

  @override
  String get expertSaved => 'সংরক্ষিত';

  @override
  String get expertNoArticles => 'এখানে এখনো কোনো লেখা নেই';

  @override
  String get expertNoArticlesBody =>
      'প্রথম লেখাটি লিখুন — কৃষকরা কৃষি বার্তায় দেখবেন।';

  @override
  String get expertLike => 'পছন্দ';

  @override
  String get expertUnlike => 'পছন্দ সরান';

  @override
  String get expertSave => 'সংরক্ষণ';

  @override
  String get expertUnsave => 'সংরক্ষণ থেকে সরান';

  @override
  String get expertRateArticle => 'লেখাটি রেট দিন';

  @override
  String expertRateStars(int stars) {
    return '$stars স্টার';
  }

  @override
  String get expertRatingThanks => 'ধন্যবাদ — আপনার রেটিং সংরক্ষিত হয়েছে।';

  @override
  String expertCommentsCount(String count) {
    return 'মন্তব্য ($count)';
  }

  @override
  String get expertNoComments => 'এখনো কোনো মন্তব্য নেই। আলোচনা শুরু করুন।';

  @override
  String get expertAddComment => 'মন্তব্য লিখুন';

  @override
  String expertViewsCount(String count) {
    return '$count জন পড়েছেন';
  }

  @override
  String get expertReadArticle => 'লেখা';

  @override
  String expertPendingQuestions(String count) {
    return '$count জন কৃষক আপনার অপেক্ষায়';
  }

  @override
  String get expertAnswerNow => 'এখনই উত্তর দিন';

  @override
  String expertOpenTab(int count) {
    return 'খোলা ($count)';
  }

  @override
  String expertAnsweredTab(int count) {
    return 'উত্তর দেওয়া ($count)';
  }

  @override
  String get expertNoQuestions => 'কোনো খোলা প্রশ্ন নেই';

  @override
  String get expertNoQuestionsBody =>
      'নতুন কৃষকের অনুরোধ এখানে আসবে। সাবস্ক্রাইবাররা অগ্রাধিকার পান।';

  @override
  String get expertAnswer => 'উত্তর দিন';

  @override
  String get expertAnsweredNow => 'উত্তর কৃষকের কাছে পাঠানো হয়েছে';

  @override
  String get expertReplyHint => 'বাংলায় উত্তর দিন, পরের ধাপটি বলে দিন…';

  @override
  String get expertModeMessage => 'বার্তা';

  @override
  String get expertModeCall => 'কল';

  @override
  String get expertModeVideo => 'ভিডিও';

  @override
  String get expertEditorialTools => 'সম্পাদনার হাতিয়ার';

  @override
  String get expertReviewQueue => 'রিভিউ কিউ';

  @override
  String get expertReviewQueueBody => 'কম আত্মবিশ্বাসের রোগ নির্ণয়';

  @override
  String get expertNewsPipeline => 'কৃষি বার্তা পাইপলাইন';

  @override
  String get expertNewsPipelineBody => 'খসড়া, প্রকাশ ও প্রত্যাখ্যান';

  @override
  String get expertKnowledgeBase => 'জ্ঞানভাণ্ডার';

  @override
  String get expertKnowledgeBody => 'প্রতিটি নির্ণয়ের পেছনের নির্দেশনা';

  @override
  String get expertInbox => 'আপনার ইনবক্স';

  @override
  String get expertTotalViews => 'মোট পাঠ';

  @override
  String get expertEarnings => 'আয়';

  @override
  String get expertSubscribers => 'সাবস্ক্রাইবার';

  @override
  String expertSubscribersCount(String count) {
    return '$count জন সাবস্ক্রাইবার';
  }

  @override
  String get expertFollowers => 'ফলোয়ার';

  @override
  String expertFollowersCount(String count) {
    return '$count ফলোয়ার';
  }

  @override
  String get expertRating => 'রেটিং';

  @override
  String get expertResponseTime => 'উত্তরের সময়';

  @override
  String expertMinutesShort(String value) {
    return '$value মিনিট';
  }

  @override
  String expertMinutes(String value) {
    return '$value মিনিট';
  }

  @override
  String get expertPlans => 'প্ল্যান';

  @override
  String get expertCalls => 'কল';

  @override
  String expertPerPeriod(String period) {
    return 'প্রতি $period';
  }

  @override
  String get expertPlanActive => 'চালু';

  @override
  String get expertPlanPaused => 'বন্ধ';

  @override
  String get expertJoinCall => 'কলে যোগ দিন';

  @override
  String get expertNoCalls => 'কোনো কল বুক হয়নি';

  @override
  String get expertNoCallsBody =>
      'কৃষকরা আপনার প্রোফাইল থেকে কল বুক করতে পারেন।';

  @override
  String get expertNetwork => 'বিশেষজ্ঞ নেটওয়ার্ক';

  @override
  String get expertConnect => 'কানেক্ট';

  @override
  String get expertConnected => 'সংযুক্ত';

  @override
  String get expertConnectNow => 'সংযোগ করুন';

  @override
  String get adminOverview => 'ওভারভিউ';

  @override
  String get adminConsoleEyebrow => 'প্ল্যাটফর্ম নিয়ন্ত্রণ';

  @override
  String get adminConsoleSubtitle =>
      'অনুমোদন, মানুষ, বাজার আর সিস্টেম — এক জায়গা থেকে।';

  @override
  String get adminApprovals => 'অনুমোদন';

  @override
  String get adminApprovalBody =>
      'প্রতিটি আবেদন, ২৪ ঘণ্টার প্রতিশ্রুতি সামনে রেখে।';

  @override
  String get adminSlaTitle => '২৪ ঘণ্টার মধ্যে যাচাই';

  @override
  String get adminSlaBody =>
      'আপনি অনুমোদন না দিলে বিক্রেতা ও বিশেষজ্ঞ কাজ করতে পারেন না। কিউ পুরনো আগে।';

  @override
  String get adminVendorsTab => 'বিক্রেতা';

  @override
  String get adminVendorApplications => 'বিক্রেতার আবেদন';

  @override
  String get adminAccountApplications => 'অ্যাকাউন্টের আবেদন';

  @override
  String get adminAccountApplication => 'অ্যাকাউন্টের আবেদন';

  @override
  String get adminVendorApplication => 'বিক্রেতার আবেদন';

  @override
  String get adminApprove => 'অনুমোদন';

  @override
  String adminPendingTotal(String count) {
    return 'কিউতে $countটি আবেদন';
  }

  @override
  String get adminApprovalFooter =>
      'অনুমোদন দিলে অ্যাকাউন্ট সাথে সাথে চালু হয়। প্রত্যাখ্যানের কারণ আবেদনকারী দেখতে পান।';

  @override
  String get adminApprovedNow => 'অনুমোদিত — অ্যাকাউন্ট চালু হয়েছে';

  @override
  String get adminRejectedNow => 'আবেদন প্রত্যাখ্যাত হয়েছে';

  @override
  String get adminNoApprovals => 'কিছু অপেক্ষা করছে না';

  @override
  String get adminNoApprovalsBody => 'নতুন আবেদন এখানে দেখা যাবে।';

  @override
  String get adminApprovalsUnavailable => 'অনুমোদনের তালিকাটি এখন লোড হয়নি';

  @override
  String get adminOpenApprovals => 'অনুমোদন কিউ খুলুন';

  @override
  String get adminApprovalQueue => 'অনুমোদন কিউ';

  @override
  String adminPendingApprovalsCount(String count) {
    return '$countটি আবেদনে সিদ্ধান্ত দরকার';
  }

  @override
  String get adminReviewWithin24h => '২৪ ঘণ্টার সীমা';

  @override
  String get adminAllClear => 'আপনার কাছে কিছু অপেক্ষা করছে না';

  @override
  String get adminGmv => 'মোট বিক্রি (৩০ দিন)';

  @override
  String get adminLast30Days => '৩০ দিন';

  @override
  String get adminCommissionEarned => 'কমিশন আয়';

  @override
  String get adminActiveUsers => 'সক্রিয় ব্যবহারকারী';

  @override
  String get adminNewUsers => 'নতুন ব্যবহারকারী (৭ দিন)';

  @override
  String get adminPlatformHealth => 'প্ল্যাটফর্মের গতি';

  @override
  String get adminNeedsAttention => 'নজর দিন';

  @override
  String get adminAllSystemsOk => 'সব সিস্টেম ঠিক আছে';

  @override
  String get adminAllSystemsOkBody =>
      'প্রতিটি সক্রিয় সোর্স শেষ সংগ্রহ সফলভাবে করেছে।';

  @override
  String adminSourceIssues(String count) {
    return '$countটি সংবাদ সোর্স ব্যর্থ হচ্ছে';
  }

  @override
  String get adminSourceIssuesBody =>
      'সংগ্রহকারী আবার চেষ্টা করছে; ত্রুটির জন্য সোর্স কনসোল খুলুন।';

  @override
  String get adminManageSources => 'সোর্স দেখুন';

  @override
  String get adminRecentActivity => 'সাম্প্রতিক কার্যক্রম';

  @override
  String get adminMonitor => 'মনিটর';

  @override
  String get adminMonitorSubtitle =>
      'অর্ডার, ক্যাটালগ ও প্রকাশিত কনটেন্ট — না বলা পর্যন্ত শুধু দেখা।';

  @override
  String get adminOrders => 'অর্ডার';

  @override
  String get adminCatalog => 'ক্যাটালগ';

  @override
  String get adminContent => 'কনটেন্ট';

  @override
  String get adminReadOnly => 'শুধু মনিটরিং';

  @override
  String get adminReadOnlyBody =>
      'অ্যাডমিন সব অর্ডার দেখতে পারেন, কিন্তু নিজে কিনতে পারেন না — কেনা শুধু কৃষকের জন্য।';

  @override
  String get adminCatalogNote => 'প্রতিটি পণ্য, প্রতিটি দোকান';

  @override
  String get adminCatalogNoteBody =>
      'নিয়ম ভাঙা পণ্য লুকান; দোকানের হিসাব থেকে যাবে।';

  @override
  String get adminContentNote => 'প্রকাশিত কনটেন্ট';

  @override
  String get adminContentNoteBody =>
      'ভুল বা অনিরাপদ সংবাদ সরিয়ে নিন। সার্ভার লেখককে জানাবে।';

  @override
  String get adminItems => 'পণ্য';

  @override
  String get adminHidden => 'লুকানো';

  @override
  String get adminHideProduct => 'লুকান';

  @override
  String get adminShowProduct => 'প্রকাশ';

  @override
  String get adminProductUpdated => 'পণ্যের অবস্থা বদলানো হয়েছে';

  @override
  String get adminTakeDown => 'সরিয়ে নিন';

  @override
  String get adminRestore => 'ফিরিয়ে দিন';

  @override
  String get adminContentUpdated => 'কনটেন্টের অবস্থা বদলানো হয়েছে';

  @override
  String get adminSystem => 'সিস্টেম';

  @override
  String get adminSystemSubtitle =>
      'প্ল্যাটফর্ম সেটিংস, সোর্স, লগ আর আপনার অ্যাকাউন্ট।';

  @override
  String get adminSettings => 'প্ল্যাটফর্ম সেটিংস';

  @override
  String get adminCommissionPercent => 'কমিশন (%)';

  @override
  String get adminCommissionHint => 'প্রতিটি সম্পন্ন অর্ডারে, ০–৩০%।';

  @override
  String get adminCommissionInvalid => '০ থেকে ৩০ এর মধ্যে সংখ্যা দিন';

  @override
  String get adminAutoApproveFarmers => 'কৃষক অ্যাকাউন্ট স্বয়ংক্রিয় অনুমোদন';

  @override
  String get adminAutoApproveFarmersHint =>
      'কৃষকরা কিউ এড়িয়ে যাবেন; বিক্রেতা ও বিশেষজ্ঞরা কখনো নয়।';

  @override
  String get adminMaintenance => 'মেইনটেন্যান্স মোড';

  @override
  String get adminMaintenanceHint =>
      'অ্যাডমিন ছাড়া সবাইকে মেইনটেন্যান্স বার্তা দেখাবে।';

  @override
  String get adminSupportPhone => 'সাপোর্ট নম্বর';

  @override
  String get adminBroadcast => 'সবাইকে বার্তা';

  @override
  String get adminBroadcastHint =>
      'আপনি মুছে না ফেলা পর্যন্ত কৃষকের হোমে দেখা যাবে।';

  @override
  String get adminSaveSettings => 'সেটিংস সংরক্ষণ';

  @override
  String get adminSettingsSaved => 'সেটিংস সংরক্ষিত হয়েছে';

  @override
  String get adminOperations => 'অপারেশন';

  @override
  String get adminSourcesSubtitle => 'সংগ্রহকারী কী পড়ে, কত ঘন ঘন।';

  @override
  String get adminLogsSubtitle => 'প্রতিটি সিস্টেম, সংগ্রহ ও অডিট ঘটনা।';

  @override
  String get adminVendorApprovals => 'বিক্রেতা অনুমোদন';

  @override
  String get adminVendorApprovalsSubtitle => 'লাইসেন্স, স্থগিত ও পুনর্বহাল।';

  @override
  String get adminUsersSubtitle =>
      'যেকোনো অ্যাকাউন্ট খুঁজুন, ফিল্টার করুন, ব্যবস্থা নিন।';

  @override
  String get advisoryTitle => 'বিশেষজ্ঞ পরামর্শ';

  @override
  String get advisorySubtitle => 'কৃষি বিশেষজ্ঞদের লেখা, যাচাই করা পরামর্শ।';

  @override
  String get homeTileAdvisory => 'পরামর্শ পড়ুন';

  @override
  String get homeTileAdvisoryHint => 'বিশেষজ্ঞদের লেখা';

  @override
  String get articleComments => 'মন্তব্য';

  @override
  String get articleCommentHint => 'আপনার মন্তব্য লিখুন';

  @override
  String get articleRate => 'রেটিং দিন';

  @override
  String get articleRated => 'ধন্যবাদ, রেটিং সংরক্ষিত হয়েছে';

  @override
  String get articleReads => 'বার পড়া হয়েছে';

  @override
  String get articleNoComments => 'এখনো কোনো মন্তব্য নেই।';

  @override
  String get askExpert => 'বিশেষজ্ঞকে প্রশ্ন করুন';

  @override
  String get askExpertHint => 'আপনার ফসলের সমস্যাটি বিস্তারিত লিখুন';

  @override
  String get askExpertSent =>
      'প্রশ্ন পাঠানো হয়েছে। বিশেষজ্ঞ উত্তর দিলে জানানো হবে।';

  @override
  String get askExpertUrgent => 'জরুরি';

  @override
  String get actionLike => 'পছন্দ';

  @override
  String get actionUnlike => 'পছন্দ সরান';
}
