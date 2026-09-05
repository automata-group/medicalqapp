import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/specialty_remote_data_source.dart';
import '../../data/repositories/specialty_repository_impl.dart';
import '../../domain/repositories/specialty_repository.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/specialty_provider.dart';
import '../../presentation/providers/study_goal_provider.dart';
import '../../presentation/providers/dashboard_provider.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/datasources/question_remote_data_source.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/question_local_data_source.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/repositories/question_repository.dart';
import '../../presentation/providers/question_provider.dart';
import '../../presentation/providers/sync_provider.dart';
import '../network/dio_client.dart';
import '../../data/datasources/mock_exam_remote_data_source.dart';
import '../../data/repositories/mock_exam_repository_impl.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../../presentation/providers/mock_exam_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../services/notification_service.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../presentation/providers/notification_provider.dart';
import '../../data/datasources/ai_feedback_remote_data_source.dart';
import '../../presentation/providers/ai_feedback_provider.dart';
import '../../presentation/providers/contribution_provider.dart';
import '../../presentation/providers/locale_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient(sharedPreferences: sl()));

  // Locale Provider
  sl.registerLazySingleton(() => LocaleProvider(prefs: sl()));

  // Init notification service
  await NotificationService.instance.initialize();

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl(), sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SpecialtyRemoteDataSource>(
    () => SpecialtyRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<SpecialtyRepository>(
    () => SpecialtyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Providers
  sl.registerFactory(
    () => AuthProvider(authRepository: sl(), prefs: sl()),
  );

  sl.registerFactory(
    () => SpecialtyProvider(specialtyRepository: sl(), prefs: sl()),
  );
  sl.registerFactory(() => StudyGoalProvider(specialtyRepository: sl()));

  // Dashboard
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => DashboardProvider(repository: sl(), prefs: sl()),
  );

  // Question / Exam
  sl.registerLazySingleton<QuestionRemoteDataSource>(
    () => QuestionRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton(() => DatabaseHelper.instance);

  sl.registerLazySingleton(
    () => QuestionLocalDataSource(dbHelper: sl()),
  );

  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerFactory(
    () => QuestionProvider(repository: sl()),
  );

  // Sync (Offline)
  sl.registerFactory(
    () => SyncProvider(dioClient: sl(), localDataSource: sl()),
  );
  // Mock Exam
  sl.registerLazySingleton<MockExamRemoteDataSource>(
    () => MockExamRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<MockExamRepository>(
    () => MockExamRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(
    () => MockExamProvider(repository: sl()),
  );

  // Reminders
  sl.registerFactory(
    () => ReminderProvider(prefs: sl()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerFactory(
    () => NotificationProvider(dataSource: sl()),
  );

  // AI Feedback
  sl.registerLazySingleton(
    () => AIFeedbackRemoteDataSource(dio: sl<DioClient>().dio),
  );
  sl.registerFactory(
    () => AIFeedbackProvider(remoteDataSource: sl()),
  );

  // Contributions
  sl.registerFactory(
    () => ContributionProvider(dioClient: sl()),
  );
}
