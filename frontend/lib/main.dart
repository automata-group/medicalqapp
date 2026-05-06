import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/study_goal_provider.dart';
import 'presentation/providers/specialty_provider.dart';
import 'presentation/providers/question_provider.dart';
import 'presentation/providers/mock_exam_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/admin_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/ai_feedback_provider.dart';
import 'core/services/notification_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await di.init();

  // Initialize FCM service (permissions, token registration, etc.)
  FCMService.instance.initialize(baseUrl: 'https://healthlicenseprep.com/api/v1');

  // Initialize Notification Service for local reminders
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<DashboardProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<StudyGoalProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<SpecialtyProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<QuestionProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<MockExamProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<SyncProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ReminderProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AIFeedbackProvider>()),
        ChangeNotifierProvider(
            create: (_) => AdminProvider()), // Inject AdminProvider
      ],
      child: MaterialApp(
        title: 'healthlicenseprep',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: const Locale('en'), // Default to English
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SplashScreen(),
      ),
    );
  }
}
