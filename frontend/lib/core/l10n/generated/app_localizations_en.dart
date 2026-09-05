// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Medical Q';

  @override
  String get mockExams => 'Mock Exams';

  @override
  String get noExamsAvailable => 'No exams available at the moment.';

  @override
  String get free => 'FREE';

  @override
  String get minutes => 'mins';

  @override
  String get questions => 'questions';

  @override
  String get startExam => 'Start Exam';

  @override
  String get finishExam => 'Finish Exam';

  @override
  String get continueRevision => 'Continue Revision';

  @override
  String get recentPractice => 'Recent Practice';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get performanceTrend => 'Performance Trend';

  @override
  String get achievements => 'Achievements';

  @override
  String get noAchievements => 'No achievements yet. Keep practicing!';

  @override
  String get startRevision => 'Start Revision';

  @override
  String get continueAction => 'Continue';

  @override
  String get examPassed => 'Congratulations!';

  @override
  String get examFailed => 'Keep Practicing!';

  @override
  String get yourScore => 'Your Score';

  @override
  String get correct => 'Correct';

  @override
  String get total => 'Total';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get noResultData => 'No result data available';

  @override
  String get login => 'Login';

  @override
  String get startOffline => 'Start Offline';

  @override
  String get connectionTimeout => 'Connection is taking too long';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get selectSpecialty => 'Select Specialty';

  @override
  String get searchSpecialty => 'Search for a specialty...';

  @override
  String get continueText => 'Continue';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String questionsAvailable(int count) {
    return '$count Questions Available';
  }

  @override
  String get setStudyGoal => 'Set Your Goal';

  @override
  String get studyGoalSubtitle => 'Define your exam date and study hours.';

  @override
  String get examDate => 'Exam Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get dailyStudyHours => 'Daily Study Hours';

  @override
  String get hours => 'Hours';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get stats => 'Stats';

  @override
  String get profile => 'Profile';

  @override
  String welcomeBack(String name) {
    return 'Welcome, $name';
  }

  @override
  String get readyForChallenge => 'Ready for today\'s challenge?';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String answeredQuestions(int count) {
    return 'You answered $count questions this week';
  }

  @override
  String get medicalSpecialties => 'Medical Specialties';

  @override
  String get seeAll => 'See All';

  @override
  String get keepRevising => 'Keep Revising';

  @override
  String get quickExam => 'Quick Exam';

  @override
  String questionsProgress(int count) {
    return '$count/100 questions';
  }

  @override
  String get studyStreak => 'Study Streak';

  @override
  String get activeDays => 'Active Days';

  @override
  String get orthodontics => 'Orthodontics';

  @override
  String get endodontics => 'Endodontics';

  @override
  String get prosthodontics => 'Prosthodontics';

  @override
  String get periodontics => 'Periodontics';

  @override
  String get pediatricDentistry => 'Pediatric Dentistry';

  @override
  String get restorative => 'Restorative Dentistry';

  @override
  String get dentalSurgery => 'Dental Surgery';

  @override
  String get oralSurgery => 'Oral Surgery';

  @override
  String get infectionControl => 'Sterilization and Infection Control';

  @override
  String get oralMedicine => 'Oral Medicine & Pathology';

  @override
  String get dentalEthics => 'Dental Ethics';

  @override
  String hoursAgo(Object count, Object phase) {
    return '$count hours ago • $phase';
  }

  @override
  String yesterday(Object phase) {
    return 'Yesterday • $phase';
  }

  @override
  String get resume => 'Resume';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next Question';

  @override
  String get submit => 'Submit Answer';

  @override
  String get explanation => 'Explanation';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get appSettings => 'App Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get unlockUnlimitedAccess => 'Unlock Unlimited Access';

  @override
  String get premiumDescription =>
      'Get access to all questions, mock exams, and advanced statistics.';

  @override
  String get unlimitedQuestions => 'Unlimited Questions & Exams';

  @override
  String get detailedExplanations => 'Detailed Explanations & AI Insights';

  @override
  String get advancedStats => 'Advanced Performance Stats';

  @override
  String get adFree => 'Ad-Free Experience';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get yearlyPlan => 'Yearly';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get recurringBilling => 'Recurring billing, cancel anytime.';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get paymentSuccessful => 'Payment Successful';

  @override
  String get premiumSuccessMessage =>
      'You are now a Premium member! Enjoy unlimited access.';

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get cardHolderName => 'Card Holder Name';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry (MM/YY)';

  @override
  String get cvv => 'CVV';

  @override
  String get invalidCardNumber => 'Invalid Card Number';

  @override
  String pay(String amount) {
    return 'Pay $amount';
  }

  @override
  String get securePaymentMoyasar => 'Secure Payment via Moyasar';

  @override
  String get premiumRequired => 'Premium Required';

  @override
  String get premiumRequiredMessage =>
      'This exam is only available for Premium members. Upgrade to unlock.';

  @override
  String get cancel => 'Cancel';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get aiCoach => 'AI Study Coach';

  @override
  String get refreshAnalysis => 'Refresh Analysis';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get letAiAnalyze => 'Let AI Analyze Your Mistakes';

  @override
  String get aiAnalyzeDescription =>
      'We will analyze your last 15 incorrect questions to provide personalized advice.';

  @override
  String get startAnalysis => 'Start Analysis Now';

  @override
  String get analysisValidPeriod =>
      'This analysis is valid for 7 days and will be deleted automatically.';

  @override
  String get smartPerformanceAnalysis => 'Smart Performance Analysis';

  @override
  String createdAt(String date) {
    return 'Created at: $date';
  }

  @override
  String get accuracy => 'Accuracy';

  @override
  String get questionBank => 'Question Bank';

  @override
  String get allSpecialties => 'All Specialties';

  @override
  String get shuffleQuestions => 'Shuffle Questions';
}
