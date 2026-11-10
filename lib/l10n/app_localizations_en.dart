// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AgriSense';

  @override
  String get appTagline => 'Your farming adviser, in your pocket';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSave => 'Save';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Go back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionReadAloud => 'Read aloud';

  @override
  String get actionStopReading => 'Stop reading';

  @override
  String get stateLoading => 'Just a moment…';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateEmptyBody => 'New items will show up here.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'Try again. If it keeps happening, check back later.';

  @override
  String get statePermissionTitle => 'Permission needed';

  @override
  String get statePermissionBody =>
      'Turn the permission on in Settings to continue.';

  @override
  String get statePermissionAction => 'Open settings';

  @override
  String get offlineBanner => 'No internet. Photos will upload later.';

  @override
  String offlineQueued(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText photos waiting',
      one: '1 photo waiting',
    );
    return '$_temp0';
  }

  @override
  String get aiBadge => 'AI';

  @override
  String get aiDisclaimer => 'This is guidance, not a final diagnosis.';

  @override
  String get aiMarksNotice => 'Orange items are produced by AI.';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get languageSubtitle => 'Pick the one you read most easily';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageContinue => 'Continue';

  @override
  String get languageSwitchLabel => 'Change language';

  @override
  String get consentTitle => 'Your permission is needed';

  @override
  String get consentSubtitle =>
      'We only use what you agree to, and you can change this any time.';

  @override
  String get consentPhotosTitle => 'Crop photos';

  @override
  String get consentPhotosBody =>
      'Photos are used to find the disease. Only you, an expert and an admin can see them.';

  @override
  String get consentLocationTitle => 'District';

  @override
  String get consentLocationBody =>
      'We need your district to match weather and news. We take the district only, never your address.';

  @override
  String get consentPhoneTitle => 'Mobile number';

  @override
  String get consentPhoneBody =>
      'Needed to keep your account and to tell you about orders.';

  @override
  String get consentVoiceTitle => 'Voice commands';

  @override
  String get consentVoiceBody =>
      'Speak in Bangla to control the app. Recordings are deleted once the command is understood.';

  @override
  String get consentAccept => 'I agree';

  @override
  String get consentDecline => 'Not now';

  @override
  String get obAccountTitle => 'Account';

  @override
  String get obAccountSubtitle =>
      'Log in if you already have an account, otherwise create one.';

  @override
  String get obLogin => 'Log in';

  @override
  String get obRegister => 'Create an account';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitle => 'Enter your mobile number and password';

  @override
  String get loginMobileLabel => 'Mobile number';

  @override
  String get loginMobileHint => '01XXXXXXXXX';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginSubmit => 'Log in';

  @override
  String get loginForgot => 'Forgot your password?';

  @override
  String get loginFailed => 'That number or password is not right.';

  @override
  String get roleTitle => 'Who are you?';

  @override
  String get roleSubtitle => 'Choose the one that matches your work';

  @override
  String get roleFarmer => 'Farmer';

  @override
  String get roleFarmerHint => 'To check crops and get advice';

  @override
  String get roleVendor => 'Vendor';

  @override
  String get roleVendorHint => 'To sell seeds, fertiliser and medicine';

  @override
  String get roleExpert => 'Agri expert';

  @override
  String get roleExpertHint => 'To advise and verify news';

  @override
  String get registerTitle => 'New account';

  @override
  String registerAs(String role) {
    return 'You are registering as: $role';
  }

  @override
  String get registerNameLabel => 'Your name';

  @override
  String get registerNameHint => 'Enter your full name';

  @override
  String get registerDistrictLabel => 'District';

  @override
  String get registerDistrictHint => 'Choose your district';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'At least 8 characters';

  @override
  String get registerPasswordRule => 'Use at least 8 characters.';

  @override
  String get registerPasswordWeak =>
      'Password must not be only numbers. Mix letters and numbers.';

  @override
  String get registerPasswordCommon =>
      'That password is too common. Choose something harder to guess.';

  @override
  String get registerPasswordHasMobile =>
      'Password must not contain your mobile number.';

  @override
  String get registerNameRequired => 'Please enter your name.';

  @override
  String get registerMobileRequired => 'Enter a valid 11-digit mobile number.';

  @override
  String get registerDistrictRequired => 'Please choose your district.';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get registerShopNameLabel => 'Shop name';

  @override
  String get registerLicenseLabel => 'Trade licence number';

  @override
  String get registerSpecializationLabel => 'Your specialisation';

  @override
  String get registerCertificationLabel => 'Certificate number';

  @override
  String get registerAlreadyHave => 'Already have an account?';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpBody(String mobile) {
    return 'Enter the 6-digit code sent to $mobile';
  }

  @override
  String get otpLabel => 'Code';

  @override
  String get otpHint => '6-digit code';

  @override
  String get otpSubmit => 'Verify';

  @override
  String get otpResend => 'Send the code again';

  @override
  String get otpInvalid => 'That code is not right. Please check it.';

  @override
  String get phoneRegistered => 'An account already exists for this number.';

  @override
  String get resetRequestBody =>
      'Enter your mobile number. In development, the reset code is printed in the API server log.';

  @override
  String get resetRequestAction => 'Request reset code';

  @override
  String resetCodeSent(String mobile) {
    return 'A reset code was issued for $mobile';
  }

  @override
  String get resetCodeLabel => 'Reset code';

  @override
  String get resetCodeHint => 'Code from the API server log';

  @override
  String get resetSubmit => 'Reset password';

  @override
  String get resetInvalid => 'That code is invalid or expired.';

  @override
  String get resetRequestFailed => 'Could not request a reset code. Try again.';

  @override
  String get resetDoneTitle => 'Password updated';

  @override
  String get resetDoneBody => 'Sign in with your new password.';

  @override
  String get resetDevNote =>
      'In development, the reset code is in the API server log.';

  @override
  String get pendingTitle => 'Waiting for approval';

  @override
  String get pendingBody =>
      'Your application is being checked. We will tell you once it is approved.';

  @override
  String get pendingCheckStatus => 'Check status';

  @override
  String get accountStatusSuspendedTitle => 'Account suspended';

  @override
  String get accountStatusSuspendedBody => 'Contact support to find out more.';

  @override
  String get navHome => 'Home';

  @override
  String get navMarket => 'Market';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDiagnosis => 'Check crop';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProducts => 'Products';

  @override
  String get navOrders => 'Orders';

  @override
  String get navReviews => 'Reviews';

  @override
  String get navNews => 'Krishi Barta';

  @override
  String get navKnowledge => 'Knowledge';

  @override
  String get navVendors => 'Vendors';

  @override
  String get navUsers => 'Users';

  @override
  String get navSources => 'Sources';

  @override
  String get navLogs => 'Logs';

  @override
  String homeGreeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeGreetingAnonymous => 'Welcome';

  @override
  String get homeSubtitle => 'What would you like to do?';

  @override
  String get homeWeatherUnavailable => 'Weather could not be loaded';

  @override
  String get homeWeatherReadAloud => 'Read the weather aloud';

  @override
  String get homeUrgentTitle => 'Urgent news';

  @override
  String get homeUrgentBody => 'There is an urgent alert for your crops.';

  @override
  String get homeUrgentAction => 'Read the news';

  @override
  String get homeTileCheckCrop => 'Check crop';

  @override
  String get homeTileCheckCropHint => 'Photograph a leaf to find the disease';

  @override
  String get homeTileAsk => 'Ask by voice';

  @override
  String get homeTileAskHint => 'Speak a question, hear the answer';

  @override
  String get homeTileAdvice => 'Crop advice';

  @override
  String get homeTileAdviceHint => 'By soil and season';

  @override
  String get homeTileWeather => 'Weather';

  @override
  String get homeTileWeatherHint => 'Rain and heat warnings';

  @override
  String get homeTileNews => 'Krishi Barta';

  @override
  String get homeTileNewsHint => 'News about new diseases and pests';

  @override
  String get homeTileMarket => 'Market';

  @override
  String get homeTileMarketHint => 'Products from verified vendors';

  @override
  String get homeContrastToggle => 'Sunlight mode';

  @override
  String get homeContrastToggleHint => 'Easier to read outdoors';

  @override
  String get homeRecentTitle => 'Recently checked';

  @override
  String get defaultUserName => 'Farmer';

  @override
  String get diagnosisCaptureTitle => 'Photograph the leaf';

  @override
  String get diagnosisCaptureSubtitle =>
      'Keep the affected leaf in the middle of the frame';

  @override
  String get diagnosisTipLight => 'Use good light';

  @override
  String get diagnosisTipCenter => 'One leaf, in the centre';

  @override
  String get diagnosisTipFocus => 'Retake if it looks blurry';

  @override
  String get diagnosisOpenCamera => 'Open camera';

  @override
  String get diagnosisFromGallery => 'Choose from gallery';

  @override
  String get diagnosisSelectCrop => 'Which crop?';

  @override
  String get diagnosisCropRice => 'Rice';

  @override
  String get diagnosisCropPotato => 'Potato';

  @override
  String get diagnosisCropTomato => 'Tomato';

  @override
  String get diagnosisCropUnknown => 'Not sure';

  @override
  String get diagnosisPreviewTitle => 'Check the photo';

  @override
  String get diagnosisPreviewBody =>
      'Send it if the photo is clear, otherwise take another.';

  @override
  String get diagnosisUsePhoto => 'Send this photo';

  @override
  String get diagnosisRetake => 'Take another';

  @override
  String get diagnosisProcessingTitle => 'AI is checking…';

  @override
  String get diagnosisProcessingBody =>
      'This takes a moment. Please keep the app open.';

  @override
  String get diagnosisQueuedTitle => 'Photo saved';

  @override
  String get diagnosisQueuedBody =>
      'It will be sent automatically once you are back online.';

  @override
  String get diagnosisResultTitle => 'Result';

  @override
  String get diagnosisConfidenceLabel => 'Confidence';

  @override
  String get diagnosisConfidenceHigh => 'Fairly confident';

  @override
  String get diagnosisConfidenceMedium => 'Somewhat confident';

  @override
  String get diagnosisConfidenceLow => 'Not confident';

  @override
  String get diagnosisTreatmentTitle => 'What to do';

  @override
  String get diagnosisReadAll => 'Read all steps aloud';

  @override
  String get diagnosisOrderMedicine => 'Order medicine';

  @override
  String get diagnosisAskQuestion => 'Ask a question';

  @override
  String get diagnosisSendToExpert => 'Send to an expert';

  @override
  String get diagnosisSentToExpert => 'Your photo has been sent to an expert.';

  @override
  String get diagnosisExpertReviewed => 'Verified by an expert';

  @override
  String get diagnosisLowTitle => 'Not sure enough';

  @override
  String get diagnosisNotLeafTitle => 'This is not a crop leaf';

  @override
  String get diagnosisNotLeafBody =>
      'We could not find a crop leaf in this photo. Move closer to the affected leaf, use good light, and keep the photo sharp.';

  @override
  String get diagnosisLowBody =>
      'The disease could not be identified from this photo, so no name is shown. Take a new photo, or send it to an expert.';

  @override
  String get diagnosisMediumCaution =>
      'I am not fully sure. If in doubt, ask an expert.';

  @override
  String get diagnosisHealthyTitle => 'This plant looks healthy';

  @override
  String get diagnosisSafetyTitle => 'Safety';

  @override
  String get diagnosisSafetyBody =>
      'Cover your nose and mouth when spraying, wash your hands and face afterwards, and keep chemicals away from children.';

  @override
  String get diagnosisHistoryTitle => 'Your previous photos';

  @override
  String get diagnosisHistoryEmptyTitle => 'No photos yet';

  @override
  String get diagnosisHistoryEmptyBody =>
      'Press the camera button to check your first leaf.';

  @override
  String get diagnosisShowTop3 => 'What the AI also considered';

  @override
  String get diagnosisFeedbackThanks =>
      'Thank you! Your feedback helps it learn.';

  @override
  String get weatherTitle => 'Weather';

  @override
  String get weatherHumidity => 'Humidity';

  @override
  String get weatherWind => 'Wind';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherForecastTitle => 'Next few days';

  @override
  String get weatherAlertsTitle => 'Alerts';

  @override
  String get weatherNoAlerts => 'No alerts right now';

  @override
  String weatherUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileEditTitle => 'Edit details';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileContrast => 'Sunlight mode';

  @override
  String get profileVoiceMode => 'Voice mode';

  @override
  String get profileVoiceModeHint => 'Results are read aloud automatically';

  @override
  String get profileNotifications => 'News alerts';

  @override
  String get profileConsent => 'Your permissions';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileLogoutConfirm => 'Do you want to log out?';

  @override
  String get profileDeleteAccount => 'Request account deletion';

  @override
  String get profileDeleteAccountConfirm =>
      'A request to delete your data will be sent. Are you sure?';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get profileSaved => 'Saved';

  @override
  String get voiceListening => 'Speak, I am listening';

  @override
  String get voiceProcessing => 'Understanding…';

  @override
  String voiceUnderstood(String text) {
    return 'You said: $text';
  }

  @override
  String get voiceCouldNotUnderstand => 'I did not understand that';

  @override
  String get voiceAskAgain => 'Please say it again';

  @override
  String get voiceCancel => 'Stop';

  @override
  String get voiceUseTouch => 'Use the buttons';

  @override
  String get voiceNoInternet =>
      'No internet, so voice is unavailable. You can still use the buttons.';

  @override
  String get voiceMicLabel => 'Control the app by voice';

  @override
  String get voiceConfirmationTitle => 'Please confirm';

  @override
  String get voiceConfirmationBody => 'I am about to place this order';

  @override
  String get productDescription => 'Product details';

  @override
  String get selectQuantity => 'How many?';

  @override
  String get orderConfirmTitle => 'Confirm the order';

  @override
  String get orderTotal => 'Total';

  @override
  String get orderServerTotalNote =>
      'The final total is calculated by the server.';

  @override
  String get orderPaymentMode => 'Payment';

  @override
  String get orderPaymentCod => 'Cash on delivery';

  @override
  String get orderPaymentDirect => 'Pay the vendor';

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get orderCannotCancel => 'This order can no longer be cancelled.';

  @override
  String get orderCancelTitle => 'Cancel this order?';

  @override
  String get orderOneVendorOnly =>
      'An order can only contain products from one vendor.';

  @override
  String get marketAllCategories => 'All categories';

  @override
  String get marketInStockOnly => 'In stock only';

  @override
  String get marketOutOfStock => 'Out of stock';

  @override
  String marketStockCount(String count) {
    return 'In stock: $count';
  }

  @override
  String get categorySeed => 'Seeds';

  @override
  String get categoryFertilizer => 'Fertiliser';

  @override
  String get categoryPesticide => 'Pesticide';

  @override
  String get categoryFungicide => 'Fungicide';

  @override
  String get categoryEquipment => 'Equipment';

  @override
  String get categoryOther => 'Other';

  @override
  String get vendorVerified => 'Verified vendor';

  @override
  String get vendorNotVerified => 'Not verified yet';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get severityUrgent => 'Urgent';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusShipped => 'Shipped';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusRejected => 'Rejected';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get syncQueued => 'Waiting';

  @override
  String get syncUploading => 'Uploading';

  @override
  String get syncSynced => 'Uploaded';

  @override
  String get syncFailed => 'Upload failed';

  @override
  String get newsCategoryDisease => 'Disease';

  @override
  String get newsCategoryPest => 'Pest';

  @override
  String get newsCategoryVirus => 'Virus';

  @override
  String get newsCategoryNutrient => 'Nutrient deficiency';

  @override
  String get newsCategoryWeather => 'Weather';

  @override
  String get newsCategoryMarket => 'Market price';

  @override
  String get newsCategoryAdvisory => 'Advisory';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBody => 'This part is still being built.';

  @override
  String get homeTileOrdersHint => 'Track what you bought';

  @override
  String get homeTileHistoryHint => 'Past photos and their advice';

  @override
  String get homeFieldPrompt => 'What\'s wrong in the field today?';

  @override
  String get homeFieldPromptHint => 'Photograph a leaf — advice in seconds';

  @override
  String get homeScanAction => 'Take a photo';

  @override
  String get homeRecentEmpty => 'No leaf checked yet';

  @override
  String get filterAll => 'All';

  @override
  String get filterUncertain => 'Not certain';

  @override
  String get profileAnimation => 'Animation';

  @override
  String get profileAnimationHint => 'The sky and crops move slowly';

  @override
  String get homeAnimationOn => 'Animation on';

  @override
  String get homeAnimationOff => 'Animation off';

  @override
  String get homeSkyRain => 'A rainy sky today';

  @override
  String get voiceNoSpeech =>
      'Voice cannot be used on this device. Type below, or use the buttons.';

  @override
  String get voiceTypeInstead => 'Can\'t speak? Type it here';

  @override
  String voiceOpening(String screen) {
    return 'Opening $screen';
  }

  @override
  String get voiceAnswerTitle => 'AI answer';

  @override
  String get voiceChooseProduct => 'Which product? Pick one below';

  @override
  String voiceFound(String term, String count) {
    return '$term: $count found';
  }

  @override
  String voiceWeatherSummary(String district, String temp, String condition) {
    return 'Today in $district: $temp degrees, $condition';
  }

  @override
  String voicePriceLine(String name, String price) {
    return '$name, $price';
  }

  @override
  String voicePlaceOrder(String product, String qty) {
    return 'I will order $qty of $product. Confirm if that is right.';
  }

  @override
  String get voiceConfirmYes => 'Yes, place the order';

  @override
  String get adviceTitle => 'Crop advice';

  @override
  String get adviceIntro =>
      'Tell me the soil and the season — I will match your district\'s weather and suggest three crops.';

  @override
  String get adviceSoil => 'Soil type';

  @override
  String get adviceSeason => 'Season';

  @override
  String get adviceSeasonAuto => 'This month\'s season';

  @override
  String get adviceDistrict => 'District';

  @override
  String get adviceAction => 'Get advice';

  @override
  String get adviceResultsTitle => 'Three crops for you';

  @override
  String get adviceWeatherIncluded => 'Your district\'s weather was included';

  @override
  String get adviceWeatherMissing =>
      'Weather could not be included — soil and season only';

  @override
  String adviceRank(String rank) {
    return 'Rank $rank';
  }

  @override
  String get adviceCalendar => 'Seasonal calendar';

  @override
  String get adviceSavedTitle => 'Earlier advice';

  @override
  String get adviceSavedEmpty => 'No advice has been taken yet.';

  @override
  String get adviceIntroShort => 'Pick a soil type, then get advice.';

  @override
  String get calendarTitle => 'Seasonal calendar';

  @override
  String get calendarPlanting => 'Sowing / planting';

  @override
  String get calendarHarvest => 'Harvest';

  @override
  String get calendarLegend => 'Shaded months have work in them';

  @override
  String get calendarEmpty => 'No calendar has been added for this crop yet.';

  @override
  String calendarMonth(String month) {
    return 'Month $month';
  }

  @override
  String get assistantTitle => 'Farming assistant';

  @override
  String get assistantIntro =>
      'Ask anything about crop disease, fertiliser or pests. Answers come from the verified knowledge base.';

  @override
  String get assistantAsk => 'Type your question';

  @override
  String get assistantMicHint => 'Speak your question';

  @override
  String get assistantListening => 'Listening…';

  @override
  String get assistantThinking => 'Looking for an answer…';

  @override
  String get assistantSources => 'Sources';

  @override
  String get assistantNoAnswerTitle => 'I do not have that answer';

  @override
  String get assistantNoAnswerBody =>
      'I will not guess. Send it to an expert and an agronomist will reply.';

  @override
  String get assistantOfferExpert => 'Send to an expert';

  @override
  String get assistantSentToExpert =>
      'Your question has been sent to an expert.';

  @override
  String get assistantHistoryTitle => 'Earlier questions';

  @override
  String get assistantHistoryEmpty => 'No questions asked yet.';

  @override
  String assistantYouAsked(String question) {
    return 'You asked: $question';
  }

  @override
  String get adviceDisclaimer =>
      'This is advice, not a final recommendation. Check your own soil before deciding.';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get vendorAddProduct => 'Add product';

  @override
  String get vendorEditProduct => 'Edit product';

  @override
  String get vendorProductName => 'Product name';

  @override
  String get vendorProductNameBn => 'Name (Bangla)';

  @override
  String get vendorProductCategory => 'Category';

  @override
  String get vendorProductPrice => 'Price (taka)';

  @override
  String get vendorProductStock => 'Stock';

  @override
  String get vendorProductDescription => 'Description';

  @override
  String get vendorProductSaved => 'Product saved';

  @override
  String get vendorProductDeleted => 'Product removed';

  @override
  String get vendorFieldRequired => 'This field is required.';

  @override
  String get vendorPriceInvalid => 'Price must be more than zero.';

  @override
  String get vendorStockInvalid => 'Stock must be zero or more.';

  @override
  String get vendorLowStock => 'Low stock';

  @override
  String get vendorOutOfStock => 'Out of stock';

  @override
  String get vendorStockMinus => 'Decrease by one';

  @override
  String get vendorStockPlus => 'Increase by one';

  @override
  String get vendorStockFine => 'Every product is well stocked.';

  @override
  String get vendorLowStockTitle => 'Stock to watch';

  @override
  String get vendorNoProducts => 'No products yet';

  @override
  String get vendorNoProductsBody =>
      'Add your first product and farmers will see it in Haat Bazar.';

  @override
  String get vendorVerifiedHint =>
      'Your shop is verified — you can list products.';

  @override
  String get vendorBlockedBody =>
      'You can list products and accept orders once an admin has verified the shop.';

  @override
  String get vendorInvalidTransition => 'That step is not possible yet.';

  @override
  String get vendorTodayOrders => 'Today\'s orders';

  @override
  String get vendorTodayRevenue => 'Today\'s revenue';

  @override
  String get vendorPendingOrders => 'Pending orders';

  @override
  String get vendorRatingsTitle => 'Buyer ratings';

  @override
  String get vendorRecentOrders => 'Recent orders';

  @override
  String get vendorNoOrders => 'No orders yet';

  @override
  String get vendorNoOrdersBody => 'Orders from farmers will appear here.';

  @override
  String get vendorOrderUpdated => 'Order status updated';

  @override
  String get vendorAcceptOrder => 'Accept order';

  @override
  String get vendorRejectOrder => 'Reject';

  @override
  String get vendorShipOrder => 'Mark shipped';

  @override
  String get vendorDeliverOrder => 'Mark delivered';

  @override
  String get vendorRejectTitle => 'Why is this order rejected?';

  @override
  String get vendorRejectHint => 'e.g. the item is out of stock';

  @override
  String expertTabPending(String count) {
    return 'Waiting ($count)';
  }

  @override
  String expertTabResolved(String count) {
    return 'Done ($count)';
  }

  @override
  String get expertQueueEmpty => 'Nothing waiting for review';

  @override
  String get expertQueueEmptyBody => 'Uncertain photos will show up here.';

  @override
  String get expertResolved => 'Done';

  @override
  String get expertNeedsRetake => 'Needs a new photo';

  @override
  String get expertAiGuess => 'AI\'s guess (the farmer never sees this)';

  @override
  String get expertConfirmDisease => 'Confirm the disease';

  @override
  String get expertPickDisease => 'Which disease is it?';

  @override
  String get expertHealthy => 'Healthy';

  @override
  String get expertNote => 'Note for the farmer';

  @override
  String get expertCropUnknown => 'Crop unknown';

  @override
  String get expertRetakeTitle => 'What should the farmer do?';

  @override
  String get expertRetakeHint =>
      'e.g. take a clear photo of one leaf in daylight';

  @override
  String get expertSend => 'Send';

  @override
  String get expertRequestSent => 'The farmer was told';

  @override
  String get expertNewsEmpty => 'Nothing in this list';

  @override
  String get expertNewsEmptyBody => 'New drafts will appear here.';

  @override
  String get draftNeedsWriting => 'Needs writing';

  @override
  String get draftInProgress => 'Draft';

  @override
  String get draftPublished => 'Published';

  @override
  String get draftRejected => 'Rejected';

  @override
  String get expertAddManual => 'Write a news item';

  @override
  String get expertDraftCreated => 'Draft created';

  @override
  String get expertSuggestSource => 'Suggest a source';

  @override
  String get expertSourceSuggested => 'Suggestion sent to the admin';

  @override
  String get expertSourceName => 'Source name';

  @override
  String get expertSourceUrl => 'Website';

  @override
  String get expertSourceNote => 'Why it is useful (note)';

  @override
  String get expertSendSuggestion => 'Send suggestion';

  @override
  String get expertUrgent => 'Urgent';

  @override
  String get expertEditNews => 'Edit news item';

  @override
  String get expertNewsTitle => 'Title';

  @override
  String get expertNewsSummary => 'Summary';

  @override
  String get expertNewsSymptoms => 'Symptoms';

  @override
  String get expertNewsAction => 'What the farmer should do';

  @override
  String get expertNewsSource => 'Source';

  @override
  String get expertNewsCrop => 'Crop';

  @override
  String get expertNewsCategory => 'Category';

  @override
  String get expertNewsSeverity => 'Severity';

  @override
  String get expertSaveDraft => 'Save draft';

  @override
  String get expertPublish => 'Publish';

  @override
  String get expertPublishUrgent => 'Publish as urgent';

  @override
  String get expertPublishTitle => 'How should this be published?';

  @override
  String get expertPublishBody =>
      'Urgent items are pushed to farmers\' phones.';

  @override
  String get expertPublished => 'Published';

  @override
  String get expertReject => 'Reject';

  @override
  String get expertRejectTitle => 'Why is it rejected?';

  @override
  String get expertRejectHint => 'e.g. the source does not support this';

  @override
  String get expertRejected => 'Rejected';

  @override
  String get expertKnowledgeSearch => 'Search a disease or a protocol';

  @override
  String get expertKnowledgeEmpty => 'Nothing in the knowledge base';

  @override
  String get expertKnowledgeEmptyBody =>
      'Try another word, or wait for new entries.';

  @override
  String get expertKnowledgeEditTitle => 'Edit knowledge entry';

  @override
  String get expertKnowledgeProtocol => 'Treatment protocol';

  @override
  String get expertKnowledgeSource => 'Source (BRRI, DAE…)';

  @override
  String get expertKnowledgeSafety => 'Safety note';

  @override
  String get expertKnowledgeReindex =>
      'Saved — the change is being added to the search index.';

  @override
  String get accountStatusActive => 'Active';

  @override
  String get accountStatusPending => 'Pending approval';

  @override
  String get accountStatusSuspended => 'Suspended';

  @override
  String get accountStatusRemoved => 'Removed';

  @override
  String get vendorPendingReview => 'Awaiting approval';

  @override
  String get vendorRejected => 'Rejected';

  @override
  String get vendorSuspended => 'Suspended';

  @override
  String get adminLicense => 'Trade licence';

  @override
  String get adminVerify => 'Verify';

  @override
  String get adminReject => 'Reject';

  @override
  String get adminSuspend => 'Suspend';

  @override
  String get adminResetPassword => 'Reset password';

  @override
  String get adminResetPasswordBody =>
      'This temporary password is shown once. Give it to the user and ask them to change it after signing in.';

  @override
  String get adminReinstate => 'Reinstate';

  @override
  String get adminRejectTitle => 'Why is it rejected?';

  @override
  String get adminSuspendTitle => 'Why is it suspended?';

  @override
  String get adminReasonHint => 'The user will be told this reason';

  @override
  String get adminVendorUpdated => 'Vendor status updated';

  @override
  String get adminVendorEmpty => 'No vendors in this list';

  @override
  String get adminVendorEmptyBody => 'Try another status.';

  @override
  String get adminUserSearch => 'Name, mobile or district';

  @override
  String get adminUserEmpty => 'No accounts match';

  @override
  String get adminUserEmptyBody => 'Change the search or the filters.';

  @override
  String get adminActivate => 'Activate';

  @override
  String get adminUserUpdated => 'Account status updated';

  @override
  String get adminSourceEmpty => 'No sources added';

  @override
  String get adminSourceEmptyBody =>
      'Add a news source and collection can start.';

  @override
  String get adminAddSource => 'Add source';

  @override
  String get adminEditSource => 'Edit source';

  @override
  String get adminSourceName => 'Source name';

  @override
  String get adminSourceUrl => 'Feed URL';

  @override
  String get adminSourceUrlInvalid => 'The URL must start with http.';

  @override
  String get adminSourceType => 'Source type';

  @override
  String get adminSourceSaved => 'Source saved';

  @override
  String get adminSourceOn => 'Collection on';

  @override
  String get adminSourceOff => 'Collection off';

  @override
  String get adminSourceNeverRun => 'Never collected';

  @override
  String get adminSourceFailed => 'Last collection failed';

  @override
  String get adminSourceDeleteTitle => 'Remove this source?';

  @override
  String get adminSourceRemoved => 'Source removed';

  @override
  String get adminScheduleTitle => 'Collection schedule';

  @override
  String get adminScheduleEnabled => 'Collect automatically';

  @override
  String get adminScheduleSaved => 'Schedule saved';

  @override
  String get adminIntervalUp => 'Longer interval';

  @override
  String get adminIntervalDown => 'Shorter interval';

  @override
  String get adminRunNow => 'Collect now';

  @override
  String get adminRunDone => 'Collection finished';

  @override
  String get adminLogsEmpty => 'No logs of this kind';

  @override
  String get adminLogsEmptyBody => 'Try another type.';

  @override
  String get logTypeSystem => 'System';

  @override
  String get logTypeCollection => 'Collection';

  @override
  String get logTypeVoice => 'Voice';

  @override
  String get logTypeAiFallback => 'AI fallback';

  @override
  String get logTypeAudit => 'Audit';

  @override
  String get sourceTypeGovernment => 'Government';

  @override
  String get sourceTypeResearch => 'Research';

  @override
  String get sourceTypeNewsPortal => 'News portal';

  @override
  String get vendorDeleteTitle => 'Remove product?';

  @override
  String vendorStockLeft(String count) {
    return 'Stock $count';
  }

  @override
  String vendorRatingAverage(String rating, String count) {
    return 'Average $rating · $count ratings';
  }

  @override
  String expertKnowledgeVersion(String version) {
    return 'Version $version';
  }

  @override
  String adminSubmitted(String date) {
    return 'Submitted $date';
  }

  @override
  String adminSourceLastRun(String time) {
    return 'Last collected $time';
  }

  @override
  String adminSourceDeleteConfirm(String name) {
    return '$name will no longer be collected.';
  }

  @override
  String adminScheduleInterval(String hours) {
    return 'Every $hours hours';
  }

  @override
  String adminScheduleNext(String time) {
    return 'Next run $time';
  }

  @override
  String vendorDeleteConfirm(String name) {
    return '$name will be removed. Past orders keep their record.';
  }

  @override
  String get pendingPromise =>
      'Your request is being reviewed — we will let you know within 24 hours.';

  @override
  String get pendingStepSubmitted => 'Application received';

  @override
  String get pendingStepReview => 'An admin is reviewing it';

  @override
  String get pendingStepReviewBody => 'Usually within 24 hours.';

  @override
  String get pendingStepLive => 'Account activated';

  @override
  String get registerApprovalNote =>
      'Every new account is checked by an admin before it goes live. This usually takes under 24 hours.';

  @override
  String get staffQuickActions => 'Quick actions';

  @override
  String get staffComingSoon =>
      'The interface is ready — calling arrives with the backend.';

  @override
  String get staffCall => 'Call';

  @override
  String get staffMessage => 'Message';

  @override
  String get staffVideo => 'Video call';

  @override
  String get staffCompleted => 'Completed';

  @override
  String get staffNeedsAction => 'Needs action';

  @override
  String get vendorConsoleEyebrow => 'Vendor console';

  @override
  String get vendorConsoleSubtitle =>
      'Today\'s orders, stock and customers — all in one place.';

  @override
  String get vendorProductsSubtitle =>
      'Price, stock and photos for every listing.';

  @override
  String get vendorOrdersSubtitle =>
      'Accept, ship and deliver — only the next valid step.';

  @override
  String get vendorBusiness => 'Business';

  @override
  String get vendorBusinessSubtitle =>
      'Sales, profit, payouts and your customer book.';

  @override
  String get vendorCustomerBook => 'Customers';

  @override
  String get vendorCustomers => 'Total customers';

  @override
  String get vendorRepeatCustomers => 'Repeat buyers';

  @override
  String get vendorCustomerSearch => 'Search name, mobile or district';

  @override
  String vendorFollowUpCount(String count) {
    return '$count customers need a follow-up';
  }

  @override
  String get vendorFollowUpBody =>
      'A quick call keeps a buyer from drifting to another shop.';

  @override
  String get vendorFollowUpHint => 'Show this customer in the follow-up list.';

  @override
  String get vendorMarkFollowUp => 'Follow-up needed';

  @override
  String get vendorNoCustomers => 'No customers yet';

  @override
  String get vendorNoCustomersBody =>
      'A customer appears here after their first delivered order.';

  @override
  String get vendorCustomerNote => 'Private note';

  @override
  String get vendorNoteHint =>
      'What should the shop remember about this customer?';

  @override
  String get vendorNoteSaved => 'Customer note saved';

  @override
  String get vendorLifetimeValue => 'Lifetime value';

  @override
  String get vendorLastOrder => 'Last order';

  @override
  String vendorOrdersCount(String count) {
    return '$count orders';
  }

  @override
  String get vendorSegmentNew => 'New';

  @override
  String get vendorSegmentRepeat => 'Returning';

  @override
  String get vendorSegmentLoyal => 'Loyal';

  @override
  String get vendorSegmentAtRisk => 'At risk';

  @override
  String get vendorMoney => 'Money';

  @override
  String get vendorRevenue30 => 'Revenue (30 days)';

  @override
  String get vendorProfit30 => 'Profit (30 days)';

  @override
  String get vendorCommission => 'Platform commission';

  @override
  String get vendorPendingPayout => 'Pending payout';

  @override
  String get vendorPayouts => 'Payout history';

  @override
  String get vendorPayoutPaid => 'Paid';

  @override
  String get vendorTopProducts => 'Best sellers';

  @override
  String vendorUnits(String units) {
    return '$units units';
  }

  @override
  String get vendorWeekSales => 'Sales this week';

  @override
  String get vendorStoreVisits => 'Store visits';

  @override
  String get vendorConversion => 'Conversion';

  @override
  String get vendorOrders30 => 'Orders (30 days)';

  @override
  String get vendorReviewPending =>
      'Your shop is in the approval queue. You can prepare listings, but nothing goes live until an admin verifies the licence.';

  @override
  String get vendorPhotoLink => 'Photo link';

  @override
  String get vendorPhotoHint => 'https://… (optional)';

  @override
  String get vendorPhotoSoon =>
      'Upload from the camera arrives with the backend; a link previews now.';

  @override
  String get vendorPhotoRemove => 'Remove photo';

  @override
  String get expertHome => 'Home';

  @override
  String get expertConsoleEyebrow => 'Expert studio';

  @override
  String get expertConsoleSubtitle =>
      'Your writing, answers and consultations build your reputation.';

  @override
  String get expertFeed => 'Feed';

  @override
  String get expertQuestions => 'Questions';

  @override
  String get expertConsultations => 'Consultations';

  @override
  String get expertStudio => 'Studio';

  @override
  String get expertStudioSubtitle =>
      'Reviews, Krishi Barta and the knowledge base.';

  @override
  String get expertQuestionsSubtitle =>
      'Farmers waiting for a person, not an article.';

  @override
  String get expertConsultationsSubtitle =>
      'Plans, bookings and your expert network.';

  @override
  String get expertReviewsSubtitle => 'Low-confidence diagnoses routed to you.';

  @override
  String get expertNewsSubtitle => 'Review, edit and publish Krishi Barta.';

  @override
  String get expertKnowledgeSubtitle =>
      'The verified protocol behind every answer.';

  @override
  String get expertWrite => 'Write an article';

  @override
  String get expertArticleTitle => 'Title';

  @override
  String get expertArticleSummary => 'One-line summary';

  @override
  String get expertArticleBody => 'Full article';

  @override
  String get expertArticleCrop => 'Crop';

  @override
  String get expertArticlePublished => 'Article published to the farmer feed';

  @override
  String get expertMine => 'Yours';

  @override
  String get expertAllArticles => 'All';

  @override
  String get expertMyArticles => 'My articles';

  @override
  String get expertSaved => 'Saved';

  @override
  String get expertNoArticles => 'No articles here yet';

  @override
  String get expertNoArticlesBody =>
      'Write the first one — farmers see it in Krishi Barta.';

  @override
  String get expertLike => 'Like';

  @override
  String get expertUnlike => 'Remove like';

  @override
  String get expertSave => 'Save';

  @override
  String get expertUnsave => 'Remove from saved';

  @override
  String get expertRateArticle => 'Rate this article';

  @override
  String expertRateStars(int stars) {
    return '$stars star';
  }

  @override
  String get expertRatingThanks => 'Thanks — your rating was recorded.';

  @override
  String expertCommentsCount(String count) {
    return 'Comments ($count)';
  }

  @override
  String get expertNoComments => 'No comments yet. Start the conversation.';

  @override
  String get expertAddComment => 'Write a comment';

  @override
  String expertViewsCount(String count) {
    return '$count views';
  }

  @override
  String get expertReadArticle => 'Article';

  @override
  String expertPendingQuestions(String count) {
    return '$count farmers are waiting for you';
  }

  @override
  String get expertAnswerNow => 'Answer now';

  @override
  String expertOpenTab(int count) {
    return 'Open ($count)';
  }

  @override
  String expertAnsweredTab(int count) {
    return 'Answered ($count)';
  }

  @override
  String get expertNoQuestions => 'No open questions';

  @override
  String get expertNoQuestionsBody =>
      'New farmer requests land here. Subscribers get priority.';

  @override
  String get expertAnswer => 'Write an answer';

  @override
  String get expertAnsweredNow => 'Answer sent to the farmer';

  @override
  String get expertReplyHint =>
      'Answer in Bangla, with the next step they should take…';

  @override
  String get expertModeMessage => 'Message';

  @override
  String get expertModeCall => 'Call';

  @override
  String get expertModeVideo => 'Video';

  @override
  String get expertEditorialTools => 'Editorial tools';

  @override
  String get expertReviewQueue => 'Review queue';

  @override
  String get expertReviewQueueBody => 'Low-confidence diagnoses';

  @override
  String get expertNewsPipeline => 'Krishi Barta pipeline';

  @override
  String get expertNewsPipelineBody => 'Drafts, publishing and rejections';

  @override
  String get expertKnowledgeBase => 'Knowledge base';

  @override
  String get expertKnowledgeBody => 'Protocols behind every diagnosis';

  @override
  String get expertInbox => 'Your inbox';

  @override
  String get expertTotalViews => 'Total reads';

  @override
  String get expertEarnings => 'Earnings';

  @override
  String get expertSubscribers => 'Subscribers';

  @override
  String expertSubscribersCount(String count) {
    return '$count subscribers';
  }

  @override
  String get expertFollowers => 'Followers';

  @override
  String expertFollowersCount(String count) {
    return '$count followers';
  }

  @override
  String get expertRating => 'Rating';

  @override
  String get expertResponseTime => 'Reply time';

  @override
  String expertMinutesShort(String value) {
    return '$value min';
  }

  @override
  String expertMinutes(String value) {
    return '$value min';
  }

  @override
  String get expertPlans => 'Plans';

  @override
  String get expertCalls => 'Calls';

  @override
  String expertPerPeriod(String period) {
    return 'per $period';
  }

  @override
  String get expertPlanActive => 'Live';

  @override
  String get expertPlanPaused => 'Paused';

  @override
  String get expertJoinCall => 'Join call';

  @override
  String get expertNoCalls => 'No calls booked';

  @override
  String get expertNoCallsBody => 'Farmers can book a call from your profile.';

  @override
  String get expertNetwork => 'Expert network';

  @override
  String get expertConnect => 'Connect';

  @override
  String get expertConnected => 'Connected';

  @override
  String get expertConnectNow => 'Connect now';

  @override
  String get adminOverview => 'Overview';

  @override
  String get adminConsoleEyebrow => 'Platform control';

  @override
  String get adminConsoleSubtitle =>
      'Approvals, people, the market and the system — from one place.';

  @override
  String get adminApprovals => 'Approvals';

  @override
  String get adminApprovalBody =>
      'Every application, with the 24-hour promise visible.';

  @override
  String get adminSlaTitle => 'Review within 24 hours';

  @override
  String get adminSlaBody =>
      'Vendors and experts cannot trade until you approve them. The queue is oldest-first.';

  @override
  String get adminVendorsTab => 'Vendors';

  @override
  String get adminVendorApplications => 'Vendor applications';

  @override
  String get adminAccountApplications => 'Account applications';

  @override
  String get adminAccountApplication => 'Account application';

  @override
  String get adminVendorApplication => 'Vendor application';

  @override
  String get adminApprove => 'Approve';

  @override
  String adminPendingTotal(String count) {
    return '$count applications in the queue';
  }

  @override
  String get adminApprovalFooter =>
      'Approving activates the account immediately. Rejections keep the reason for the applicant.';

  @override
  String get adminApprovedNow => 'Approved — the account is live';

  @override
  String get adminRejectedNow => 'Application rejected';

  @override
  String get adminNoApprovals => 'Nothing waiting';

  @override
  String get adminNoApprovalsBody => 'New applications will appear here.';

  @override
  String get adminApprovalsUnavailable =>
      'Pending approvals could not be loaded';

  @override
  String get adminOpenApprovals => 'Open the approval queue';

  @override
  String get adminApprovalQueue => 'Approval queue';

  @override
  String adminPendingApprovalsCount(String count) {
    return '$count applications need a decision';
  }

  @override
  String get adminReviewWithin24h => '24h SLA';

  @override
  String get adminAllClear => 'Nothing is waiting on you';

  @override
  String get adminGmv => 'Gross sales (30 days)';

  @override
  String get adminLast30Days => '30 days';

  @override
  String get adminCommissionEarned => 'Commission earned';

  @override
  String get adminActiveUsers => 'Active users';

  @override
  String get adminNewUsers => 'New users (7 days)';

  @override
  String get adminPlatformHealth => 'Platform pace';

  @override
  String get adminNeedsAttention => 'Needs attention';

  @override
  String get adminAllSystemsOk => 'All systems healthy';

  @override
  String get adminAllSystemsOkBody =>
      'Every active news source completed its last run.';

  @override
  String adminSourceIssues(String count) {
    return '$count news sources are failing';
  }

  @override
  String get adminSourceIssuesBody =>
      'The collector keeps retrying; open the source console for the error.';

  @override
  String get adminManageSources => 'Manage sources';

  @override
  String get adminRecentActivity => 'Recent activity';

  @override
  String get adminMonitor => 'Monitor';

  @override
  String get adminMonitorSubtitle =>
      'Orders, catalogue and published content — read-only unless noted.';

  @override
  String get adminOrders => 'Orders';

  @override
  String get adminCatalog => 'Catalogue';

  @override
  String get adminContent => 'Content';

  @override
  String get adminReadOnly => 'Monitoring only';

  @override
  String get adminReadOnlyBody =>
      'Admins can see every order but cannot place one — buying is farmer-only by design.';

  @override
  String get adminCatalogNote => 'Every listing, every shop';

  @override
  String get adminCatalogNoteBody =>
      'Hide a listing that breaks the rules; the shop keeps the record.';

  @override
  String get adminContentNote => 'Published content';

  @override
  String get adminContentNoteBody =>
      'Take down a story that is wrong or unsafe. The author is notified by the server.';

  @override
  String get adminItems => 'Items';

  @override
  String get adminHidden => 'Hidden';

  @override
  String get adminHideProduct => 'Hide';

  @override
  String get adminShowProduct => 'Show';

  @override
  String get adminProductUpdated => 'Listing updated';

  @override
  String get adminTakeDown => 'Take down';

  @override
  String get adminRestore => 'Restore';

  @override
  String get adminContentUpdated => 'Content updated';

  @override
  String get adminSystem => 'System';

  @override
  String get adminSystemSubtitle =>
      'Platform switches, sources, logs and your account.';

  @override
  String get adminSettings => 'Platform settings';

  @override
  String get adminCommissionPercent => 'Commission (%)';

  @override
  String get adminCommissionHint => 'Charged on each completed order, 0–30%.';

  @override
  String get adminCommissionInvalid => 'Enter a number from 0 to 30';

  @override
  String get adminAutoApproveFarmers => 'Auto-approve farmer accounts';

  @override
  String get adminAutoApproveFarmersHint =>
      'Farmers skip the queue; vendors and experts never do.';

  @override
  String get adminMaintenance => 'Maintenance mode';

  @override
  String get adminMaintenanceHint =>
      'Shows the maintenance notice to every role except admin.';

  @override
  String get adminSupportPhone => 'Support phone';

  @override
  String get adminBroadcast => 'Broadcast banner';

  @override
  String get adminBroadcastHint =>
      'Shown on the farmer home until you clear it.';

  @override
  String get adminSaveSettings => 'Save settings';

  @override
  String get adminSettingsSaved => 'Settings saved';

  @override
  String get adminOperations => 'Operations';

  @override
  String get adminSourcesSubtitle => 'What the collector reads, and how often.';

  @override
  String get adminLogsSubtitle => 'Every system, collection and audit event.';

  @override
  String get adminVendorApprovals => 'Vendor approvals';

  @override
  String get adminVendorApprovalsSubtitle =>
      'Licences, suspensions and reinstatements.';

  @override
  String get adminUsersSubtitle => 'Search, filter and act on any account.';

  @override
  String get advisoryTitle => 'Expert advice';

  @override
  String get advisorySubtitle =>
      'Verified guidance written by agricultural experts.';

  @override
  String get homeTileAdvisory => 'Read advice';

  @override
  String get homeTileAdvisoryHint => 'From the experts';

  @override
  String get articleComments => 'Comments';

  @override
  String get articleCommentHint => 'Write a comment';

  @override
  String get articleRate => 'Rate this';

  @override
  String get articleRated => 'Thanks, your rating was saved';

  @override
  String get articleReads => 'reads';

  @override
  String get articleNoComments => 'No comments yet.';

  @override
  String get askExpert => 'Ask an expert';

  @override
  String get askExpertHint => 'Describe your crop problem in detail';

  @override
  String get askExpertSent =>
      'Your question was sent. You will be notified when an expert answers.';

  @override
  String get askExpertUrgent => 'Urgent';

  @override
  String get actionLike => 'Like';

  @override
  String get actionUnlike => 'Remove like';
}
