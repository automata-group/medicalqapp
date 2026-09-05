import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Q'**
  String get appTitle;

  /// No description provided for @mockExams.
  ///
  /// In en, this message translates to:
  /// **'Mock Exams'**
  String get mockExams;

  /// No description provided for @noExamsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exams available at the moment.'**
  String get noExamsAvailable;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get minutes;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @startExam.
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get startExam;

  /// No description provided for @finishExam.
  ///
  /// In en, this message translates to:
  /// **'Finish Exam'**
  String get finishExam;

  /// No description provided for @continueRevision.
  ///
  /// In en, this message translates to:
  /// **'Continue Revision'**
  String get continueRevision;

  /// No description provided for @recentPractice.
  ///
  /// In en, this message translates to:
  /// **'Recent Practice'**
  String get recentPractice;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @performanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance Trend'**
  String get performanceTrend;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet. Keep practicing!'**
  String get noAchievements;

  /// No description provided for @startRevision.
  ///
  /// In en, this message translates to:
  /// **'Start Revision'**
  String get startRevision;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @examPassed.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get examPassed;

  /// No description provided for @examFailed.
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get examFailed;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @noResultData.
  ///
  /// In en, this message translates to:
  /// **'No result data available'**
  String get noResultData;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @startOffline.
  ///
  /// In en, this message translates to:
  /// **'Start Offline'**
  String get startOffline;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection is taking too long'**
  String get connectionTimeout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select Specialty'**
  String get selectSpecialty;

  /// No description provided for @searchSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Search for a specialty...'**
  String get searchSpecialty;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @questionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} Questions Available'**
  String questionsAvailable(int count);

  /// No description provided for @setStudyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Your Goal'**
  String get setStudyGoal;

  /// No description provided for @studyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define your exam date and study hours.'**
  String get studyGoalSubtitle;

  /// No description provided for @examDate.
  ///
  /// In en, this message translates to:
  /// **'Exam Date'**
  String get examDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @dailyStudyHours.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Hours'**
  String get dailyStudyHours;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeBack(String name);

  /// No description provided for @readyForChallenge.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s challenge?'**
  String get readyForChallenge;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @answeredQuestions.
  ///
  /// In en, this message translates to:
  /// **'You answered {count} questions this week'**
  String answeredQuestions(int count);

  /// No description provided for @medicalSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Medical Specialties'**
  String get medicalSpecialties;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @keepRevising.
  ///
  /// In en, this message translates to:
  /// **'Keep Revising'**
  String get keepRevising;

  /// No description provided for @quickExam.
  ///
  /// In en, this message translates to:
  /// **'Quick Exam'**
  String get quickExam;

  /// Progress message showing number of questions completed
  ///
  /// In en, this message translates to:
  /// **'{count}/100 questions'**
  String questionsProgress(int count);

  /// No description provided for @studyStreak.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get studyStreak;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// No description provided for @orthodontics.
  ///
  /// In en, this message translates to:
  /// **'Orthodontics'**
  String get orthodontics;

  /// No description provided for @endodontics.
  ///
  /// In en, this message translates to:
  /// **'Endodontics'**
  String get endodontics;

  /// No description provided for @prosthodontics.
  ///
  /// In en, this message translates to:
  /// **'Prosthodontics'**
  String get prosthodontics;

  /// No description provided for @periodontics.
  ///
  /// In en, this message translates to:
  /// **'Periodontics'**
  String get periodontics;

  /// No description provided for @pediatricDentistry.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Dentistry'**
  String get pediatricDentistry;

  /// No description provided for @restorative.
  ///
  /// In en, this message translates to:
  /// **'Restorative Dentistry'**
  String get restorative;

  /// No description provided for @dentalSurgery.
  ///
  /// In en, this message translates to:
  /// **'Dental Surgery'**
  String get dentalSurgery;

  /// No description provided for @oralSurgery.
  ///
  /// In en, this message translates to:
  /// **'Oral Surgery'**
  String get oralSurgery;

  /// No description provided for @infectionControl.
  ///
  /// In en, this message translates to:
  /// **'Sterilization and Infection Control'**
  String get infectionControl;

  /// No description provided for @oralMedicine.
  ///
  /// In en, this message translates to:
  /// **'Oral Medicine & Pathology'**
  String get oralMedicine;

  /// No description provided for @dentalEthics.
  ///
  /// In en, this message translates to:
  /// **'Dental Ethics'**
  String get dentalEthics;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago • {phase}'**
  String hoursAgo(Object count, Object phase);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday • {phase}'**
  String yesterday(Object phase);

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get submit;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @unlockUnlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlock Unlimited Access'**
  String get unlockUnlimitedAccess;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Get access to all questions, mock exams, and advanced statistics.'**
  String get premiumDescription;

  /// No description provided for @unlimitedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Questions & Exams'**
  String get unlimitedQuestions;

  /// No description provided for @detailedExplanations.
  ///
  /// In en, this message translates to:
  /// **'Detailed Explanations & AI Insights'**
  String get detailedExplanations;

  /// No description provided for @advancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced Performance Stats'**
  String get advancedStats;

  /// No description provided for @adFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get adFree;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearlyPlan;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @recurringBilling.
  ///
  /// In en, this message translates to:
  /// **'Recurring billing, cancel anytime.'**
  String get recurringBilling;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @premiumSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You are now a Premium member! Enjoy unlimited access.'**
  String get premiumSuccessMessage;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @cardHolderName.
  ///
  /// In en, this message translates to:
  /// **'Card Holder Name'**
  String get cardHolderName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry (MM/YY)'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @invalidCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Card Number'**
  String get invalidCardNumber;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String pay(String amount);

  /// No description provided for @securePaymentMoyasar.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment via Moyasar'**
  String get securePaymentMoyasar;

  /// No description provided for @premiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premiumRequired;

  /// No description provided for @premiumRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This exam is only available for Premium members. Upgrade to unlock.'**
  String get premiumRequiredMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @aiCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Study Coach'**
  String get aiCoach;

  /// No description provided for @refreshAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Refresh Analysis'**
  String get refreshAnalysis;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @letAiAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Let AI Analyze Your Mistakes'**
  String get letAiAnalyze;

  /// No description provided for @aiAnalyzeDescription.
  ///
  /// In en, this message translates to:
  /// **'We will analyze your last 15 incorrect questions to provide personalized advice.'**
  String get aiAnalyzeDescription;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis Now'**
  String get startAnalysis;

  /// No description provided for @analysisValidPeriod.
  ///
  /// In en, this message translates to:
  /// **'This analysis is valid for 7 days and will be deleted automatically.'**
  String get analysisValidPeriod;

  /// No description provided for @smartPerformanceAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Smart Performance Analysis'**
  String get smartPerformanceAnalysis;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at: {date}'**
  String createdAt(String date);

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @questionBank.
  ///
  /// In en, this message translates to:
  /// **'Question Bank'**
  String get questionBank;

  /// No description provided for @allSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All Specialties'**
  String get allSpecialties;

  /// No description provided for @shuffleQuestions.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Questions'**
  String get shuffleQuestions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
