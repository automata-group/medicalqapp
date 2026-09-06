// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'SDLE';

  @override
  String get mockExams => 'اختبارات تجريبية';

  @override
  String get noExamsAvailable => 'لا توجد اختبارات متاحة حاليا.';

  @override
  String get free => 'مجاني';

  @override
  String get minutes => 'دقيقة';

  @override
  String get questions => 'سؤال';

  @override
  String get startExam => 'ابدأ الاختبار';

  @override
  String get finishExam => 'إنهاء الاختبار';

  @override
  String get continueRevision => 'واصل المراجعة';

  @override
  String get recentPractice => 'ممارسة حديثة';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get performanceTrend => 'مؤشر الأداء';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get noAchievements => 'لا توجد إنجازات بعد. واصل التدريب!';

  @override
  String get startRevision => 'ابدأ المراجعة';

  @override
  String get continueAction => 'استكمال';

  @override
  String get examPassed => 'مبارك! أحسنت';

  @override
  String get examFailed => 'واصل المحاولة!';

  @override
  String get yourScore => 'نتيجتـك';

  @override
  String get correct => 'صحيحة';

  @override
  String get total => 'المجموع';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get noResultData => 'لا توجد نتائج للعرض';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get startOffline => 'البدء بدون إنترنت';

  @override
  String get connectionTimeout => 'الاتصال يستغرق وقتًا طويلاً';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signIn => 'دخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get selectSpecialty => 'اختر التخصص';

  @override
  String get searchSpecialty => 'ابحث عن تخصص طبي...';

  @override
  String get continueText => 'متابعة';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String questionsAvailable(int count) {
    return '$count سؤال متاح';
  }

  @override
  String get setStudyGoal => 'حدد هدفك';

  @override
  String get studyGoalSubtitle => 'حدد موعد الاختبار وساعات المذاكرة اليومية.';

  @override
  String get examDate => 'موعد الاختبار';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get dailyStudyHours => 'ساعات المذاكرة اليومية';

  @override
  String get hours => 'ساعات';

  @override
  String get home => 'الرئيسية';

  @override
  String get library => 'المكتبة';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get profile => 'حسابي';

  @override
  String welcomeBack(String name) {
    return 'أهلاً بك، $name';
  }

  @override
  String get readyForChallenge => 'مستعد لتحدي اليوم؟';

  @override
  String get weeklyProgress => 'الإنجاز الأسبوعي';

  @override
  String answeredQuestions(int count) {
    return 'أجبت على $count سؤالاً هذا الأسبوع';
  }

  @override
  String get medicalSpecialties => 'التخصصات الطبية';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get keepRevising => 'واصل المراجعة';

  @override
  String get quickExam => 'اختبار سريع';

  @override
  String questionsProgress(int count) {
    return '$count/100 سؤال';
  }

  @override
  String get studyStreak => 'سجل المذاكرة';

  @override
  String get activeDays => 'أيام النشاط';

  @override
  String get orthodontics => 'تقويم الأسنان';

  @override
  String get endodontics => 'علاج الجذور';

  @override
  String get prosthodontics => 'الاستعاضة السنية';

  @override
  String get periodontics => 'أمراض اللثة';

  @override
  String get pediatricDentistry => 'طب أسنان الأطفال';

  @override
  String get restorative => 'العلاج التحفظي';

  @override
  String get dentalSurgery => 'جراحة الأسنان';

  @override
  String get oralSurgery => 'جراحة الفم والوجه والفكين';

  @override
  String get infectionControl => 'التعقيم ومكافحة العدوى';

  @override
  String get oralMedicine => 'طب وأمراض الفم';

  @override
  String get dentalEthics => 'أخلاقيات طب الأسنان';

  @override
  String hoursAgo(Object count, Object phase) {
    return 'منذ $count ساعات • $phase';
  }

  @override
  String yesterday(Object phase) {
    return 'الأمس • $phase';
  }

  @override
  String get resume => 'اكمل';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'السؤال التالي';

  @override
  String get submit => 'إرسال الإجابة';

  @override
  String get explanation => 'الشرح';

  @override
  String get bookmarks => 'المحفوظات';

  @override
  String get account => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get upgradeToPremium => 'الترقية للبريميوم';

  @override
  String get unlockUnlimitedAccess => 'افتح وصول غير محدود';

  @override
  String get premiumDescription =>
      'احصل على جميع الأسئلة، الاختبارات التجريبية، وإحصائيات متقدمة.';

  @override
  String get unlimitedQuestions => 'أسئلة واختبارات غير محدودة';

  @override
  String get detailedExplanations => 'شرح مفصل ورؤى الذكاء الاصطناعي';

  @override
  String get advancedStats => 'إحصائيات أداء متقدمة';

  @override
  String get adFree => 'تجربة خالية من الإعلانات';

  @override
  String get monthlyPlan => 'شهري';

  @override
  String get yearlyPlan => 'سنوي';

  @override
  String get bestValue => 'الأفضل قيمة';

  @override
  String get recurringBilling => 'تجديد تلقائي، إلغاء في أي وقت.';

  @override
  String get subscribeNow => 'اشترك الآن';

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح';

  @override
  String get premiumSuccessMessage =>
      'أنت الآن عضو مميز! استمتع بوصول غير محدود.';

  @override
  String get paymentDetails => 'تفاصيل الدفع';

  @override
  String get cardHolderName => 'اسم حامل البطاقة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get expiryDate => 'تاريخ الانتهاء (MM/YY)';

  @override
  String get cvv => 'رمز الأمان (CVV)';

  @override
  String get invalidCardNumber => 'رقم البطاقة غير صحيح';

  @override
  String pay(String amount) {
    return 'ادفع $amount';
  }

  @override
  String get securePaymentMoyasar => 'دفع آمن عبر مويسر';

  @override
  String get premiumRequired => 'يتطلب اشتراك مميز';

  @override
  String get premiumRequiredMessage =>
      'هذا الاختبار متاح فقط للأعضاء المميزين. قم بالترقية لفتح القفل.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get upgrade => 'ترقية';

  @override
  String get rateApp => 'تقييم التطبيق';

  @override
  String get aiCoach => 'مدرب المذاكرة الذكي';

  @override
  String get refreshAnalysis => 'تحديث التحليل';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get letAiAnalyze => 'دع الذكاء الاصطناعي يحلل أخطائك';

  @override
  String get aiAnalyzeDescription =>
      'سنقوم بتحليل آخر 15 سؤال أخطأت فيهم لتزويدك بنصائح مخصصة.';

  @override
  String get startAnalysis => 'ابدأ التحليل الآن';

  @override
  String get analysisValidPeriod =>
      'هذا التحليل صالح لمدة 7 أيام وسيتم حذفه تلقائياً.';

  @override
  String get smartPerformanceAnalysis => 'تحليل الأداء الذكي';

  @override
  String createdAt(String date) {
    return 'تم الإنشاء في: $date';
  }

  @override
  String get accuracy => 'الدقة';

  @override
  String get questionBank => 'بنك الأسئلة';

  @override
  String get allSpecialties => 'جميع التخصصات';

  @override
  String get shuffleQuestions => 'خلط الأسئلة';

  @override
  String get examRecallTitle => 'تذكّر سؤالاً جاءك في الاختبار؟';

  @override
  String get examRecallSubtitle =>
      'ساهم بالسؤال وساعد زملاءك في الاستعداد للاختبار.';

  @override
  String get shareNow => 'شارك الآن';

  @override
  String get examContributionTitle => 'مساهمة بسؤال اختبار';

  @override
  String get examContributionSubtitle =>
      'ساهم بالسؤال وساعد زملاءك في الاستعداد لاختبار الهيئة. سيتم تدقيقه واعتماده رسمياً.';

  @override
  String get specialtyRequired => 'التخصص *';

  @override
  String get selectSpecialtyHint => 'اختر التخصص';

  @override
  String get questionTextLabel => 'ما الذي تتذكره من السؤال؟ *';

  @override
  String get questionTextHint =>
      'اكتب نص السؤال أو الحالة السريرية أو الأعراض كما تذكرتها...';

  @override
  String get questionTextValidation => 'يرجى كتابة ما تتذكره من السؤال';

  @override
  String get optionsOptional => 'الخيارات إن كنت تتذكرها (اختياري)';

  @override
  String get perceivedCorrectAnswer => 'ما الإجابة التي تعتقد أنها صحيحة؟';

  @override
  String get unsureAnswer => 'غير متأكد';

  @override
  String get confidenceLevelQuestion => 'مدى ثقتك بتذكرك للسؤال؟ *';

  @override
  String get confidenceHighTitle => 'أتذكره بشكل جيد';

  @override
  String get confidenceHighSubtitle =>
      'حرفياً أو شبه مطابق لما ورد في الاختبار';

  @override
  String get confidenceMediumTitle => 'أتذكر معظمه';

  @override
  String get confidenceMediumSubtitle =>
      'قريب جداً من النص الأصلي مع نسيان بعض التفاصيل';

  @override
  String get confidenceLowTitle => 'أتذكر الفكرة فقط';

  @override
  String get confidenceLowSubtitle =>
      'أتذكر فكرة الحالة السريرية والموضوع العام';

  @override
  String get examDateOptional => 'متى اختبرت؟ (اختياري)';

  @override
  String get selectExamDateHint => 'اختر تاريخ الاختبار إن كنت تتذكره';

  @override
  String get notesOptional => 'شرح أو ملاحظة (اختياري)';

  @override
  String get notesHint =>
      'أضف أي ملاحظة حول سبب اختيارك أو تفاصيل إضافية عن السؤال...';

  @override
  String get attachImageOptional => 'إرفاق صورة (اختياري)';

  @override
  String get pickImageFromDevice => 'اختيار صورة من الجهاز';

  @override
  String get imagePrivacyNotice =>
      'تنبيه: يرجى عدم رفع أي صور تحتوي على بيانات شخصية أو مواد محظورة.';

  @override
  String get submitForReview => 'إرسال للمراجعة';

  @override
  String get reportQuestionTitle => 'الإبلاغ عن مشكلة في السؤال';

  @override
  String get reportQuestionSubtitle =>
      'ساعدنا في الحفاظ على دقة بنك الأسئلة ومراجعتها من قبل المختصين';

  @override
  String get reportReasonLabel => 'نوع المشكلة';

  @override
  String get reportReasonWrongAnswer => 'الإجابة الصحيحة غير دقيقة';

  @override
  String get reportReasonWrongAnswerDesc =>
      'مفتاح الحل المعلم كصحيح غير مطابق للصواب';

  @override
  String get reportReasonScientific => 'خطأ علمي أو طبي';

  @override
  String get reportReasonScientificDesc =>
      'خطأ في المعلومة الطبية، الحالة، أو التفسير';

  @override
  String get reportReasonTypo => 'خطأ لغوي أو إملائي';

  @override
  String get reportReasonTypoDesc => 'أخطاء في الصياغة، الترجمة أو التنسيق';

  @override
  String get reportReasonConfusing => 'سؤال غامض أو غير مكتمل';

  @override
  String get reportReasonConfusingDesc =>
      'السؤال غير واضح، ناقص خيارات أو غير مفهوم';

  @override
  String get reportReasonOther => 'سبب آخر';

  @override
  String get reportReasonOtherDesc => 'أي ملاحظة أخرى تود إضافتها';

  @override
  String get reportDescriptionLabel => 'تفاصيل إضافية (اختياري)';

  @override
  String get reportDescriptionHint =>
      'وضح تفاصيل الخطأ أو الملاحظة لمساعدة المدققين...';

  @override
  String get reportSubmitButton => 'إرسال البلاغ';

  @override
  String get reportSuccessMessage => 'تم إرسال البلاغ بنجاح، شكراً لمساهمتك!';

  @override
  String get reportFailedMessage =>
      'تعذر إرسال البلاغ، يرجى المحاولة مرة أخرى.';

  @override
  String optionTextHint(String key) {
    return 'نص الخيار ($key)';
  }

  @override
  String optionLabel(String key) {
    return 'الخيار $key';
  }

  @override
  String get pleaseSelectSpecialty => 'يرجى اختيار التخصص';

  @override
  String get contributionReceivedTitle => 'تم استلام مساهمتك';

  @override
  String get contributionReceivedMessage =>
      'شكرًا لمساعدتك في تطوير بنك الأسئلة.\nسيقوم فريقنا بمراجعة السؤال والتحقق منه قبل إضافته.';

  @override
  String get contributeAnotherQuestion => 'مساهمة بسؤال آخر';

  @override
  String get submissionError => 'حدث خطأ أثناء الإرسال';

  @override
  String get studyPlanSaved => 'تم حفظ خطة المذاكرة بنجاح!';

  @override
  String get studyPlanSaveError =>
      'فشل حفظ خطة المذاكرة، يرجى المحاولة مرة أخرى.';

  @override
  String get splashSubtitle =>
      'منصتك الأولى لاجتياز اختبار رخصة طب الأسنان السعودي';

  @override
  String get chooseYourPlan => 'اختر باقتك المناسبة';

  @override
  String get whatsIncluded => 'ماذا تشمل باقاتنا؟';

  @override
  String get passExamWithConfidence => 'اجتز اختبار الهيئة بكل ثقة وتفوق.';

  @override
  String get allPlansFullAccessNotice =>
      'جميع الخطط تمنح وصولاً كاملاً لكافة الأسئلة ومزايا الذكاء الاصطناعي — الفرق فقط في المدة والسعر';

  @override
  String get subscriptionCardTitle => 'باقات الاشتراك المميزة';

  @override
  String get subscriptionCardActiveTitle => 'عضوية PRO مميزة';

  @override
  String get subscriptionCardBadge => 'SDLE PRO';

  @override
  String get subscriptionCardActiveBadge => 'PRO نشط';

  @override
  String get subscriptionCardDesc =>
      'افتح جميع التخصصات، والاختبارات التجريبية غير المحدودة، ومزايا الذكاء الاصطناعي.';

  @override
  String get subscriptionCardActiveDesc =>
      'لديك وصول كامل لجميع بنوك الأسئلة، واختبارات المحاكاة، ومزايا الذكاء الاصطناعي.';

  @override
  String get subscriptionCardBtn => 'استعراض الخطط والاشتراك الآن ✨';

  @override
  String get subscriptionCardActiveBtn => 'إدارة تفاصيل الاشتراك';

  @override
  String get subscriptionPlansTitle => 'باقات الاشتراك والترقية (PRO)';

  @override
  String get activePro => 'PRO نشط';

  @override
  String get inviteFriendsTitle => 'ادعُ أصدقاءك واكسب المكافآت 🎁';

  @override
  String get inviteFriendsDesc =>
      'شارك رمز الإحالة الخاص بك مع زملائك، وعند تسجيلهم ستحصلان معاً على مكافآت مميزة!';

  @override
  String get referralCodeCopied => 'تم نسخ رمز الإحالة بنجاح!';

  @override
  String get mySpecialties => 'تخصصاتي';

  @override
  String get dailyReminderTime => 'وقت التذكير اليومي';

  @override
  String get offlineMode => 'المذاكرة بدون إنترنت';

  @override
  String get readyStatus => 'جاهز ✓';

  @override
  String get allAnswersSynced => 'تمت مزامنة جميع الإجابات ✓';

  @override
  String answersPendingSync(int count) {
    return '$count إجابة بانتظار المزامنة';
  }

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get myMasteryProgress => 'مستوى التقدم والإتقان';

  @override
  String get questionsLabel => 'الأسئلة';

  @override
  String get streakLabel => 'أيام متواصلة';

  @override
  String streakDaysCount(int count) {
    return '$count يوم';
  }

  @override
  String get aiCoachTab => 'المدرب الذكي 🤖';

  @override
  String get practiceAllSpecialtiesSubtitle =>
      'تدرب على جميع التخصصات ونماذج الامتحانات';

  @override
  String get specialties => 'التخصصات';

  @override
  String get startRandomPractice => 'بدء تدريب عشوائي';

  @override
  String get practiceAllQuestionsSubtitle => 'تدرب على جميع أسئلة هذا التخصص';

  @override
  String get resumeWhereLeftOff => 'المتابعة من حيث توقفت';

  @override
  String get noActivityData => 'لا توجد بيانات نشاط';

  @override
  String questionNumber(int number) {
    return 'السؤال $number';
  }

  @override
  String questionNumberWithTotal(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get resumeSessionTitle => 'استئناف الجلسة؟';

  @override
  String resumeSessionContent(String subTopic) {
    return 'لديك جلسة محفوظة في $subTopic.\nهل ترغب في المتابعة من حيث توقفت؟';
  }

  @override
  String get thisSpecialty => 'هذا التخصص';

  @override
  String get startNew => 'بدء جديد';

  @override
  String get exitExamTitle => 'الخروج من الاختبار؟';

  @override
  String get exitExamContent =>
      'هل أنت متأكد من رغبتك في الخروج؟ قد تفقد تقدمك الحالي.';

  @override
  String get exit => 'خروج';

  @override
  String get plan1Month => 'شهر واحد';

  @override
  String get plan3Months => '3 أشهر';

  @override
  String get plan6Months => '6 أشهر';

  @override
  String get plan1Year => 'سنة كاملة (12 شهر)';

  @override
  String get sarCurrency => 'ر.س';

  @override
  String get perMonth => 'شهرياً';

  @override
  String get sarPerMonth => 'ر.س / شهرياً';

  @override
  String get sarPer3Months => 'ر.س / 3 أشهر';

  @override
  String get sarPer6Months => 'ر.س / 6 أشهر';

  @override
  String get sarPerYear => 'ر.س / سنوياً';

  @override
  String get bestValueBadge => 'الأكثر توفيراً 🔥';

  @override
  String get mostPopularBadge => 'الأكثر طلباً ⭐';

  @override
  String savePercentage(int percent) {
    return 'وفر $percent%';
  }

  @override
  String equivalentPerMonth(String amount) {
    return 'يعادل $amount ر.س / شهر فقط';
  }

  @override
  String get cancelAnytime => 'إلغاء الاشتراك متاح في أي وقت بنقرة واحدة';

  @override
  String get fullProAccessHeader =>
      'جميع الباقات تشمل وصولاً كاملاً وغير محدود لجميع المزايا';

  @override
  String get secureCheckout => 'دفع إلكتروني آمن ومشفّر 100%';

  @override
  String get moneyBackGuarantee =>
      'مطابق لأحدث معايير اختبار الهيئة السعودية للتخصصات الصحية';

  @override
  String get questionBankLimitReached =>
      'لقد استنفذت الحد المجاني لبنك الأسئلة (30 سؤالاً)';

  @override
  String get specialtyLimitReached =>
      'لقد استنفذت الـ 15 سؤالاً المجانية لهذا التخصص';

  @override
  String get upgradeToProPrompt =>
      'قم بالترقية إلى باقة PRO لفتح جميع الأسئلة بلا حدود، والشروحات الذكية، والامتحانات التجريبية.';

  @override
  String get upgradeToProBtn => 'الترقية إلى باقة PRO 👑';

  @override
  String get failedToLoadQuestion => 'فشل تحميل السؤال';

  @override
  String get checkConnectionPrompt =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get viewExplanation => 'عرض الشرح';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get proMembership => 'عضوية PRO';

  @override
  String get tagQuestionsCount => '🎯 +4,700 سؤال';

  @override
  String get tagSmartExplanations => '🤖 شروحات ذكية';

  @override
  String get tagExamSimulation => '⏱️ محاكاة الهيئة';
}
