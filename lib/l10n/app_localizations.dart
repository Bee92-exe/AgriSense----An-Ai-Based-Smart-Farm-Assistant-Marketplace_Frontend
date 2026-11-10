import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In bn, this message translates to:
  /// **'AgriSense'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In bn, this message translates to:
  /// **'পকেটে আপনার কৃষি উপদেষ্টা'**
  String get appTagline;

  /// No description provided for @actionRetry.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করুন'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get actionConfirm;

  /// No description provided for @actionSave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করুন'**
  String get actionSave;

  /// No description provided for @actionNext.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In bn, this message translates to:
  /// **'পিছনে যান'**
  String get actionBack;

  /// No description provided for @actionClose.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করুন'**
  String get actionClose;

  /// No description provided for @actionSearch.
  ///
  /// In bn, this message translates to:
  /// **'খুঁজুন'**
  String get actionSearch;

  /// No description provided for @actionSeeAll.
  ///
  /// In bn, this message translates to:
  /// **'সব দেখুন'**
  String get actionSeeAll;

  /// No description provided for @actionReadAloud.
  ///
  /// In bn, this message translates to:
  /// **'পড়ে শোনান'**
  String get actionReadAloud;

  /// No description provided for @actionStopReading.
  ///
  /// In bn, this message translates to:
  /// **'পড়া থামান'**
  String get actionStopReading;

  /// No description provided for @stateLoading.
  ///
  /// In bn, this message translates to:
  /// **'একটু অপেক্ষা করুন…'**
  String get stateLoading;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখন কিছু নেই'**
  String get stateEmptyTitle;

  /// No description provided for @stateEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কিছু এলে এখানে দেখা যাবে।'**
  String get stateEmptyBody;

  /// No description provided for @stateErrorTitle.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে'**
  String get stateErrorTitle;

  /// No description provided for @stateErrorBody.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন। সমস্যা থেকে গেলে পরে আবার দেখুন।'**
  String get stateErrorBody;

  /// No description provided for @statePermissionTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুমতি দরকার'**
  String get statePermissionTitle;

  /// No description provided for @statePermissionBody.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংসে গিয়ে অনুমতিটি চালু করে দিন।'**
  String get statePermissionBody;

  /// No description provided for @statePermissionAction.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস খুলুন'**
  String get statePermissionAction;

  /// No description provided for @offlineBanner.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট নেই। ছবিগুলো পরে পাঠানো হবে।'**
  String get offlineBanner;

  /// No description provided for @offlineQueued.
  ///
  /// In bn, this message translates to:
  /// **'{count, plural, =1{১টি ছবি অপেক্ষায় আছে} other{{countText}টি ছবি অপেক্ষায় আছে}}'**
  String offlineQueued(int count, String countText);

  /// No description provided for @aiBadge.
  ///
  /// In bn, this message translates to:
  /// **'AI'**
  String get aiBadge;

  /// No description provided for @aiDisclaimer.
  ///
  /// In bn, this message translates to:
  /// **'এটি পরামর্শ, চূড়ান্ত রোগনির্ণয় নয়।'**
  String get aiDisclaimer;

  /// No description provided for @aiMarksNotice.
  ///
  /// In bn, this message translates to:
  /// **'সোনালি রঙের অংশগুলো AI তৈরি করেছে।'**
  String get aiMarksNotice;

  /// No description provided for @languageTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ভাষা বেছে নিন'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যে ভাষায় আপনি সহজে বুঝতে পারেন'**
  String get languageSubtitle;

  /// No description provided for @languageBangla.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @languageEnglish.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageContinue.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান'**
  String get languageContinue;

  /// No description provided for @languageSwitchLabel.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা বদলান'**
  String get languageSwitchLabel;

  /// No description provided for @consentTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অনুমতি দরকার'**
  String get consentTitle;

  /// No description provided for @consentSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনি যেটিতে রাজি, সেটিই নেওয়া হবে। যেকোনো সময় বন্ধ করতে পারবেন।'**
  String get consentSubtitle;

  /// No description provided for @consentPhotosTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফসলের ছবি'**
  String get consentPhotosTitle;

  /// No description provided for @consentPhotosBody.
  ///
  /// In bn, this message translates to:
  /// **'রোগ খুঁজতে ছবি ব্যবহার হবে। ছবি শুধু আপনি, বিশেষজ্ঞ আর প্রশাসক দেখতে পাবেন।'**
  String get consentPhotosBody;

  /// No description provided for @consentLocationTitle.
  ///
  /// In bn, this message translates to:
  /// **'জেলা'**
  String get consentLocationTitle;

  /// No description provided for @consentLocationBody.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া আর খবর আপনার জেলার মতো করে দেখাতে দরকার। শুধু জেলা নেওয়া হয়, ঠিকানা নয়।'**
  String get consentLocationBody;

  /// No description provided for @consentPhoneTitle.
  ///
  /// In bn, this message translates to:
  /// **'মোবাইল নম্বর'**
  String get consentPhoneTitle;

  /// No description provided for @consentPhoneBody.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট চালাতে আর অর্ডারের খবর জানাতে দরকার।'**
  String get consentPhoneBody;

  /// No description provided for @consentVoiceTitle.
  ///
  /// In bn, this message translates to:
  /// **'ভয়েস কমান্ড'**
  String get consentVoiceTitle;

  /// No description provided for @consentVoiceBody.
  ///
  /// In bn, this message translates to:
  /// **'বাংলায় কথা বলে অ্যাপ চালাতে পারবেন। রেকর্ডিং কমান্ড বোঝার পরে মুছে ফেলা হয়।'**
  String get consentVoiceBody;

  /// No description provided for @consentAccept.
  ///
  /// In bn, this message translates to:
  /// **'রাজি আছি'**
  String get consentAccept;

  /// No description provided for @consentDecline.
  ///
  /// In bn, this message translates to:
  /// **'এখন নয়'**
  String get consentDecline;

  /// No description provided for @obAccountTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট'**
  String get obAccountTitle;

  /// No description provided for @obAccountSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আগে থেকে অ্যাকাউন্ট থাকলে লগইন করুন, নাহলে নতুন খুলুন।'**
  String get obAccountSubtitle;

  /// No description provided for @obLogin.
  ///
  /// In bn, this message translates to:
  /// **'লগইন করুন'**
  String get obLogin;

  /// No description provided for @obRegister.
  ///
  /// In bn, this message translates to:
  /// **'নতুন অ্যাকাউন্ট খুলুন'**
  String get obRegister;

  /// No description provided for @loginTitle.
  ///
  /// In bn, this message translates to:
  /// **'লগইন করুন'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'মোবাইল নম্বর আর পাসওয়ার্ড দিয়ে ঢুকুন'**
  String get loginSubtitle;

  /// No description provided for @loginMobileLabel.
  ///
  /// In bn, this message translates to:
  /// **'মোবাইল নম্বর'**
  String get loginMobileLabel;

  /// No description provided for @loginMobileHint.
  ///
  /// In bn, this message translates to:
  /// **'০১XXXXXXXXX'**
  String get loginMobileHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড লিখুন'**
  String get loginPasswordHint;

  /// No description provided for @loginSubmit.
  ///
  /// In bn, this message translates to:
  /// **'লগইন'**
  String get loginSubmit;

  /// No description provided for @loginForgot.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড ভুলে গেছেন?'**
  String get loginForgot;

  /// No description provided for @loginFailed.
  ///
  /// In bn, this message translates to:
  /// **'নম্বর বা পাসওয়ার্ড ঠিক নেই।'**
  String get loginFailed;

  /// No description provided for @roleTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনি কে?'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কাজ অনুযায়ী সঠিকটি বেছে নিন'**
  String get roleSubtitle;

  /// No description provided for @roleFarmer.
  ///
  /// In bn, this message translates to:
  /// **'কৃষক'**
  String get roleFarmer;

  /// No description provided for @roleFarmerHint.
  ///
  /// In bn, this message translates to:
  /// **'ফসল দেখানো আর পরামর্শ নেওয়ার জন্য'**
  String get roleFarmerHint;

  /// No description provided for @roleVendor.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতা'**
  String get roleVendor;

  /// No description provided for @roleVendorHint.
  ///
  /// In bn, this message translates to:
  /// **'বীজ, সার আর ওষুধ বিক্রি করতে'**
  String get roleVendorHint;

  /// No description provided for @roleExpert.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বিশেষজ্ঞ'**
  String get roleExpert;

  /// No description provided for @roleExpertHint.
  ///
  /// In bn, this message translates to:
  /// **'পরামর্শ আর খবর যাচাই করতে'**
  String get roleExpertHint;

  /// No description provided for @registerTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন অ্যাকাউন্ট'**
  String get registerTitle;

  /// No description provided for @registerAs.
  ///
  /// In bn, this message translates to:
  /// **'আপনি নিবন্ধন করছেন: {role}'**
  String registerAs(String role);

  /// No description provided for @registerNameLabel.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নাম'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In bn, this message translates to:
  /// **'পুরো নাম লিখুন'**
  String get registerNameHint;

  /// No description provided for @registerDistrictLabel.
  ///
  /// In bn, this message translates to:
  /// **'জেলা'**
  String get registerDistrictLabel;

  /// No description provided for @registerDistrictHint.
  ///
  /// In bn, this message translates to:
  /// **'জেলা বেছে নিন'**
  String get registerDistrictHint;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In bn, this message translates to:
  /// **'কমপক্ষে ৮টি অক্ষর'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordRule.
  ///
  /// In bn, this message translates to:
  /// **'কমপক্ষে ৮টি অক্ষর দিতে হবে।'**
  String get registerPasswordRule;

  /// No description provided for @registerPasswordWeak.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড শুধু সংখ্যা দিয়ে হবে না। অক্ষর ও সংখ্যা মিলিয়ে দিন।'**
  String get registerPasswordWeak;

  /// No description provided for @registerPasswordCommon.
  ///
  /// In bn, this message translates to:
  /// **'এই পাসওয়ার্ডটি অনেক সহজ। আরও কঠিন কিছু দিন।'**
  String get registerPasswordCommon;

  /// No description provided for @registerPasswordHasMobile.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ডে মোবাইল নম্বর রাখা যাবে না।'**
  String get registerPasswordHasMobile;

  /// No description provided for @registerNameRequired.
  ///
  /// In bn, this message translates to:
  /// **'নাম লিখতে হবে।'**
  String get registerNameRequired;

  /// No description provided for @registerMobileRequired.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক ১১ সংখ্যার মোবাইল নম্বর দিন।'**
  String get registerMobileRequired;

  /// No description provided for @registerDistrictRequired.
  ///
  /// In bn, this message translates to:
  /// **'জেলা বেছে নিন।'**
  String get registerDistrictRequired;

  /// No description provided for @registerSubmit.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট খুলুন'**
  String get registerSubmit;

  /// No description provided for @registerShopNameLabel.
  ///
  /// In bn, this message translates to:
  /// **'দোকানের নাম'**
  String get registerShopNameLabel;

  /// No description provided for @registerLicenseLabel.
  ///
  /// In bn, this message translates to:
  /// **'ট্রেড লাইসেন্স নম্বর'**
  String get registerLicenseLabel;

  /// No description provided for @registerSpecializationLabel.
  ///
  /// In bn, this message translates to:
  /// **'কোন বিষয়ে বিশেষজ্ঞ'**
  String get registerSpecializationLabel;

  /// No description provided for @registerCertificationLabel.
  ///
  /// In bn, this message translates to:
  /// **'সার্টিফিকেট নম্বর'**
  String get registerCertificationLabel;

  /// No description provided for @registerAlreadyHave.
  ///
  /// In bn, this message translates to:
  /// **'আগে থেকেই অ্যাকাউন্ট আছে?'**
  String get registerAlreadyHave;

  /// No description provided for @otpTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি লিখুন'**
  String get otpTitle;

  /// No description provided for @otpBody.
  ///
  /// In bn, this message translates to:
  /// **'{mobile} নম্বরে পাঠানো ৬ সংখ্যার কোড দিন'**
  String otpBody(String mobile);

  /// No description provided for @otpLabel.
  ///
  /// In bn, this message translates to:
  /// **'কোড'**
  String get otpLabel;

  /// No description provided for @otpHint.
  ///
  /// In bn, this message translates to:
  /// **'৬ সংখ্যার কোড'**
  String get otpHint;

  /// No description provided for @otpSubmit.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করুন'**
  String get otpSubmit;

  /// No description provided for @otpResend.
  ///
  /// In bn, this message translates to:
  /// **'আবার কোড পাঠান'**
  String get otpResend;

  /// No description provided for @otpInvalid.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি ঠিক নেই। আবার দেখুন।'**
  String get otpInvalid;

  /// No description provided for @phoneRegistered.
  ///
  /// In bn, this message translates to:
  /// **'এই নম্বর দিয়ে আগে থেকেই অ্যাকাউন্ট আছে।'**
  String get phoneRegistered;

  /// No description provided for @resetRequestBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার মোবাইল নম্বর দিন। ডেভেলপমেন্টে রিসেট কোডটি API সার্ভার লগে দেখা যাবে।'**
  String get resetRequestBody;

  /// No description provided for @resetRequestAction.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট কোড চান'**
  String get resetRequestAction;

  /// No description provided for @resetCodeSent.
  ///
  /// In bn, this message translates to:
  /// **'{mobile} নম্বরের জন্য একটি রিসেট কোড তৈরি হয়েছে'**
  String resetCodeSent(String mobile);

  /// No description provided for @resetCodeLabel.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট কোড'**
  String get resetCodeLabel;

  /// No description provided for @resetCodeHint.
  ///
  /// In bn, this message translates to:
  /// **'API সার্ভার লগে দেওয়া কোড'**
  String get resetCodeHint;

  /// No description provided for @resetSubmit.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড বদলান'**
  String get resetSubmit;

  /// No description provided for @resetInvalid.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি ভুল বা মেয়াদোত্তীর্ণ।'**
  String get resetInvalid;

  /// No description provided for @resetRequestFailed.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট কোড চাওয়া যায়নি। আবার চেষ্টা করুন।'**
  String get resetRequestFailed;

  /// No description provided for @resetDoneTitle.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড বদলানো হয়েছে'**
  String get resetDoneTitle;

  /// No description provided for @resetDoneBody.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পাসওয়ার্ড দিয়ে লগইন করুন।'**
  String get resetDoneBody;

  /// No description provided for @resetDevNote.
  ///
  /// In bn, this message translates to:
  /// **'ডেভেলপমেন্টে রিসেট কোডটি API সার্ভার লগে দেখা যাবে।'**
  String get resetDevNote;

  /// No description provided for @pendingTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুমতির অপেক্ষায়'**
  String get pendingTitle;

  /// No description provided for @pendingBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার আবেদন পরীক্ষা করা হচ্ছে। অনুমোদন পেলে জানানো হবে।'**
  String get pendingBody;

  /// No description provided for @pendingCheckStatus.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থা দেখুন'**
  String get pendingCheckStatus;

  /// No description provided for @accountStatusSuspendedTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট বন্ধ আছে'**
  String get accountStatusSuspendedTitle;

  /// No description provided for @accountStatusSuspendedBody.
  ///
  /// In bn, this message translates to:
  /// **'বিস্তারিত জানতে সহায়তা কেন্দ্রে যোগাযোগ করুন।'**
  String get accountStatusSuspendedBody;

  /// No description provided for @navHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get navHome;

  /// No description provided for @navMarket.
  ///
  /// In bn, this message translates to:
  /// **'হাট বাজার'**
  String get navMarket;

  /// No description provided for @navHistory.
  ///
  /// In bn, this message translates to:
  /// **'ইতিহাস'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In bn, this message translates to:
  /// **'প্রোফাইল'**
  String get navProfile;

  /// No description provided for @navDiagnosis.
  ///
  /// In bn, this message translates to:
  /// **'ফসল দেখুন'**
  String get navDiagnosis;

  /// No description provided for @navDashboard.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ড'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য'**
  String get navProducts;

  /// No description provided for @navOrders.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার'**
  String get navOrders;

  /// No description provided for @navReviews.
  ///
  /// In bn, this message translates to:
  /// **'পর্যালোচনা'**
  String get navReviews;

  /// No description provided for @navNews.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বার্তা'**
  String get navNews;

  /// No description provided for @navKnowledge.
  ///
  /// In bn, this message translates to:
  /// **'জ্ঞানভাণ্ডার'**
  String get navKnowledge;

  /// No description provided for @navVendors.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতা'**
  String get navVendors;

  /// No description provided for @navUsers.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবহারকারী'**
  String get navUsers;

  /// No description provided for @navSources.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র'**
  String get navSources;

  /// No description provided for @navLogs.
  ///
  /// In bn, this message translates to:
  /// **'লগ'**
  String get navLogs;

  /// No description provided for @homeGreeting.
  ///
  /// In bn, this message translates to:
  /// **'স্বাগতম, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingAnonymous.
  ///
  /// In bn, this message translates to:
  /// **'স্বাগতম'**
  String get homeGreetingAnonymous;

  /// No description provided for @homeSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আজ কী করতে চান?'**
  String get homeSubtitle;

  /// No description provided for @homeWeatherUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া আনা যায়নি'**
  String get homeWeatherUnavailable;

  /// No description provided for @homeWeatherReadAloud.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া পড়ে শোনান'**
  String get homeWeatherReadAloud;

  /// No description provided for @homeUrgentTitle.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি খবর'**
  String get homeUrgentTitle;

  /// No description provided for @homeUrgentBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ফসলের জন্য জরুরি একটি বার্তা আছে।'**
  String get homeUrgentBody;

  /// No description provided for @homeUrgentAction.
  ///
  /// In bn, this message translates to:
  /// **'খবরটি দেখুন'**
  String get homeUrgentAction;

  /// No description provided for @homeTileCheckCrop.
  ///
  /// In bn, this message translates to:
  /// **'ফসল দেখুন'**
  String get homeTileCheckCrop;

  /// No description provided for @homeTileCheckCropHint.
  ///
  /// In bn, this message translates to:
  /// **'পাতার ছবি তুলে রোগ জানুন'**
  String get homeTileCheckCropHint;

  /// No description provided for @homeTileAsk.
  ///
  /// In bn, this message translates to:
  /// **'কথা বলে জিজ্ঞাসা'**
  String get homeTileAsk;

  /// No description provided for @homeTileAskHint.
  ///
  /// In bn, this message translates to:
  /// **'মুখে প্রশ্ন করুন, উত্তর শুনুন'**
  String get homeTileAskHint;

  /// No description provided for @homeTileAdvice.
  ///
  /// In bn, this message translates to:
  /// **'ফসল পরামর্শ'**
  String get homeTileAdvice;

  /// No description provided for @homeTileAdviceHint.
  ///
  /// In bn, this message translates to:
  /// **'মাটি আর মৌসুম অনুযায়ী'**
  String get homeTileAdviceHint;

  /// No description provided for @homeTileWeather.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া'**
  String get homeTileWeather;

  /// No description provided for @homeTileWeatherHint.
  ///
  /// In bn, this message translates to:
  /// **'বৃষ্টি আর গরমের খবর'**
  String get homeTileWeatherHint;

  /// No description provided for @homeTileNews.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বার্তা'**
  String get homeTileNews;

  /// No description provided for @homeTileNewsHint.
  ///
  /// In bn, this message translates to:
  /// **'নতুন রোগ আর পোকার খবর'**
  String get homeTileNewsHint;

  /// No description provided for @homeTileMarket.
  ///
  /// In bn, this message translates to:
  /// **'হাট বাজার'**
  String get homeTileMarket;

  /// No description provided for @homeTileMarketHint.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করা বিক্রেতার পণ্য'**
  String get homeTileMarketHint;

  /// No description provided for @homeContrastToggle.
  ///
  /// In bn, this message translates to:
  /// **'স্পষ্ট মোড'**
  String get homeContrastToggle;

  /// No description provided for @homeContrastToggleHint.
  ///
  /// In bn, this message translates to:
  /// **'রোদে ভালো দেখতে'**
  String get homeContrastToggleHint;

  /// No description provided for @homeRecentTitle.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক দেখা'**
  String get homeRecentTitle;

  /// No description provided for @defaultUserName.
  ///
  /// In bn, this message translates to:
  /// **'কৃষক'**
  String get defaultUserName;

  /// No description provided for @diagnosisCaptureTitle.
  ///
  /// In bn, this message translates to:
  /// **'পাতার ছবি তুলুন'**
  String get diagnosisCaptureTitle;

  /// No description provided for @diagnosisCaptureSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আক্রান্ত পাতাটি ছবির মাঝখানে রাখুন'**
  String get diagnosisCaptureSubtitle;

  /// No description provided for @diagnosisTipLight.
  ///
  /// In bn, this message translates to:
  /// **'ভালো আলোতে ছবি তুলুন'**
  String get diagnosisTipLight;

  /// No description provided for @diagnosisTipCenter.
  ///
  /// In bn, this message translates to:
  /// **'একটি পাতা, মাঝখানে'**
  String get diagnosisTipCenter;

  /// No description provided for @diagnosisTipFocus.
  ///
  /// In bn, this message translates to:
  /// **'ঝাপসা হলে আবার তুলুন'**
  String get diagnosisTipFocus;

  /// No description provided for @diagnosisOpenCamera.
  ///
  /// In bn, this message translates to:
  /// **'ক্যামেরা খুলুন'**
  String get diagnosisOpenCamera;

  /// No description provided for @diagnosisFromGallery.
  ///
  /// In bn, this message translates to:
  /// **'গ্যালারি থেকে নিন'**
  String get diagnosisFromGallery;

  /// No description provided for @diagnosisSelectCrop.
  ///
  /// In bn, this message translates to:
  /// **'কোন ফসল?'**
  String get diagnosisSelectCrop;

  /// No description provided for @diagnosisCropRice.
  ///
  /// In bn, this message translates to:
  /// **'ধান'**
  String get diagnosisCropRice;

  /// No description provided for @diagnosisCropPotato.
  ///
  /// In bn, this message translates to:
  /// **'আলু'**
  String get diagnosisCropPotato;

  /// No description provided for @diagnosisCropTomato.
  ///
  /// In bn, this message translates to:
  /// **'টমেটো'**
  String get diagnosisCropTomato;

  /// No description provided for @diagnosisCropUnknown.
  ///
  /// In bn, this message translates to:
  /// **'জানি না'**
  String get diagnosisCropUnknown;

  /// No description provided for @diagnosisPreviewTitle.
  ///
  /// In bn, this message translates to:
  /// **'ছবিটি দেখে নিন'**
  String get diagnosisPreviewTitle;

  /// No description provided for @diagnosisPreviewBody.
  ///
  /// In bn, this message translates to:
  /// **'ছবি স্পষ্ট হলে পাঠিয়ে দিন, নাহলে আবার তুলুন।'**
  String get diagnosisPreviewBody;

  /// No description provided for @diagnosisUsePhoto.
  ///
  /// In bn, this message translates to:
  /// **'এই ছবি পাঠান'**
  String get diagnosisUsePhoto;

  /// No description provided for @diagnosisRetake.
  ///
  /// In bn, this message translates to:
  /// **'আবার তুলুন'**
  String get diagnosisRetake;

  /// No description provided for @diagnosisProcessingTitle.
  ///
  /// In bn, this message translates to:
  /// **'AI ছবি দেখছে…'**
  String get diagnosisProcessingTitle;

  /// No description provided for @diagnosisProcessingBody.
  ///
  /// In bn, this message translates to:
  /// **'একটু সময় লাগবে। অ্যাপ বন্ধ করবেন না।'**
  String get diagnosisProcessingBody;

  /// No description provided for @diagnosisQueuedTitle.
  ///
  /// In bn, this message translates to:
  /// **'ছবি সংরক্ষণ করা হয়েছে'**
  String get diagnosisQueuedTitle;

  /// No description provided for @diagnosisQueuedBody.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট এলে ছবিটি নিজে থেকে পাঠানো হবে।'**
  String get diagnosisQueuedBody;

  /// No description provided for @diagnosisResultTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফলাফল'**
  String get diagnosisResultTitle;

  /// No description provided for @diagnosisConfidenceLabel.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চয়তা'**
  String get diagnosisConfidenceLabel;

  /// No description provided for @diagnosisConfidenceHigh.
  ///
  /// In bn, this message translates to:
  /// **'বেশ নিশ্চিত'**
  String get diagnosisConfidenceHigh;

  /// No description provided for @diagnosisConfidenceMedium.
  ///
  /// In bn, this message translates to:
  /// **'মোটামুটি নিশ্চিত'**
  String get diagnosisConfidenceMedium;

  /// No description provided for @diagnosisConfidenceLow.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত নই'**
  String get diagnosisConfidenceLow;

  /// No description provided for @diagnosisTreatmentTitle.
  ///
  /// In bn, this message translates to:
  /// **'কী করবেন'**
  String get diagnosisTreatmentTitle;

  /// No description provided for @diagnosisReadAll.
  ///
  /// In bn, this message translates to:
  /// **'সব পড়ে শোনান'**
  String get diagnosisReadAll;

  /// No description provided for @diagnosisOrderMedicine.
  ///
  /// In bn, this message translates to:
  /// **'ওষুধ অর্ডার করুন'**
  String get diagnosisOrderMedicine;

  /// No description provided for @diagnosisAskQuestion.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন করুন'**
  String get diagnosisAskQuestion;

  /// No description provided for @diagnosisSendToExpert.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞকে পাঠান'**
  String get diagnosisSendToExpert;

  /// No description provided for @diagnosisSentToExpert.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ছবিটি বিশেষজ্ঞের কাছে পাঠানো হয়েছে।'**
  String get diagnosisSentToExpert;

  /// No description provided for @diagnosisExpertReviewed.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞ যাচাই করেছেন'**
  String get diagnosisExpertReviewed;

  /// No description provided for @diagnosisLowTitle.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত হওয়া যায়নি'**
  String get diagnosisLowTitle;

  /// No description provided for @diagnosisNotLeafTitle.
  ///
  /// In bn, this message translates to:
  /// **'এটি ফসলের পাতা নয়'**
  String get diagnosisNotLeafTitle;

  /// No description provided for @diagnosisNotLeafBody.
  ///
  /// In bn, this message translates to:
  /// **'ছবিতে ফসলের পাতা শনাক্ত করা যায়নি। আক্রান্ত পাতার কাছে গিয়ে, ভালো আলোতে, ঝাপসা ছাড়া ছবি তুলুন।'**
  String get diagnosisNotLeafBody;

  /// No description provided for @diagnosisLowBody.
  ///
  /// In bn, this message translates to:
  /// **'ছবিটি দেখে সঠিক রোগ বোঝা যাচ্ছে না, তাই রোগের নাম দেখানো হচ্ছে না। নতুন ছবি নিন বা বিশেষজ্ঞকে পাঠান।'**
  String get diagnosisLowBody;

  /// No description provided for @diagnosisMediumCaution.
  ///
  /// In bn, this message translates to:
  /// **'আমি পুরোপুরি নিশ্চিত নই। সন্দেহ থাকলে বিশেষজ্ঞকে দেখান।'**
  String get diagnosisMediumCaution;

  /// No description provided for @diagnosisHealthyTitle.
  ///
  /// In bn, this message translates to:
  /// **'গাছটি সুস্থ'**
  String get diagnosisHealthyTitle;

  /// No description provided for @diagnosisSafetyTitle.
  ///
  /// In bn, this message translates to:
  /// **'নিরাপত্তা'**
  String get diagnosisSafetyTitle;

  /// No description provided for @diagnosisSafetyBody.
  ///
  /// In bn, this message translates to:
  /// **'ওষুধ ব্যবহারের সময় মুখে-নাকে কাপড় দিন, পরে হাত-মুখ ধুয়ে ফেলুন। শিশুদের নাগালের বাইরে রাখুন।'**
  String get diagnosisSafetyBody;

  /// No description provided for @diagnosisHistoryTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার আগের ছবি'**
  String get diagnosisHistoryTitle;

  /// No description provided for @diagnosisHistoryEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ছবি নেই'**
  String get diagnosisHistoryEmptyTitle;

  /// No description provided for @diagnosisHistoryEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম পাতা দেখতে ক্যামেরা বাটনে চাপ দিন।'**
  String get diagnosisHistoryEmptyBody;

  /// No description provided for @diagnosisShowTop3.
  ///
  /// In bn, this message translates to:
  /// **'AI-এর সন্দেহের তালিকা'**
  String get diagnosisShowTop3;

  /// No description provided for @diagnosisFeedbackThanks.
  ///
  /// In bn, this message translates to:
  /// **'ধন্যবাদ! আপনার মতামত শেখাতে সাহায্য করবে।'**
  String get diagnosisFeedbackThanks;

  /// No description provided for @weatherTitle.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া'**
  String get weatherTitle;

  /// No description provided for @weatherHumidity.
  ///
  /// In bn, this message translates to:
  /// **'আর্দ্রতা'**
  String get weatherHumidity;

  /// No description provided for @weatherWind.
  ///
  /// In bn, this message translates to:
  /// **'বাতাস'**
  String get weatherWind;

  /// No description provided for @weatherRain.
  ///
  /// In bn, this message translates to:
  /// **'বৃষ্টি'**
  String get weatherRain;

  /// No description provided for @weatherForecastTitle.
  ///
  /// In bn, this message translates to:
  /// **'আগামী দিনগুলো'**
  String get weatherForecastTitle;

  /// No description provided for @weatherAlertsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সতর্কতা'**
  String get weatherAlertsTitle;

  /// No description provided for @weatherNoAlerts.
  ///
  /// In bn, this message translates to:
  /// **'এখন কোনো সতর্কতা নেই'**
  String get weatherNoAlerts;

  /// No description provided for @weatherUpdated.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ হালনাগাদ: {time}'**
  String weatherUpdated(String time);

  /// No description provided for @profileTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রোফাইল'**
  String get profileTitle;

  /// No description provided for @profileSettings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get profileSettings;

  /// No description provided for @profileEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য সম্পাদনা'**
  String get profileEditTitle;

  /// No description provided for @profileLanguage.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get profileLanguage;

  /// No description provided for @profileContrast.
  ///
  /// In bn, this message translates to:
  /// **'স্পষ্ট মোড'**
  String get profileContrast;

  /// No description provided for @profileVoiceMode.
  ///
  /// In bn, this message translates to:
  /// **'ভয়েস মোড'**
  String get profileVoiceMode;

  /// No description provided for @profileVoiceModeHint.
  ///
  /// In bn, this message translates to:
  /// **'ফলাফল নিজে থেকে পড়ে শোনানো হবে'**
  String get profileVoiceModeHint;

  /// No description provided for @profileNotifications.
  ///
  /// In bn, this message translates to:
  /// **'খবরের বিজ্ঞপ্তি'**
  String get profileNotifications;

  /// No description provided for @profileConsent.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অনুমতিপত্র'**
  String get profileConsent;

  /// No description provided for @profileLogout.
  ///
  /// In bn, this message translates to:
  /// **'লগ আউট'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In bn, this message translates to:
  /// **'আপনি কি লগ আউট করতে চান?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট মুছতে বলুন'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In bn, this message translates to:
  /// **'আপনার তথ্য মুছে ফেলার অনুরোধ পাঠানো হবে। নিশ্চিত?'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @profileVersion.
  ///
  /// In bn, this message translates to:
  /// **'সংস্করণ {version}'**
  String profileVersion(String version);

  /// No description provided for @profileSaved.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ হয়েছে'**
  String get profileSaved;

  /// No description provided for @voiceListening.
  ///
  /// In bn, this message translates to:
  /// **'বলুন, আমি শুনছি'**
  String get voiceListening;

  /// No description provided for @voiceProcessing.
  ///
  /// In bn, this message translates to:
  /// **'বুঝছি…'**
  String get voiceProcessing;

  /// No description provided for @voiceUnderstood.
  ///
  /// In bn, this message translates to:
  /// **'আপনি বলেছেন: {text}'**
  String voiceUnderstood(String text);

  /// No description provided for @voiceCouldNotUnderstand.
  ///
  /// In bn, this message translates to:
  /// **'আমি বুঝতে পারিনি'**
  String get voiceCouldNotUnderstand;

  /// No description provided for @voiceAskAgain.
  ///
  /// In bn, this message translates to:
  /// **'আবার বলুন'**
  String get voiceAskAgain;

  /// No description provided for @voiceCancel.
  ///
  /// In bn, this message translates to:
  /// **'থামান'**
  String get voiceCancel;

  /// No description provided for @voiceUseTouch.
  ///
  /// In bn, this message translates to:
  /// **'হাতে চালান'**
  String get voiceUseTouch;

  /// No description provided for @voiceNoInternet.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট নেই, তাই কথা শোনা যাচ্ছে না। হাতেই চালাতে পারবেন।'**
  String get voiceNoInternet;

  /// No description provided for @voiceMicLabel.
  ///
  /// In bn, this message translates to:
  /// **'কথা বলে অ্যাপ চালান'**
  String get voiceMicLabel;

  /// No description provided for @voiceConfirmationTitle.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get voiceConfirmationTitle;

  /// No description provided for @voiceConfirmationBody.
  ///
  /// In bn, this message translates to:
  /// **'আমি এই অর্ডারটি দিতে যাচ্ছি'**
  String get voiceConfirmationBody;

  /// No description provided for @productDescription.
  ///
  /// In bn, this message translates to:
  /// **'পণ্যের বিবরণ'**
  String get productDescription;

  /// No description provided for @selectQuantity.
  ///
  /// In bn, this message translates to:
  /// **'কতটি লাগবে'**
  String get selectQuantity;

  /// No description provided for @orderConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার নিশ্চিত করুন'**
  String get orderConfirmTitle;

  /// No description provided for @orderTotal.
  ///
  /// In bn, this message translates to:
  /// **'সর্বমোট'**
  String get orderTotal;

  /// No description provided for @orderServerTotalNote.
  ///
  /// In bn, this message translates to:
  /// **'চূড়ান্ত হিসাব সার্ভার থেকে আসবে।'**
  String get orderServerTotalNote;

  /// No description provided for @orderPaymentMode.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধের ধরন'**
  String get orderPaymentMode;

  /// No description provided for @orderPaymentCod.
  ///
  /// In bn, this message translates to:
  /// **'হাতে পেয়ে টাকা'**
  String get orderPaymentCod;

  /// No description provided for @orderPaymentDirect.
  ///
  /// In bn, this message translates to:
  /// **'সরাসরি বিক্রেতাকে'**
  String get orderPaymentDirect;

  /// No description provided for @orderPlaced.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার দেওয়া হয়েছে'**
  String get orderPlaced;

  /// No description provided for @orderCannotCancel.
  ///
  /// In bn, this message translates to:
  /// **'এই অর্ডারটি আর বাতিল করা যাবে না।'**
  String get orderCannotCancel;

  /// No description provided for @orderCancelTitle.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার বাতিল করবেন?'**
  String get orderCancelTitle;

  /// No description provided for @orderOneVendorOnly.
  ///
  /// In bn, this message translates to:
  /// **'একটি অর্ডারে একই বিক্রেতার পণ্য থাকতে হবে।'**
  String get orderOneVendorOnly;

  /// No description provided for @marketAllCategories.
  ///
  /// In bn, this message translates to:
  /// **'সব ধরনের'**
  String get marketAllCategories;

  /// No description provided for @marketInStockOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু মজুদ থাকা পণ্য'**
  String get marketInStockOnly;

  /// No description provided for @marketOutOfStock.
  ///
  /// In bn, this message translates to:
  /// **'মজুদ নেই'**
  String get marketOutOfStock;

  /// No description provided for @marketStockCount.
  ///
  /// In bn, this message translates to:
  /// **'মজুদ: {count}'**
  String marketStockCount(String count);

  /// No description provided for @categorySeed.
  ///
  /// In bn, this message translates to:
  /// **'বীজ'**
  String get categorySeed;

  /// No description provided for @categoryFertilizer.
  ///
  /// In bn, this message translates to:
  /// **'সার'**
  String get categoryFertilizer;

  /// No description provided for @categoryPesticide.
  ///
  /// In bn, this message translates to:
  /// **'কীটনাশক'**
  String get categoryPesticide;

  /// No description provided for @categoryFungicide.
  ///
  /// In bn, this message translates to:
  /// **'ছত্রাকনাশক'**
  String get categoryFungicide;

  /// No description provided for @categoryEquipment.
  ///
  /// In bn, this message translates to:
  /// **'যন্ত্রপাতি'**
  String get categoryEquipment;

  /// No description provided for @categoryOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get categoryOther;

  /// No description provided for @vendorVerified.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত বিক্রেতা'**
  String get vendorVerified;

  /// No description provided for @vendorNotVerified.
  ///
  /// In bn, this message translates to:
  /// **'এখনো যাচাই হয়নি'**
  String get vendorNotVerified;

  /// No description provided for @severityLow.
  ///
  /// In bn, this message translates to:
  /// **'কম'**
  String get severityLow;

  /// No description provided for @severityMedium.
  ///
  /// In bn, this message translates to:
  /// **'মাঝারি'**
  String get severityMedium;

  /// No description provided for @severityHigh.
  ///
  /// In bn, this message translates to:
  /// **'বেশি'**
  String get severityHigh;

  /// No description provided for @severityUrgent.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি'**
  String get severityUrgent;

  /// No description provided for @orderStatusPending.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষায়'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত হয়েছে'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusShipped.
  ///
  /// In bn, this message translates to:
  /// **'পাঠানো হয়েছে'**
  String get orderStatusShipped;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In bn, this message translates to:
  /// **'পৌঁছে দেওয়া হয়েছে'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusRejected.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করা হয়েছে'**
  String get orderStatusRejected;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get orderStatusCancelled;

  /// No description provided for @syncQueued.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষায় আছে'**
  String get syncQueued;

  /// No description provided for @syncUploading.
  ///
  /// In bn, this message translates to:
  /// **'পাঠানো হচ্ছে'**
  String get syncUploading;

  /// No description provided for @syncSynced.
  ///
  /// In bn, this message translates to:
  /// **'পাঠানো হয়েছে'**
  String get syncSynced;

  /// No description provided for @syncFailed.
  ///
  /// In bn, this message translates to:
  /// **'পাঠানো যায়নি'**
  String get syncFailed;

  /// No description provided for @newsCategoryDisease.
  ///
  /// In bn, this message translates to:
  /// **'রোগ'**
  String get newsCategoryDisease;

  /// No description provided for @newsCategoryPest.
  ///
  /// In bn, this message translates to:
  /// **'পোকা'**
  String get newsCategoryPest;

  /// No description provided for @newsCategoryVirus.
  ///
  /// In bn, this message translates to:
  /// **'ভাইরাস'**
  String get newsCategoryVirus;

  /// No description provided for @newsCategoryNutrient.
  ///
  /// In bn, this message translates to:
  /// **'পুষ্টির অভাব'**
  String get newsCategoryNutrient;

  /// No description provided for @newsCategoryWeather.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া'**
  String get newsCategoryWeather;

  /// No description provided for @newsCategoryMarket.
  ///
  /// In bn, this message translates to:
  /// **'বাজারদর'**
  String get newsCategoryMarket;

  /// No description provided for @newsCategoryAdvisory.
  ///
  /// In bn, this message translates to:
  /// **'পরামর্শ'**
  String get newsCategoryAdvisory;

  /// No description provided for @comingSoon.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই আসছে'**
  String get comingSoon;

  /// No description provided for @comingSoonBody.
  ///
  /// In bn, this message translates to:
  /// **'এই অংশটি এখনো তৈরি হচ্ছে।'**
  String get comingSoonBody;

  /// No description provided for @homeTileOrdersHint.
  ///
  /// In bn, this message translates to:
  /// **'কেনা-বেচার হিসাব দেখুন'**
  String get homeTileOrdersHint;

  /// No description provided for @homeTileHistoryHint.
  ///
  /// In bn, this message translates to:
  /// **'আগের ছবি আর পরামর্শ'**
  String get homeTileHistoryHint;

  /// No description provided for @homeFieldPrompt.
  ///
  /// In bn, this message translates to:
  /// **'আজ মাঠে কী সমস্যা?'**
  String get homeFieldPrompt;

  /// No description provided for @homeFieldPromptHint.
  ///
  /// In bn, this message translates to:
  /// **'পাতার ছবি তুলুন — কয়েক সেকেন্ডেই পরামর্শ'**
  String get homeFieldPromptHint;

  /// No description provided for @homeScanAction.
  ///
  /// In bn, this message translates to:
  /// **'ছবি তুলুন'**
  String get homeScanAction;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো পাতা দেখা হয়নি'**
  String get homeRecentEmpty;

  /// No description provided for @filterAll.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get filterAll;

  /// No description provided for @filterUncertain.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত নয়'**
  String get filterUncertain;

  /// No description provided for @profileAnimation.
  ///
  /// In bn, this message translates to:
  /// **'অ্যানিমেশন'**
  String get profileAnimation;

  /// No description provided for @profileAnimationHint.
  ///
  /// In bn, this message translates to:
  /// **'আকাশ আর ফসল ধীরে নড়বে'**
  String get profileAnimationHint;

  /// No description provided for @homeAnimationOn.
  ///
  /// In bn, this message translates to:
  /// **'অ্যানিমেশন চালু'**
  String get homeAnimationOn;

  /// No description provided for @homeAnimationOff.
  ///
  /// In bn, this message translates to:
  /// **'অ্যানিমেশন বন্ধ'**
  String get homeAnimationOff;

  /// No description provided for @homeSkyRain.
  ///
  /// In bn, this message translates to:
  /// **'আজ বৃষ্টির আকাশ'**
  String get homeSkyRain;

  /// No description provided for @voiceNoSpeech.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে কথা শোনা যাচ্ছে না। নিচে লিখে বলুন, অথবা বোতাম দিয়েই সব কাজ করুন।'**
  String get voiceNoSpeech;

  /// No description provided for @voiceTypeInstead.
  ///
  /// In bn, this message translates to:
  /// **'কথা বলতে না পারলে এখানে লিখুন'**
  String get voiceTypeInstead;

  /// No description provided for @voiceOpening.
  ///
  /// In bn, this message translates to:
  /// **'{screen} খুলছি'**
  String voiceOpening(String screen);

  /// No description provided for @voiceAnswerTitle.
  ///
  /// In bn, this message translates to:
  /// **'AI-এর উত্তর'**
  String get voiceAnswerTitle;

  /// No description provided for @voiceChooseProduct.
  ///
  /// In bn, this message translates to:
  /// **'কোন পণ্যটি দরকার? নিচে থেকে বেছে নিন'**
  String get voiceChooseProduct;

  /// No description provided for @voiceFound.
  ///
  /// In bn, this message translates to:
  /// **'{term}: {count}টি পাওয়া গেছে'**
  String voiceFound(String term, String count);

  /// No description provided for @voiceWeatherSummary.
  ///
  /// In bn, this message translates to:
  /// **'আজ {district}-এ {temp} ডিগ্রি, {condition}'**
  String voiceWeatherSummary(String district, String temp, String condition);

  /// No description provided for @voicePriceLine.
  ///
  /// In bn, this message translates to:
  /// **'{name}, {price}'**
  String voicePriceLine(String name, String price);

  /// No description provided for @voicePlaceOrder.
  ///
  /// In bn, this message translates to:
  /// **'আমি {product}, {qty}টি অর্ডার করব। ঠিক থাকলে নিশ্চিত করুন।'**
  String voicePlaceOrder(String product, String qty);

  /// No description provided for @voiceConfirmYes.
  ///
  /// In bn, this message translates to:
  /// **'হ্যাঁ, অর্ডার করুন'**
  String get voiceConfirmYes;

  /// No description provided for @adviceTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফসল পরামর্শ'**
  String get adviceTitle;

  /// No description provided for @adviceIntro.
  ///
  /// In bn, this message translates to:
  /// **'মাটি আর মৌসুম বলুন — আপনার জেলার আবহাওয়া মিলিয়ে তিনটি ফসলের পরামর্শ দেব।'**
  String get adviceIntro;

  /// No description provided for @adviceSoil.
  ///
  /// In bn, this message translates to:
  /// **'মাটির ধরন'**
  String get adviceSoil;

  /// No description provided for @adviceSeason.
  ///
  /// In bn, this message translates to:
  /// **'মৌসুম'**
  String get adviceSeason;

  /// No description provided for @adviceSeasonAuto.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের মৌসুম'**
  String get adviceSeasonAuto;

  /// No description provided for @adviceDistrict.
  ///
  /// In bn, this message translates to:
  /// **'জেলা'**
  String get adviceDistrict;

  /// No description provided for @adviceAction.
  ///
  /// In bn, this message translates to:
  /// **'পরামর্শ দিন'**
  String get adviceAction;

  /// No description provided for @adviceResultsTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার জন্য তিনটি ফসল'**
  String get adviceResultsTitle;

  /// No description provided for @adviceWeatherIncluded.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া মিলিয়ে দেখা হয়েছে'**
  String get adviceWeatherIncluded;

  /// No description provided for @adviceWeatherMissing.
  ///
  /// In bn, this message translates to:
  /// **'আবহাওয়া মেলানো যায়নি — শুধু মাটি আর মৌসুম দেখে'**
  String get adviceWeatherMissing;

  /// No description provided for @adviceRank.
  ///
  /// In bn, this message translates to:
  /// **'ক্রম {rank}'**
  String adviceRank(String rank);

  /// No description provided for @adviceCalendar.
  ///
  /// In bn, this message translates to:
  /// **'মৌসুমি ক্যালেন্ডার'**
  String get adviceCalendar;

  /// No description provided for @adviceSavedTitle.
  ///
  /// In bn, this message translates to:
  /// **'আগের পরামর্শ'**
  String get adviceSavedTitle;

  /// No description provided for @adviceSavedEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো পরামর্শ নেওয়া হয়নি।'**
  String get adviceSavedEmpty;

  /// No description provided for @adviceIntroShort.
  ///
  /// In bn, this message translates to:
  /// **'মাটি বেছে নিন, তারপর পরামর্শ দিন।'**
  String get adviceIntroShort;

  /// No description provided for @calendarTitle.
  ///
  /// In bn, this message translates to:
  /// **'মৌসুমি ক্যালেন্ডার'**
  String get calendarTitle;

  /// No description provided for @calendarPlanting.
  ///
  /// In bn, this message translates to:
  /// **'বপন / রোপণ'**
  String get calendarPlanting;

  /// No description provided for @calendarHarvest.
  ///
  /// In bn, this message translates to:
  /// **'কাটা / সংগ্রহ'**
  String get calendarHarvest;

  /// No description provided for @calendarLegend.
  ///
  /// In bn, this message translates to:
  /// **'রঙিন মাসে কাজ আছে — নিচে কোন মাসে কী'**
  String get calendarLegend;

  /// No description provided for @calendarEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই ফসলের ক্যালেন্ডার এখনো যোগ করা হয়নি।'**
  String get calendarEmpty;

  /// No description provided for @calendarMonth.
  ///
  /// In bn, this message translates to:
  /// **'{month} মাস'**
  String calendarMonth(String month);

  /// No description provided for @assistantTitle.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি সহায়ক'**
  String get assistantTitle;

  /// No description provided for @assistantIntro.
  ///
  /// In bn, this message translates to:
  /// **'ফসলের রোগ, সার বা পোকার যেকোনো প্রশ্ন করতে পারেন। উত্তর যাচাই করা জ্ঞানভাণ্ডার থেকে আসে।'**
  String get assistantIntro;

  /// No description provided for @assistantAsk.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন লিখুন'**
  String get assistantAsk;

  /// No description provided for @assistantMicHint.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন বলুন'**
  String get assistantMicHint;

  /// No description provided for @assistantListening.
  ///
  /// In bn, this message translates to:
  /// **'শুনছি…'**
  String get assistantListening;

  /// No description provided for @assistantThinking.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর খুঁজছি…'**
  String get assistantThinking;

  /// No description provided for @assistantSources.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র'**
  String get assistantSources;

  /// No description provided for @assistantNoAnswerTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই উত্তর আমার কাছে নেই'**
  String get assistantNoAnswerTitle;

  /// No description provided for @assistantNoAnswerBody.
  ///
  /// In bn, this message translates to:
  /// **'আন্দাজে কিছু বলছি না। বিশেষজ্ঞকে পাঠালে কৃষিবিদ উত্তর দেবেন।'**
  String get assistantNoAnswerBody;

  /// No description provided for @assistantOfferExpert.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞকে পাঠান'**
  String get assistantOfferExpert;

  /// No description provided for @assistantSentToExpert.
  ///
  /// In bn, this message translates to:
  /// **'আপনার প্রশ্নটি বিশেষজ্ঞের কাছে পাঠানো হয়েছে।'**
  String get assistantSentToExpert;

  /// No description provided for @assistantHistoryTitle.
  ///
  /// In bn, this message translates to:
  /// **'আগের প্রশ্ন'**
  String get assistantHistoryTitle;

  /// No description provided for @assistantHistoryEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো প্রশ্ন করা হয়নি।'**
  String get assistantHistoryEmpty;

  /// No description provided for @assistantYouAsked.
  ///
  /// In bn, this message translates to:
  /// **'আপনি জিজ্ঞেস করেছিলেন: {question}'**
  String assistantYouAsked(String question);

  /// No description provided for @adviceDisclaimer.
  ///
  /// In bn, this message translates to:
  /// **'এটি একটি পরামর্শ — চূড়ান্ত সুপারিশ নয়। জমির মাটি পরীক্ষা করে শেষ সিদ্ধান্ত নিন।'**
  String get adviceDisclaimer;

  /// No description provided for @actionEdit.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনা'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get actionDelete;

  /// No description provided for @vendorAddProduct.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পণ্য যোগ করুন'**
  String get vendorAddProduct;

  /// No description provided for @vendorEditProduct.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য সম্পাদনা'**
  String get vendorEditProduct;

  /// No description provided for @vendorProductName.
  ///
  /// In bn, this message translates to:
  /// **'পণ্যের নাম'**
  String get vendorProductName;

  /// No description provided for @vendorProductNameBn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (বাংলা)'**
  String get vendorProductNameBn;

  /// No description provided for @vendorProductCategory.
  ///
  /// In bn, this message translates to:
  /// **'ধরন'**
  String get vendorProductCategory;

  /// No description provided for @vendorProductPrice.
  ///
  /// In bn, this message translates to:
  /// **'দাম (টাকা)'**
  String get vendorProductPrice;

  /// No description provided for @vendorProductStock.
  ///
  /// In bn, this message translates to:
  /// **'স্টকে পরিমাণ'**
  String get vendorProductStock;

  /// No description provided for @vendorProductDescription.
  ///
  /// In bn, this message translates to:
  /// **'বিবরণ'**
  String get vendorProductDescription;

  /// No description provided for @vendorProductSaved.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য সংরক্ষণ হয়েছে'**
  String get vendorProductSaved;

  /// No description provided for @vendorProductDeleted.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য মোছা হয়েছে'**
  String get vendorProductDeleted;

  /// No description provided for @vendorFieldRequired.
  ///
  /// In bn, this message translates to:
  /// **'এই ঘরটি পূরণ করুন।'**
  String get vendorFieldRequired;

  /// No description provided for @vendorPriceInvalid.
  ///
  /// In bn, this message translates to:
  /// **'দাম শূন্যের বেশি হতে হবে।'**
  String get vendorPriceInvalid;

  /// No description provided for @vendorStockInvalid.
  ///
  /// In bn, this message translates to:
  /// **'স্টক শূন্য বা তার বেশি হতে হবে।'**
  String get vendorStockInvalid;

  /// No description provided for @vendorLowStock.
  ///
  /// In bn, this message translates to:
  /// **'স্টক কম'**
  String get vendorLowStock;

  /// No description provided for @vendorOutOfStock.
  ///
  /// In bn, this message translates to:
  /// **'স্টক শেষ'**
  String get vendorOutOfStock;

  /// No description provided for @vendorStockMinus.
  ///
  /// In bn, this message translates to:
  /// **'একটি কমান'**
  String get vendorStockMinus;

  /// No description provided for @vendorStockPlus.
  ///
  /// In bn, this message translates to:
  /// **'একটি বাড়ান'**
  String get vendorStockPlus;

  /// No description provided for @vendorStockFine.
  ///
  /// In bn, this message translates to:
  /// **'সব পণ্যের স্টক ঠিক আছে।'**
  String get vendorStockFine;

  /// No description provided for @vendorLowStockTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্টক দেখুন'**
  String get vendorLowStockTitle;

  /// No description provided for @vendorNoProducts.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো পণ্য যোগ করা হয়নি'**
  String get vendorNoProducts;

  /// No description provided for @vendorNoProductsBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম পণ্যটি যোগ করলে কৃষকেরা হাট বাজারে দেখতে পাবেন।'**
  String get vendorNoProductsBody;

  /// No description provided for @vendorVerifiedHint.
  ///
  /// In bn, this message translates to:
  /// **'আপনার দোকান যাচাই হয়েছে — পণ্য যোগ করতে পারবেন।'**
  String get vendorVerifiedHint;

  /// No description provided for @vendorBlockedBody.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন যাচাই করার পরেই পণ্য যোগ বা অর্ডার নিশ্চিত করা যাবে।'**
  String get vendorBlockedBody;

  /// No description provided for @vendorInvalidTransition.
  ///
  /// In bn, this message translates to:
  /// **'এই ধাপটি এখন করা যাবে না।'**
  String get vendorInvalidTransition;

  /// No description provided for @vendorTodayOrders.
  ///
  /// In bn, this message translates to:
  /// **'আজকের অর্ডার'**
  String get vendorTodayOrders;

  /// No description provided for @vendorTodayRevenue.
  ///
  /// In bn, this message translates to:
  /// **'আজকের আয়'**
  String get vendorTodayRevenue;

  /// No description provided for @vendorPendingOrders.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষারত অর্ডার'**
  String get vendorPendingOrders;

  /// No description provided for @vendorRatingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'ক্রেতার রেটিং'**
  String get vendorRatingsTitle;

  /// No description provided for @vendorRecentOrders.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক অর্ডার'**
  String get vendorRecentOrders;

  /// No description provided for @vendorNoOrders.
  ///
  /// In bn, this message translates to:
  /// **'এখনো অর্ডার আসেনি'**
  String get vendorNoOrders;

  /// No description provided for @vendorNoOrdersBody.
  ///
  /// In bn, this message translates to:
  /// **'কৃষক অর্ডার করলে এখানে দেখা যাবে।'**
  String get vendorNoOrdersBody;

  /// No description provided for @vendorOrderUpdated.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডারের অবস্থা বদলেছে'**
  String get vendorOrderUpdated;

  /// No description provided for @vendorAcceptOrder.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার নিশ্চিত করুন'**
  String get vendorAcceptOrder;

  /// No description provided for @vendorRejectOrder.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করুন'**
  String get vendorRejectOrder;

  /// No description provided for @vendorShipOrder.
  ///
  /// In bn, this message translates to:
  /// **'পাঠিয়ে দিন'**
  String get vendorShipOrder;

  /// No description provided for @vendorDeliverOrder.
  ///
  /// In bn, this message translates to:
  /// **'পৌঁছে দেওয়া হয়েছে'**
  String get vendorDeliverOrder;

  /// No description provided for @vendorRejectTitle.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার বাতিলের কারণ'**
  String get vendorRejectTitle;

  /// No description provided for @vendorRejectHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: পণ্যটি স্টকে নেই'**
  String get vendorRejectHint;

  /// No description provided for @expertTabPending.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষায় ({count})'**
  String expertTabPending(String count);

  /// No description provided for @expertTabResolved.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন ({count})'**
  String expertTabResolved(String count);

  /// No description provided for @expertQueueEmpty.
  ///
  /// In bn, this message translates to:
  /// **'পর্যালোচনার অপেক্ষায় কিছু নেই'**
  String get expertQueueEmpty;

  /// No description provided for @expertQueueEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত নয় এমন ছবি এলে এখানে দেখা যাবে।'**
  String get expertQueueEmptyBody;

  /// No description provided for @expertResolved.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন'**
  String get expertResolved;

  /// No description provided for @expertNeedsRetake.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ছবি দরকার'**
  String get expertNeedsRetake;

  /// No description provided for @expertAiGuess.
  ///
  /// In bn, this message translates to:
  /// **'AI-এর অনুমান (কৃষক দেখেন না)'**
  String get expertAiGuess;

  /// No description provided for @expertConfirmDisease.
  ///
  /// In bn, this message translates to:
  /// **'রোগ নিশ্চিত করুন'**
  String get expertConfirmDisease;

  /// No description provided for @expertPickDisease.
  ///
  /// In bn, this message translates to:
  /// **'কোন রোগটি?'**
  String get expertPickDisease;

  /// No description provided for @expertHealthy.
  ///
  /// In bn, this message translates to:
  /// **'সুস্থ'**
  String get expertHealthy;

  /// No description provided for @expertNote.
  ///
  /// In bn, this message translates to:
  /// **'কৃষকের জন্য নোট'**
  String get expertNote;

  /// No description provided for @expertCropUnknown.
  ///
  /// In bn, this message translates to:
  /// **'ফসল অজানা'**
  String get expertCropUnknown;

  /// No description provided for @expertRetakeTitle.
  ///
  /// In bn, this message translates to:
  /// **'কৃষককে কী জানাবেন?'**
  String get expertRetakeTitle;

  /// No description provided for @expertRetakeHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: দিনের আলোতে একটি পরিষ্কার পাতা তুলুন'**
  String get expertRetakeHint;

  /// No description provided for @expertSend.
  ///
  /// In bn, this message translates to:
  /// **'পাঠান'**
  String get expertSend;

  /// No description provided for @expertRequestSent.
  ///
  /// In bn, this message translates to:
  /// **'কৃষককে জানানো হয়েছে'**
  String get expertRequestSent;

  /// No description provided for @expertNewsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই তালিকায় কিছু নেই'**
  String get expertNewsEmpty;

  /// No description provided for @expertNewsEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'নতুন খসড়া এলে এখানে দেখা যাবে।'**
  String get expertNewsEmptyBody;

  /// No description provided for @draftNeedsWriting.
  ///
  /// In bn, this message translates to:
  /// **'লেখা দরকার'**
  String get draftNeedsWriting;

  /// No description provided for @draftInProgress.
  ///
  /// In bn, this message translates to:
  /// **'খসড়া'**
  String get draftInProgress;

  /// No description provided for @draftPublished.
  ///
  /// In bn, this message translates to:
  /// **'প্রকাশিত'**
  String get draftPublished;

  /// No description provided for @draftRejected.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যাত'**
  String get draftRejected;

  /// No description provided for @expertAddManual.
  ///
  /// In bn, this message translates to:
  /// **'নিজে খবর লিখুন'**
  String get expertAddManual;

  /// No description provided for @expertDraftCreated.
  ///
  /// In bn, this message translates to:
  /// **'খসড়া তৈরি হয়েছে'**
  String get expertDraftCreated;

  /// No description provided for @expertSuggestSource.
  ///
  /// In bn, this message translates to:
  /// **'নতুন সূত্রের প্রস্তাব'**
  String get expertSuggestSource;

  /// No description provided for @expertSourceSuggested.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাব অ্যাডমিনের কাছে পাঠানো হয়েছে'**
  String get expertSourceSuggested;

  /// No description provided for @expertSourceName.
  ///
  /// In bn, this message translates to:
  /// **'সূত্রের নাম'**
  String get expertSourceName;

  /// No description provided for @expertSourceUrl.
  ///
  /// In bn, this message translates to:
  /// **'ওয়েবসাইট'**
  String get expertSourceUrl;

  /// No description provided for @expertSourceNote.
  ///
  /// In bn, this message translates to:
  /// **'কেন দরকার (নোট)'**
  String get expertSourceNote;

  /// No description provided for @expertSendSuggestion.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাব পাঠান'**
  String get expertSendSuggestion;

  /// No description provided for @expertUrgent.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি'**
  String get expertUrgent;

  /// No description provided for @expertEditNews.
  ///
  /// In bn, this message translates to:
  /// **'খবর সম্পাদনা'**
  String get expertEditNews;

  /// No description provided for @expertNewsTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিরোনাম'**
  String get expertNewsTitle;

  /// No description provided for @expertNewsSummary.
  ///
  /// In bn, this message translates to:
  /// **'সারসংক্ষেপ'**
  String get expertNewsSummary;

  /// No description provided for @expertNewsSymptoms.
  ///
  /// In bn, this message translates to:
  /// **'লক্ষণ'**
  String get expertNewsSymptoms;

  /// No description provided for @expertNewsAction.
  ///
  /// In bn, this message translates to:
  /// **'কৃষক কী করবেন'**
  String get expertNewsAction;

  /// No description provided for @expertNewsSource.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র'**
  String get expertNewsSource;

  /// No description provided for @expertNewsCrop.
  ///
  /// In bn, this message translates to:
  /// **'ফসল'**
  String get expertNewsCrop;

  /// No description provided for @expertNewsCategory.
  ///
  /// In bn, this message translates to:
  /// **'ধরন'**
  String get expertNewsCategory;

  /// No description provided for @expertNewsSeverity.
  ///
  /// In bn, this message translates to:
  /// **'গুরুত্ব'**
  String get expertNewsSeverity;

  /// No description provided for @expertSaveDraft.
  ///
  /// In bn, this message translates to:
  /// **'খসড়া সংরক্ষণ করুন'**
  String get expertSaveDraft;

  /// No description provided for @expertPublish.
  ///
  /// In bn, this message translates to:
  /// **'প্রকাশ করুন'**
  String get expertPublish;

  /// No description provided for @expertPublishUrgent.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি হিসেবে প্রকাশ'**
  String get expertPublishUrgent;

  /// No description provided for @expertPublishTitle.
  ///
  /// In bn, this message translates to:
  /// **'কীভাবে প্রকাশ করবেন?'**
  String get expertPublishTitle;

  /// No description provided for @expertPublishBody.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি খবর কৃষকের ফোনে বিজ্ঞপ্তি হিসেবে যায়।'**
  String get expertPublishBody;

  /// No description provided for @expertPublished.
  ///
  /// In bn, this message translates to:
  /// **'প্রকাশিত হয়েছে'**
  String get expertPublished;

  /// No description provided for @expertReject.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যান'**
  String get expertReject;

  /// No description provided for @expertRejectTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যানের কারণ'**
  String get expertRejectTitle;

  /// No description provided for @expertRejectHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন: সূত্রে তথ্যটি নেই'**
  String get expertRejectHint;

  /// No description provided for @expertRejected.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যান করা হয়েছে'**
  String get expertRejected;

  /// No description provided for @expertKnowledgeSearch.
  ///
  /// In bn, this message translates to:
  /// **'রোগ বা নির্দেশনা খুঁজুন'**
  String get expertKnowledgeSearch;

  /// No description provided for @expertKnowledgeEmpty.
  ///
  /// In bn, this message translates to:
  /// **'জ্ঞানভাণ্ডারে কিছু নেই'**
  String get expertKnowledgeEmpty;

  /// No description provided for @expertKnowledgeEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'অন্য শব্দ দিয়ে খুঁজুন, অথবা নতুন রোগ যোগ হবে।'**
  String get expertKnowledgeEmptyBody;

  /// No description provided for @expertKnowledgeEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'জ্ঞানভাণ্ডার সম্পাদনা'**
  String get expertKnowledgeEditTitle;

  /// No description provided for @expertKnowledgeProtocol.
  ///
  /// In bn, this message translates to:
  /// **'চিকিৎসার ধাপ'**
  String get expertKnowledgeProtocol;

  /// No description provided for @expertKnowledgeSource.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র (BRRI, DAE…)'**
  String get expertKnowledgeSource;

  /// No description provided for @expertKnowledgeSafety.
  ///
  /// In bn, this message translates to:
  /// **'নিরাপত্তা নোট'**
  String get expertKnowledgeSafety;

  /// No description provided for @expertKnowledgeReindex.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ হয়েছে — নতুন তথ্য খোঁজার তালিকায় যোগ করা হচ্ছে।'**
  String get expertKnowledgeReindex;

  /// No description provided for @accountStatusActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get accountStatusActive;

  /// No description provided for @accountStatusPending.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get accountStatusPending;

  /// No description provided for @accountStatusSuspended.
  ///
  /// In bn, this message translates to:
  /// **'স্থগিত'**
  String get accountStatusSuspended;

  /// No description provided for @accountStatusRemoved.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা'**
  String get accountStatusRemoved;

  /// No description provided for @vendorPendingReview.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get vendorPendingReview;

  /// No description provided for @vendorRejected.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যাত'**
  String get vendorRejected;

  /// No description provided for @vendorSuspended.
  ///
  /// In bn, this message translates to:
  /// **'স্থগিত'**
  String get vendorSuspended;

  /// No description provided for @adminLicense.
  ///
  /// In bn, this message translates to:
  /// **'ট্রেড লাইসেন্স'**
  String get adminLicense;

  /// No description provided for @adminVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করুন'**
  String get adminVerify;

  /// No description provided for @adminReject.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যান'**
  String get adminReject;

  /// No description provided for @adminSuspend.
  ///
  /// In bn, this message translates to:
  /// **'স্থগিত করুন'**
  String get adminSuspend;

  /// No description provided for @adminResetPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড রিসেট করুন'**
  String get adminResetPassword;

  /// No description provided for @adminResetPasswordBody.
  ///
  /// In bn, this message translates to:
  /// **'এই অস্থায়ী পাসওয়ার্ডটি একবারই দেখা যাবে। ব্যবহারকারীকে জানিয়ে দিন, এবং লগইনের পর যেন অবশ্যই পাসওয়ার্ড বদলান।'**
  String get adminResetPasswordBody;

  /// No description provided for @adminReinstate.
  ///
  /// In bn, this message translates to:
  /// **'আবার চালু করুন'**
  String get adminReinstate;

  /// No description provided for @adminRejectTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যানের কারণ'**
  String get adminRejectTitle;

  /// No description provided for @adminSuspendTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্থগিত করার কারণ'**
  String get adminSuspendTitle;

  /// No description provided for @adminReasonHint.
  ///
  /// In bn, this message translates to:
  /// **'কারণটি ব্যবহারকারীকে জানানো হবে'**
  String get adminReasonHint;

  /// No description provided for @adminVendorUpdated.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতার অবস্থা বদলেছে'**
  String get adminVendorUpdated;

  /// No description provided for @adminVendorEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই তালিকায় বিক্রেতা নেই'**
  String get adminVendorEmpty;

  /// No description provided for @adminVendorEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'অন্য অবস্থা বেছে দেখুন।'**
  String get adminVendorEmptyBody;

  /// No description provided for @adminUserSearch.
  ///
  /// In bn, this message translates to:
  /// **'নাম, মোবাইল বা জেলা'**
  String get adminUserSearch;

  /// No description provided for @adminUserEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই শর্তে কেউ নেই'**
  String get adminUserEmpty;

  /// No description provided for @adminUserEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'খোঁজ বা ছাঁকনি বদলে দেখুন।'**
  String get adminUserEmptyBody;

  /// No description provided for @adminActivate.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয় করুন'**
  String get adminActivate;

  /// No description provided for @adminUserUpdated.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবহারকারীর অবস্থা বদলেছে'**
  String get adminUserUpdated;

  /// No description provided for @adminSourceEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো সূত্র যোগ করা হয়নি'**
  String get adminSourceEmpty;

  /// No description provided for @adminSourceEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'সংবাদ সূত্র যোগ করলে সংগ্রহ শুরু হবে।'**
  String get adminSourceEmptyBody;

  /// No description provided for @adminAddSource.
  ///
  /// In bn, this message translates to:
  /// **'নতুন সূত্র'**
  String get adminAddSource;

  /// No description provided for @adminEditSource.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র সম্পাদনা'**
  String get adminEditSource;

  /// No description provided for @adminSourceName.
  ///
  /// In bn, this message translates to:
  /// **'সূত্রের নাম'**
  String get adminSourceName;

  /// No description provided for @adminSourceUrl.
  ///
  /// In bn, this message translates to:
  /// **'ওয়েবসাইটের ঠিকানা'**
  String get adminSourceUrl;

  /// No description provided for @adminSourceUrlInvalid.
  ///
  /// In bn, this message translates to:
  /// **'ঠিকানাটি http দিয়ে শুরু হতে হবে।'**
  String get adminSourceUrlInvalid;

  /// No description provided for @adminSourceType.
  ///
  /// In bn, this message translates to:
  /// **'সূত্রের ধরন'**
  String get adminSourceType;

  /// No description provided for @adminSourceSaved.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র সংরক্ষণ হয়েছে'**
  String get adminSourceSaved;

  /// No description provided for @adminSourceOn.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহ চালু'**
  String get adminSourceOn;

  /// No description provided for @adminSourceOff.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহ বন্ধ'**
  String get adminSourceOff;

  /// No description provided for @adminSourceNeverRun.
  ///
  /// In bn, this message translates to:
  /// **'এখনো সংগ্রহ হয়নি'**
  String get adminSourceNeverRun;

  /// No description provided for @adminSourceFailed.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ সংগ্রহ ব্যর্থ'**
  String get adminSourceFailed;

  /// No description provided for @adminSourceDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'সূত্রটি মুছে ফেলবেন?'**
  String get adminSourceDeleteTitle;

  /// No description provided for @adminSourceRemoved.
  ///
  /// In bn, this message translates to:
  /// **'সূত্র মোছা হয়েছে'**
  String get adminSourceRemoved;

  /// No description provided for @adminScheduleTitle.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহের সময়সূচি'**
  String get adminScheduleTitle;

  /// No description provided for @adminScheduleEnabled.
  ///
  /// In bn, this message translates to:
  /// **'নিজে থেকে সংগ্রহ করবে'**
  String get adminScheduleEnabled;

  /// No description provided for @adminScheduleSaved.
  ///
  /// In bn, this message translates to:
  /// **'সময়সূচি সংরক্ষণ হয়েছে'**
  String get adminScheduleSaved;

  /// No description provided for @adminIntervalUp.
  ///
  /// In bn, this message translates to:
  /// **'সময় বাড়ান'**
  String get adminIntervalUp;

  /// No description provided for @adminIntervalDown.
  ///
  /// In bn, this message translates to:
  /// **'সময় কমান'**
  String get adminIntervalDown;

  /// No description provided for @adminRunNow.
  ///
  /// In bn, this message translates to:
  /// **'এখনই সংগ্রহ করুন'**
  String get adminRunNow;

  /// No description provided for @adminRunDone.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহ শেষ হয়েছে'**
  String get adminRunDone;

  /// No description provided for @adminLogsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই ধরনের লগ নেই'**
  String get adminLogsEmpty;

  /// No description provided for @adminLogsEmptyBody.
  ///
  /// In bn, this message translates to:
  /// **'অন্য ধরন বেছে দেখুন।'**
  String get adminLogsEmptyBody;

  /// No description provided for @logTypeSystem.
  ///
  /// In bn, this message translates to:
  /// **'সিস্টেম'**
  String get logTypeSystem;

  /// No description provided for @logTypeCollection.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহ'**
  String get logTypeCollection;

  /// No description provided for @logTypeVoice.
  ///
  /// In bn, this message translates to:
  /// **'ভয়েস'**
  String get logTypeVoice;

  /// No description provided for @logTypeAiFallback.
  ///
  /// In bn, this message translates to:
  /// **'AI ফলব্যাক'**
  String get logTypeAiFallback;

  /// No description provided for @logTypeAudit.
  ///
  /// In bn, this message translates to:
  /// **'নিরীক্ষা'**
  String get logTypeAudit;

  /// No description provided for @sourceTypeGovernment.
  ///
  /// In bn, this message translates to:
  /// **'সরকারি'**
  String get sourceTypeGovernment;

  /// No description provided for @sourceTypeResearch.
  ///
  /// In bn, this message translates to:
  /// **'গবেষণা'**
  String get sourceTypeResearch;

  /// No description provided for @sourceTypeNewsPortal.
  ///
  /// In bn, this message translates to:
  /// **'সংবাদমাধ্যম'**
  String get sourceTypeNewsPortal;

  /// No description provided for @vendorDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য মুছে ফেলবেন?'**
  String get vendorDeleteTitle;

  /// No description provided for @vendorStockLeft.
  ///
  /// In bn, this message translates to:
  /// **'স্টক {count}'**
  String vendorStockLeft(String count);

  /// No description provided for @vendorRatingAverage.
  ///
  /// In bn, this message translates to:
  /// **'গড় {rating} · {count} জনের রেটিং'**
  String vendorRatingAverage(String rating, String count);

  /// No description provided for @expertKnowledgeVersion.
  ///
  /// In bn, this message translates to:
  /// **'সংস্করণ {version}'**
  String expertKnowledgeVersion(String version);

  /// No description provided for @adminSubmitted.
  ///
  /// In bn, this message translates to:
  /// **'জমা {date}'**
  String adminSubmitted(String date);

  /// No description provided for @adminSourceLastRun.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ সংগ্রহ {time}'**
  String adminSourceLastRun(String time);

  /// No description provided for @adminSourceDeleteConfirm.
  ///
  /// In bn, this message translates to:
  /// **'{name} আর সংগ্রহ করা হবে না।'**
  String adminSourceDeleteConfirm(String name);

  /// No description provided for @adminScheduleInterval.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি {hours} ঘণ্টা পর'**
  String adminScheduleInterval(String hours);

  /// No description provided for @adminScheduleNext.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী সংগ্রহ {time}'**
  String adminScheduleNext(String time);

  /// No description provided for @vendorDeleteConfirm.
  ///
  /// In bn, this message translates to:
  /// **'{name} মুছে ফেলা হবে। পুরনো অর্ডারে এর হিসাব থেকে যাবে।'**
  String vendorDeleteConfirm(String name);

  /// No description provided for @pendingPromise.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অনুরোধ যাচাই করা হচ্ছে — ২৪ ঘণ্টার মধ্যে জানিয়ে দেওয়া হবে।'**
  String get pendingPromise;

  /// No description provided for @pendingStepSubmitted.
  ///
  /// In bn, this message translates to:
  /// **'আবেদন জমা হয়েছে'**
  String get pendingStepSubmitted;

  /// No description provided for @pendingStepReview.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন যাচাই করছেন'**
  String get pendingStepReview;

  /// No description provided for @pendingStepReviewBody.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণত ২৪ ঘণ্টার মধ্যে।'**
  String get pendingStepReviewBody;

  /// No description provided for @pendingStepLive.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট চালু হবে'**
  String get pendingStepLive;

  /// No description provided for @registerApprovalNote.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি নতুন অ্যাকাউন্ট চালু হওয়ার আগে অ্যাডমিন যাচাই করেন। সাধারণত ২৪ ঘণ্টার কম সময় লাগে।'**
  String get registerApprovalNote;

  /// No description provided for @staffQuickActions.
  ///
  /// In bn, this message translates to:
  /// **'দ্রুত কাজ'**
  String get staffQuickActions;

  /// No description provided for @staffComingSoon.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারফেস প্রস্তুত — ব্যাকএন্ড এলে কল চালু হবে।'**
  String get staffComingSoon;

  /// No description provided for @staffCall.
  ///
  /// In bn, this message translates to:
  /// **'কল'**
  String get staffCall;

  /// No description provided for @staffMessage.
  ///
  /// In bn, this message translates to:
  /// **'বার্তা'**
  String get staffMessage;

  /// No description provided for @staffVideo.
  ///
  /// In bn, this message translates to:
  /// **'ভিডিও কল'**
  String get staffVideo;

  /// No description provided for @staffCompleted.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন'**
  String get staffCompleted;

  /// No description provided for @staffNeedsAction.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবস্থা নিন'**
  String get staffNeedsAction;

  /// No description provided for @vendorConsoleEyebrow.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতা কনসোল'**
  String get vendorConsoleEyebrow;

  /// No description provided for @vendorConsoleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আজকের অর্ডার, স্টক আর গ্রাহক — সব এক জায়গায়।'**
  String get vendorConsoleSubtitle;

  /// No description provided for @vendorProductsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি পণ্যের দাম, স্টক ও ছবি।'**
  String get vendorProductsSubtitle;

  /// No description provided for @vendorOrdersSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'গ্রহণ, পাঠানো ও ডেলিভারি — শুধু পরের সঠিক ধাপ।'**
  String get vendorOrdersSubtitle;

  /// No description provided for @vendorBusiness.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবসা'**
  String get vendorBusiness;

  /// No description provided for @vendorBusinessSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রি, লাভ, পেমেন্ট আর গ্রাহক খাতা।'**
  String get vendorBusinessSubtitle;

  /// No description provided for @vendorCustomerBook.
  ///
  /// In bn, this message translates to:
  /// **'গ্রাহক'**
  String get vendorCustomerBook;

  /// No description provided for @vendorCustomers.
  ///
  /// In bn, this message translates to:
  /// **'মোট গ্রাহক'**
  String get vendorCustomers;

  /// No description provided for @vendorRepeatCustomers.
  ///
  /// In bn, this message translates to:
  /// **'ফিরে আসা ক্রেতা'**
  String get vendorRepeatCustomers;

  /// No description provided for @vendorCustomerSearch.
  ///
  /// In bn, this message translates to:
  /// **'নাম, মোবাইল বা জেলা খুঁজুন'**
  String get vendorCustomerSearch;

  /// No description provided for @vendorFollowUpCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন গ্রাহকের ফলোআপ দরকার'**
  String vendorFollowUpCount(String count);

  /// No description provided for @vendorFollowUpBody.
  ///
  /// In bn, this message translates to:
  /// **'একটি ছোট কলই ক্রেতাকে অন্য দোকানে যাওয়া থেকে ধরে রাখে।'**
  String get vendorFollowUpBody;

  /// No description provided for @vendorFollowUpHint.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রাহককে ফলোআপ তালিকায় দেখান।'**
  String get vendorFollowUpHint;

  /// No description provided for @vendorMarkFollowUp.
  ///
  /// In bn, this message translates to:
  /// **'ফলোআপ দরকার'**
  String get vendorMarkFollowUp;

  /// No description provided for @vendorNoCustomers.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো গ্রাহক নেই'**
  String get vendorNoCustomers;

  /// No description provided for @vendorNoCustomersBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম অর্ডার ডেলিভারি হলে গ্রাহক এখানে দেখা যাবে।'**
  String get vendorNoCustomersBody;

  /// No description provided for @vendorCustomerNote.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তিগত নোট'**
  String get vendorCustomerNote;

  /// No description provided for @vendorNoteHint.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রাহক সম্পর্কে দোকান কী মনে রাখবে?'**
  String get vendorNoteHint;

  /// No description provided for @vendorNoteSaved.
  ///
  /// In bn, this message translates to:
  /// **'গ্রাহকের নোট সংরক্ষিত হয়েছে'**
  String get vendorNoteSaved;

  /// No description provided for @vendorLifetimeValue.
  ///
  /// In bn, this message translates to:
  /// **'মোট কেনাকাটা'**
  String get vendorLifetimeValue;

  /// No description provided for @vendorLastOrder.
  ///
  /// In bn, this message translates to:
  /// **'শেষ অর্ডার'**
  String get vendorLastOrder;

  /// No description provided for @vendorOrdersCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি অর্ডার'**
  String vendorOrdersCount(String count);

  /// No description provided for @vendorSegmentNew.
  ///
  /// In bn, this message translates to:
  /// **'নতুন'**
  String get vendorSegmentNew;

  /// No description provided for @vendorSegmentRepeat.
  ///
  /// In bn, this message translates to:
  /// **'ফিরে আসা'**
  String get vendorSegmentRepeat;

  /// No description provided for @vendorSegmentLoyal.
  ///
  /// In bn, this message translates to:
  /// **'নিয়মিত'**
  String get vendorSegmentLoyal;

  /// No description provided for @vendorSegmentAtRisk.
  ///
  /// In bn, this message translates to:
  /// **'ঝুঁকিতে'**
  String get vendorSegmentAtRisk;

  /// No description provided for @vendorMoney.
  ///
  /// In bn, this message translates to:
  /// **'হিসাব'**
  String get vendorMoney;

  /// No description provided for @vendorRevenue30.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রি (৩০ দিন)'**
  String get vendorRevenue30;

  /// No description provided for @vendorProfit30.
  ///
  /// In bn, this message translates to:
  /// **'লাভ (৩০ দিন)'**
  String get vendorProfit30;

  /// No description provided for @vendorCommission.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যাটফর্ম কমিশন'**
  String get vendorCommission;

  /// No description provided for @vendorPendingPayout.
  ///
  /// In bn, this message translates to:
  /// **'পাওনা টাকা'**
  String get vendorPendingPayout;

  /// No description provided for @vendorPayouts.
  ///
  /// In bn, this message translates to:
  /// **'পেমেন্ট ইতিহাস'**
  String get vendorPayouts;

  /// No description provided for @vendorPayoutPaid.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধিত'**
  String get vendorPayoutPaid;

  /// No description provided for @vendorTopProducts.
  ///
  /// In bn, this message translates to:
  /// **'সবচেয়ে বিক্রি হওয়া পণ্য'**
  String get vendorTopProducts;

  /// No description provided for @vendorUnits.
  ///
  /// In bn, this message translates to:
  /// **'{units}টি ইউনিট'**
  String vendorUnits(String units);

  /// No description provided for @vendorWeekSales.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহের বিক্রি'**
  String get vendorWeekSales;

  /// No description provided for @vendorStoreVisits.
  ///
  /// In bn, this message translates to:
  /// **'দোকান ভিজিট'**
  String get vendorStoreVisits;

  /// No description provided for @vendorConversion.
  ///
  /// In bn, this message translates to:
  /// **'কনভার্শন'**
  String get vendorConversion;

  /// No description provided for @vendorOrders30.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার (৩০ দিন)'**
  String get vendorOrders30;

  /// No description provided for @vendorReviewPending.
  ///
  /// In bn, this message translates to:
  /// **'আপনার দোকান অনুমোদনের অপেক্ষায়। পণ্য প্রস্তুত করতে পারেন, তবে লাইসেন্স যাচাই না হলে কিছু প্রকাশ হবে না।'**
  String get vendorReviewPending;

  /// No description provided for @vendorPhotoLink.
  ///
  /// In bn, this message translates to:
  /// **'ছবির লিংক'**
  String get vendorPhotoLink;

  /// No description provided for @vendorPhotoHint.
  ///
  /// In bn, this message translates to:
  /// **'https://… (ঐচ্ছিক)'**
  String get vendorPhotoHint;

  /// No description provided for @vendorPhotoSoon.
  ///
  /// In bn, this message translates to:
  /// **'ক্যামেরা আপলোড ব্যাকএন্ড এলে আসবে; এখন লিংক দিয়ে প্রিভিউ দেখা যায়।'**
  String get vendorPhotoSoon;

  /// No description provided for @vendorPhotoRemove.
  ///
  /// In bn, this message translates to:
  /// **'ছবি সরান'**
  String get vendorPhotoRemove;

  /// No description provided for @expertHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get expertHome;

  /// No description provided for @expertConsoleEyebrow.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞ স্টুডিও'**
  String get expertConsoleEyebrow;

  /// No description provided for @expertConsoleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার লেখা, উত্তর আর পরামর্শই আপনার পরিচয় গড়ে।'**
  String get expertConsoleSubtitle;

  /// No description provided for @expertFeed.
  ///
  /// In bn, this message translates to:
  /// **'ফিড'**
  String get expertFeed;

  /// No description provided for @expertQuestions.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন'**
  String get expertQuestions;

  /// No description provided for @expertConsultations.
  ///
  /// In bn, this message translates to:
  /// **'পরামর্শ'**
  String get expertConsultations;

  /// No description provided for @expertStudio.
  ///
  /// In bn, this message translates to:
  /// **'স্টুডিও'**
  String get expertStudio;

  /// No description provided for @expertStudioSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'রিভিউ, কৃষি বার্তা ও জ্ঞানভাণ্ডার।'**
  String get expertStudioSubtitle;

  /// No description provided for @expertQuestionsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কৃষকরা মানুষের উত্তর চাইছেন, লেখা নয়।'**
  String get expertQuestionsSubtitle;

  /// No description provided for @expertConsultationsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যান, বুকিং আর বিশেষজ্ঞ নেটওয়ার্ক।'**
  String get expertConsultationsSubtitle;

  /// No description provided for @expertReviewsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কম আত্মবিশ্বাসের রোগ নির্ণয় আপনার কাছে।'**
  String get expertReviewsSubtitle;

  /// No description provided for @expertNewsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বার্তা যাচাই, সম্পাদনা ও প্রকাশ।'**
  String get expertNewsSubtitle;

  /// No description provided for @expertKnowledgeSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি উত্তরের পেছনের যাচাই করা নির্দেশনা।'**
  String get expertKnowledgeSubtitle;

  /// No description provided for @expertWrite.
  ///
  /// In bn, this message translates to:
  /// **'লেখা লিখুন'**
  String get expertWrite;

  /// No description provided for @expertArticleTitle.
  ///
  /// In bn, this message translates to:
  /// **'শিরোনাম'**
  String get expertArticleTitle;

  /// No description provided for @expertArticleSummary.
  ///
  /// In bn, this message translates to:
  /// **'এক লাইনের সারসংক্ষেপ'**
  String get expertArticleSummary;

  /// No description provided for @expertArticleBody.
  ///
  /// In bn, this message translates to:
  /// **'পুরো লেখা'**
  String get expertArticleBody;

  /// No description provided for @expertArticleCrop.
  ///
  /// In bn, this message translates to:
  /// **'ফসল'**
  String get expertArticleCrop;

  /// No description provided for @expertArticlePublished.
  ///
  /// In bn, this message translates to:
  /// **'লেখাটি কৃষকের ফিডে প্রকাশিত হয়েছে'**
  String get expertArticlePublished;

  /// No description provided for @expertMine.
  ///
  /// In bn, this message translates to:
  /// **'আপনার'**
  String get expertMine;

  /// No description provided for @expertAllArticles.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get expertAllArticles;

  /// No description provided for @expertMyArticles.
  ///
  /// In bn, this message translates to:
  /// **'আমার লেখা'**
  String get expertMyArticles;

  /// No description provided for @expertSaved.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত'**
  String get expertSaved;

  /// No description provided for @expertNoArticles.
  ///
  /// In bn, this message translates to:
  /// **'এখানে এখনো কোনো লেখা নেই'**
  String get expertNoArticles;

  /// No description provided for @expertNoArticlesBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম লেখাটি লিখুন — কৃষকরা কৃষি বার্তায় দেখবেন।'**
  String get expertNoArticlesBody;

  /// No description provided for @expertLike.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ'**
  String get expertLike;

  /// No description provided for @expertUnlike.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ সরান'**
  String get expertUnlike;

  /// No description provided for @expertSave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ'**
  String get expertSave;

  /// No description provided for @expertUnsave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ থেকে সরান'**
  String get expertUnsave;

  /// No description provided for @expertRateArticle.
  ///
  /// In bn, this message translates to:
  /// **'লেখাটি রেট দিন'**
  String get expertRateArticle;

  /// No description provided for @expertRateStars.
  ///
  /// In bn, this message translates to:
  /// **'{stars} স্টার'**
  String expertRateStars(int stars);

  /// No description provided for @expertRatingThanks.
  ///
  /// In bn, this message translates to:
  /// **'ধন্যবাদ — আপনার রেটিং সংরক্ষিত হয়েছে।'**
  String get expertRatingThanks;

  /// No description provided for @expertCommentsCount.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য ({count})'**
  String expertCommentsCount(String count);

  /// No description provided for @expertNoComments.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো মন্তব্য নেই। আলোচনা শুরু করুন।'**
  String get expertNoComments;

  /// No description provided for @expertAddComment.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য লিখুন'**
  String get expertAddComment;

  /// No description provided for @expertViewsCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন পড়েছেন'**
  String expertViewsCount(String count);

  /// No description provided for @expertReadArticle.
  ///
  /// In bn, this message translates to:
  /// **'লেখা'**
  String get expertReadArticle;

  /// No description provided for @expertPendingQuestions.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন কৃষক আপনার অপেক্ষায়'**
  String expertPendingQuestions(String count);

  /// No description provided for @expertAnswerNow.
  ///
  /// In bn, this message translates to:
  /// **'এখনই উত্তর দিন'**
  String get expertAnswerNow;

  /// No description provided for @expertOpenTab.
  ///
  /// In bn, this message translates to:
  /// **'খোলা ({count})'**
  String expertOpenTab(int count);

  /// No description provided for @expertAnsweredTab.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর দেওয়া ({count})'**
  String expertAnsweredTab(int count);

  /// No description provided for @expertNoQuestions.
  ///
  /// In bn, this message translates to:
  /// **'কোনো খোলা প্রশ্ন নেই'**
  String get expertNoQuestions;

  /// No description provided for @expertNoQuestionsBody.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কৃষকের অনুরোধ এখানে আসবে। সাবস্ক্রাইবাররা অগ্রাধিকার পান।'**
  String get expertNoQuestionsBody;

  /// No description provided for @expertAnswer.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর দিন'**
  String get expertAnswer;

  /// No description provided for @expertAnsweredNow.
  ///
  /// In bn, this message translates to:
  /// **'উত্তর কৃষকের কাছে পাঠানো হয়েছে'**
  String get expertAnsweredNow;

  /// No description provided for @expertReplyHint.
  ///
  /// In bn, this message translates to:
  /// **'বাংলায় উত্তর দিন, পরের ধাপটি বলে দিন…'**
  String get expertReplyHint;

  /// No description provided for @expertModeMessage.
  ///
  /// In bn, this message translates to:
  /// **'বার্তা'**
  String get expertModeMessage;

  /// No description provided for @expertModeCall.
  ///
  /// In bn, this message translates to:
  /// **'কল'**
  String get expertModeCall;

  /// No description provided for @expertModeVideo.
  ///
  /// In bn, this message translates to:
  /// **'ভিডিও'**
  String get expertModeVideo;

  /// No description provided for @expertEditorialTools.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনার হাতিয়ার'**
  String get expertEditorialTools;

  /// No description provided for @expertReviewQueue.
  ///
  /// In bn, this message translates to:
  /// **'রিভিউ কিউ'**
  String get expertReviewQueue;

  /// No description provided for @expertReviewQueueBody.
  ///
  /// In bn, this message translates to:
  /// **'কম আত্মবিশ্বাসের রোগ নির্ণয়'**
  String get expertReviewQueueBody;

  /// No description provided for @expertNewsPipeline.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বার্তা পাইপলাইন'**
  String get expertNewsPipeline;

  /// No description provided for @expertNewsPipelineBody.
  ///
  /// In bn, this message translates to:
  /// **'খসড়া, প্রকাশ ও প্রত্যাখ্যান'**
  String get expertNewsPipelineBody;

  /// No description provided for @expertKnowledgeBase.
  ///
  /// In bn, this message translates to:
  /// **'জ্ঞানভাণ্ডার'**
  String get expertKnowledgeBase;

  /// No description provided for @expertKnowledgeBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি নির্ণয়ের পেছনের নির্দেশনা'**
  String get expertKnowledgeBody;

  /// No description provided for @expertInbox.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ইনবক্স'**
  String get expertInbox;

  /// No description provided for @expertTotalViews.
  ///
  /// In bn, this message translates to:
  /// **'মোট পাঠ'**
  String get expertTotalViews;

  /// No description provided for @expertEarnings.
  ///
  /// In bn, this message translates to:
  /// **'আয়'**
  String get expertEarnings;

  /// No description provided for @expertSubscribers.
  ///
  /// In bn, this message translates to:
  /// **'সাবস্ক্রাইবার'**
  String get expertSubscribers;

  /// No description provided for @expertSubscribersCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} জন সাবস্ক্রাইবার'**
  String expertSubscribersCount(String count);

  /// No description provided for @expertFollowers.
  ///
  /// In bn, this message translates to:
  /// **'ফলোয়ার'**
  String get expertFollowers;

  /// No description provided for @expertFollowersCount.
  ///
  /// In bn, this message translates to:
  /// **'{count} ফলোয়ার'**
  String expertFollowersCount(String count);

  /// No description provided for @expertRating.
  ///
  /// In bn, this message translates to:
  /// **'রেটিং'**
  String get expertRating;

  /// No description provided for @expertResponseTime.
  ///
  /// In bn, this message translates to:
  /// **'উত্তরের সময়'**
  String get expertResponseTime;

  /// No description provided for @expertMinutesShort.
  ///
  /// In bn, this message translates to:
  /// **'{value} মিনিট'**
  String expertMinutesShort(String value);

  /// No description provided for @expertMinutes.
  ///
  /// In bn, this message translates to:
  /// **'{value} মিনিট'**
  String expertMinutes(String value);

  /// No description provided for @expertPlans.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যান'**
  String get expertPlans;

  /// No description provided for @expertCalls.
  ///
  /// In bn, this message translates to:
  /// **'কল'**
  String get expertCalls;

  /// No description provided for @expertPerPeriod.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি {period}'**
  String expertPerPeriod(String period);

  /// No description provided for @expertPlanActive.
  ///
  /// In bn, this message translates to:
  /// **'চালু'**
  String get expertPlanActive;

  /// No description provided for @expertPlanPaused.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ'**
  String get expertPlanPaused;

  /// No description provided for @expertJoinCall.
  ///
  /// In bn, this message translates to:
  /// **'কলে যোগ দিন'**
  String get expertJoinCall;

  /// No description provided for @expertNoCalls.
  ///
  /// In bn, this message translates to:
  /// **'কোনো কল বুক হয়নি'**
  String get expertNoCalls;

  /// No description provided for @expertNoCallsBody.
  ///
  /// In bn, this message translates to:
  /// **'কৃষকরা আপনার প্রোফাইল থেকে কল বুক করতে পারেন।'**
  String get expertNoCallsBody;

  /// No description provided for @expertNetwork.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞ নেটওয়ার্ক'**
  String get expertNetwork;

  /// No description provided for @expertConnect.
  ///
  /// In bn, this message translates to:
  /// **'কানেক্ট'**
  String get expertConnect;

  /// No description provided for @expertConnected.
  ///
  /// In bn, this message translates to:
  /// **'সংযুক্ত'**
  String get expertConnected;

  /// No description provided for @expertConnectNow.
  ///
  /// In bn, this message translates to:
  /// **'সংযোগ করুন'**
  String get expertConnectNow;

  /// No description provided for @adminOverview.
  ///
  /// In bn, this message translates to:
  /// **'ওভারভিউ'**
  String get adminOverview;

  /// No description provided for @adminConsoleEyebrow.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যাটফর্ম নিয়ন্ত্রণ'**
  String get adminConsoleEyebrow;

  /// No description provided for @adminConsoleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন, মানুষ, বাজার আর সিস্টেম — এক জায়গা থেকে।'**
  String get adminConsoleSubtitle;

  /// No description provided for @adminApprovals.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get adminApprovals;

  /// No description provided for @adminApprovalBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি আবেদন, ২৪ ঘণ্টার প্রতিশ্রুতি সামনে রেখে।'**
  String get adminApprovalBody;

  /// No description provided for @adminSlaTitle.
  ///
  /// In bn, this message translates to:
  /// **'২৪ ঘণ্টার মধ্যে যাচাই'**
  String get adminSlaTitle;

  /// No description provided for @adminSlaBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনি অনুমোদন না দিলে বিক্রেতা ও বিশেষজ্ঞ কাজ করতে পারেন না। কিউ পুরনো আগে।'**
  String get adminSlaBody;

  /// No description provided for @adminVendorsTab.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতা'**
  String get adminVendorsTab;

  /// No description provided for @adminVendorApplications.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতার আবেদন'**
  String get adminVendorApplications;

  /// No description provided for @adminAccountApplications.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্টের আবেদন'**
  String get adminAccountApplications;

  /// No description provided for @adminAccountApplication.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্টের আবেদন'**
  String get adminAccountApplication;

  /// No description provided for @adminVendorApplication.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতার আবেদন'**
  String get adminVendorApplication;

  /// No description provided for @adminApprove.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get adminApprove;

  /// No description provided for @adminPendingTotal.
  ///
  /// In bn, this message translates to:
  /// **'কিউতে {count}টি আবেদন'**
  String adminPendingTotal(String count);

  /// No description provided for @adminApprovalFooter.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন দিলে অ্যাকাউন্ট সাথে সাথে চালু হয়। প্রত্যাখ্যানের কারণ আবেদনকারী দেখতে পান।'**
  String get adminApprovalFooter;

  /// No description provided for @adminApprovedNow.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদিত — অ্যাকাউন্ট চালু হয়েছে'**
  String get adminApprovedNow;

  /// No description provided for @adminRejectedNow.
  ///
  /// In bn, this message translates to:
  /// **'আবেদন প্রত্যাখ্যাত হয়েছে'**
  String get adminRejectedNow;

  /// No description provided for @adminNoApprovals.
  ///
  /// In bn, this message translates to:
  /// **'কিছু অপেক্ষা করছে না'**
  String get adminNoApprovals;

  /// No description provided for @adminNoApprovalsBody.
  ///
  /// In bn, this message translates to:
  /// **'নতুন আবেদন এখানে দেখা যাবে।'**
  String get adminNoApprovalsBody;

  /// No description provided for @adminApprovalsUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের তালিকাটি এখন লোড হয়নি'**
  String get adminApprovalsUnavailable;

  /// No description provided for @adminOpenApprovals.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন কিউ খুলুন'**
  String get adminOpenApprovals;

  /// No description provided for @adminApprovalQueue.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন কিউ'**
  String get adminApprovalQueue;

  /// No description provided for @adminPendingApprovalsCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি আবেদনে সিদ্ধান্ত দরকার'**
  String adminPendingApprovalsCount(String count);

  /// No description provided for @adminReviewWithin24h.
  ///
  /// In bn, this message translates to:
  /// **'২৪ ঘণ্টার সীমা'**
  String get adminReviewWithin24h;

  /// No description provided for @adminAllClear.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কাছে কিছু অপেক্ষা করছে না'**
  String get adminAllClear;

  /// No description provided for @adminGmv.
  ///
  /// In bn, this message translates to:
  /// **'মোট বিক্রি (৩০ দিন)'**
  String get adminGmv;

  /// No description provided for @adminLast30Days.
  ///
  /// In bn, this message translates to:
  /// **'৩০ দিন'**
  String get adminLast30Days;

  /// No description provided for @adminCommissionEarned.
  ///
  /// In bn, this message translates to:
  /// **'কমিশন আয়'**
  String get adminCommissionEarned;

  /// No description provided for @adminActiveUsers.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয় ব্যবহারকারী'**
  String get adminActiveUsers;

  /// No description provided for @adminNewUsers.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ব্যবহারকারী (৭ দিন)'**
  String get adminNewUsers;

  /// No description provided for @adminPlatformHealth.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যাটফর্মের গতি'**
  String get adminPlatformHealth;

  /// No description provided for @adminNeedsAttention.
  ///
  /// In bn, this message translates to:
  /// **'নজর দিন'**
  String get adminNeedsAttention;

  /// No description provided for @adminAllSystemsOk.
  ///
  /// In bn, this message translates to:
  /// **'সব সিস্টেম ঠিক আছে'**
  String get adminAllSystemsOk;

  /// No description provided for @adminAllSystemsOkBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি সক্রিয় সোর্স শেষ সংগ্রহ সফলভাবে করেছে।'**
  String get adminAllSystemsOkBody;

  /// No description provided for @adminSourceIssues.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি সংবাদ সোর্স ব্যর্থ হচ্ছে'**
  String adminSourceIssues(String count);

  /// No description provided for @adminSourceIssuesBody.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহকারী আবার চেষ্টা করছে; ত্রুটির জন্য সোর্স কনসোল খুলুন।'**
  String get adminSourceIssuesBody;

  /// No description provided for @adminManageSources.
  ///
  /// In bn, this message translates to:
  /// **'সোর্স দেখুন'**
  String get adminManageSources;

  /// No description provided for @adminRecentActivity.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক কার্যক্রম'**
  String get adminRecentActivity;

  /// No description provided for @adminMonitor.
  ///
  /// In bn, this message translates to:
  /// **'মনিটর'**
  String get adminMonitor;

  /// No description provided for @adminMonitorSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার, ক্যাটালগ ও প্রকাশিত কনটেন্ট — না বলা পর্যন্ত শুধু দেখা।'**
  String get adminMonitorSubtitle;

  /// No description provided for @adminOrders.
  ///
  /// In bn, this message translates to:
  /// **'অর্ডার'**
  String get adminOrders;

  /// No description provided for @adminCatalog.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটালগ'**
  String get adminCatalog;

  /// No description provided for @adminContent.
  ///
  /// In bn, this message translates to:
  /// **'কনটেন্ট'**
  String get adminContent;

  /// No description provided for @adminReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু মনিটরিং'**
  String get adminReadOnly;

  /// No description provided for @adminReadOnlyBody.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন সব অর্ডার দেখতে পারেন, কিন্তু নিজে কিনতে পারেন না — কেনা শুধু কৃষকের জন্য।'**
  String get adminReadOnlyBody;

  /// No description provided for @adminCatalogNote.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি পণ্য, প্রতিটি দোকান'**
  String get adminCatalogNote;

  /// No description provided for @adminCatalogNoteBody.
  ///
  /// In bn, this message translates to:
  /// **'নিয়ম ভাঙা পণ্য লুকান; দোকানের হিসাব থেকে যাবে।'**
  String get adminCatalogNoteBody;

  /// No description provided for @adminContentNote.
  ///
  /// In bn, this message translates to:
  /// **'প্রকাশিত কনটেন্ট'**
  String get adminContentNote;

  /// No description provided for @adminContentNoteBody.
  ///
  /// In bn, this message translates to:
  /// **'ভুল বা অনিরাপদ সংবাদ সরিয়ে নিন। সার্ভার লেখককে জানাবে।'**
  String get adminContentNoteBody;

  /// No description provided for @adminItems.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য'**
  String get adminItems;

  /// No description provided for @adminHidden.
  ///
  /// In bn, this message translates to:
  /// **'লুকানো'**
  String get adminHidden;

  /// No description provided for @adminHideProduct.
  ///
  /// In bn, this message translates to:
  /// **'লুকান'**
  String get adminHideProduct;

  /// No description provided for @adminShowProduct.
  ///
  /// In bn, this message translates to:
  /// **'প্রকাশ'**
  String get adminShowProduct;

  /// No description provided for @adminProductUpdated.
  ///
  /// In bn, this message translates to:
  /// **'পণ্যের অবস্থা বদলানো হয়েছে'**
  String get adminProductUpdated;

  /// No description provided for @adminTakeDown.
  ///
  /// In bn, this message translates to:
  /// **'সরিয়ে নিন'**
  String get adminTakeDown;

  /// No description provided for @adminRestore.
  ///
  /// In bn, this message translates to:
  /// **'ফিরিয়ে দিন'**
  String get adminRestore;

  /// No description provided for @adminContentUpdated.
  ///
  /// In bn, this message translates to:
  /// **'কনটেন্টের অবস্থা বদলানো হয়েছে'**
  String get adminContentUpdated;

  /// No description provided for @adminSystem.
  ///
  /// In bn, this message translates to:
  /// **'সিস্টেম'**
  String get adminSystem;

  /// No description provided for @adminSystemSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যাটফর্ম সেটিংস, সোর্স, লগ আর আপনার অ্যাকাউন্ট।'**
  String get adminSystemSubtitle;

  /// No description provided for @adminSettings.
  ///
  /// In bn, this message translates to:
  /// **'প্ল্যাটফর্ম সেটিংস'**
  String get adminSettings;

  /// No description provided for @adminCommissionPercent.
  ///
  /// In bn, this message translates to:
  /// **'কমিশন (%)'**
  String get adminCommissionPercent;

  /// No description provided for @adminCommissionHint.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি সম্পন্ন অর্ডারে, ০–৩০%।'**
  String get adminCommissionHint;

  /// No description provided for @adminCommissionInvalid.
  ///
  /// In bn, this message translates to:
  /// **'০ থেকে ৩০ এর মধ্যে সংখ্যা দিন'**
  String get adminCommissionInvalid;

  /// No description provided for @adminAutoApproveFarmers.
  ///
  /// In bn, this message translates to:
  /// **'কৃষক অ্যাকাউন্ট স্বয়ংক্রিয় অনুমোদন'**
  String get adminAutoApproveFarmers;

  /// No description provided for @adminAutoApproveFarmersHint.
  ///
  /// In bn, this message translates to:
  /// **'কৃষকরা কিউ এড়িয়ে যাবেন; বিক্রেতা ও বিশেষজ্ঞরা কখনো নয়।'**
  String get adminAutoApproveFarmersHint;

  /// No description provided for @adminMaintenance.
  ///
  /// In bn, this message translates to:
  /// **'মেইনটেন্যান্স মোড'**
  String get adminMaintenance;

  /// No description provided for @adminMaintenanceHint.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন ছাড়া সবাইকে মেইনটেন্যান্স বার্তা দেখাবে।'**
  String get adminMaintenanceHint;

  /// No description provided for @adminSupportPhone.
  ///
  /// In bn, this message translates to:
  /// **'সাপোর্ট নম্বর'**
  String get adminSupportPhone;

  /// No description provided for @adminBroadcast.
  ///
  /// In bn, this message translates to:
  /// **'সবাইকে বার্তা'**
  String get adminBroadcast;

  /// No description provided for @adminBroadcastHint.
  ///
  /// In bn, this message translates to:
  /// **'আপনি মুছে না ফেলা পর্যন্ত কৃষকের হোমে দেখা যাবে।'**
  String get adminBroadcastHint;

  /// No description provided for @adminSaveSettings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস সংরক্ষণ'**
  String get adminSaveSettings;

  /// No description provided for @adminSettingsSaved.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস সংরক্ষিত হয়েছে'**
  String get adminSettingsSaved;

  /// No description provided for @adminOperations.
  ///
  /// In bn, this message translates to:
  /// **'অপারেশন'**
  String get adminOperations;

  /// No description provided for @adminSourcesSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'সংগ্রহকারী কী পড়ে, কত ঘন ঘন।'**
  String get adminSourcesSubtitle;

  /// No description provided for @adminLogsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি সিস্টেম, সংগ্রহ ও অডিট ঘটনা।'**
  String get adminLogsSubtitle;

  /// No description provided for @adminVendorApprovals.
  ///
  /// In bn, this message translates to:
  /// **'বিক্রেতা অনুমোদন'**
  String get adminVendorApprovals;

  /// No description provided for @adminVendorApprovalsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'লাইসেন্স, স্থগিত ও পুনর্বহাল।'**
  String get adminVendorApprovalsSubtitle;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যেকোনো অ্যাকাউন্ট খুঁজুন, ফিল্টার করুন, ব্যবস্থা নিন।'**
  String get adminUsersSubtitle;

  /// No description provided for @advisoryTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞ পরামর্শ'**
  String get advisoryTitle;

  /// No description provided for @advisorySubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কৃষি বিশেষজ্ঞদের লেখা, যাচাই করা পরামর্শ।'**
  String get advisorySubtitle;

  /// No description provided for @homeTileAdvisory.
  ///
  /// In bn, this message translates to:
  /// **'পরামর্শ পড়ুন'**
  String get homeTileAdvisory;

  /// No description provided for @homeTileAdvisoryHint.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞদের লেখা'**
  String get homeTileAdvisoryHint;

  /// No description provided for @articleComments.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য'**
  String get articleComments;

  /// No description provided for @articleCommentHint.
  ///
  /// In bn, this message translates to:
  /// **'আপনার মন্তব্য লিখুন'**
  String get articleCommentHint;

  /// No description provided for @articleRate.
  ///
  /// In bn, this message translates to:
  /// **'রেটিং দিন'**
  String get articleRate;

  /// No description provided for @articleRated.
  ///
  /// In bn, this message translates to:
  /// **'ধন্যবাদ, রেটিং সংরক্ষিত হয়েছে'**
  String get articleRated;

  /// No description provided for @articleReads.
  ///
  /// In bn, this message translates to:
  /// **'বার পড়া হয়েছে'**
  String get articleReads;

  /// No description provided for @articleNoComments.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো মন্তব্য নেই।'**
  String get articleNoComments;

  /// No description provided for @askExpert.
  ///
  /// In bn, this message translates to:
  /// **'বিশেষজ্ঞকে প্রশ্ন করুন'**
  String get askExpert;

  /// No description provided for @askExpertHint.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ফসলের সমস্যাটি বিস্তারিত লিখুন'**
  String get askExpertHint;

  /// No description provided for @askExpertSent.
  ///
  /// In bn, this message translates to:
  /// **'প্রশ্ন পাঠানো হয়েছে। বিশেষজ্ঞ উত্তর দিলে জানানো হবে।'**
  String get askExpertSent;

  /// No description provided for @askExpertUrgent.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি'**
  String get askExpertUrgent;

  /// No description provided for @actionLike.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ'**
  String get actionLike;

  /// No description provided for @actionUnlike.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ সরান'**
  String get actionUnlike;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppL10nBn();
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
