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
import 'presentation/providers/contribution_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'presentation/screens/splash_screen.dart';
import 'dart:io';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'core/di/service_locator.dart' as di;

import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    try {
      File('app_crash.log').writeAsStringSync(
        '${DateTime.now()}: FlutterError: ${details.exception}\n${details.stack}\n---\n',
        mode: FileMode.append,
      );
    } catch (_) {}
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error: $error');
    try {
      File('app_crash.log').writeAsStringSync(
        '${DateTime.now()}: PlatformDispatcher error: $error\n$stack\n---\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    return true; // Prevents crash / process exit
  };

  await di.init();

  runApp(const MyApp());

  // Initialize push notifications and cloud services in background without blocking UI
  _initServicesAsync();
}

void _initServicesAsync() async {
  final isMobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (kIsWeb || isMobile) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 4));

      if (isMobile) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        FCMService.instance.initialize(baseUrl: 'https://healthlicenseprep.com/api/v1');
        await NotificationService.instance.initialize();
      }
    } catch (e) {
      debugPrint('Background services warning: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<LocaleProvider>()),
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
        ChangeNotifierProvider(create: (_) => di.sl<ContributionProvider>()),
        ChangeNotifierProvider(
            create: (_) => AdminProvider()), // Inject AdminProvider
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'SDLE',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
