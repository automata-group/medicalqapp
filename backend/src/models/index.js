const sequelize = require('../config/database');
const User = require('./User');
const RefreshToken = require('./RefreshToken');
const Specialty = require('./Specialty');
const Topic = require('./Topic');
const UserSpecialty = require('./UserSpecialty');
const StudyPlan = require('./StudyPlan');
const Question = require('./Question');
const Option = require('./Option');
const Explanation = require('./Explanation');
const QuestionAttempt = require('./QuestionAttempt');
const Bookmark = require('./Bookmark');
const QuestionStats = require('./QuestionStats');
const MockExam = require('./MockExam');
const MockExamSection = require('./MockExamSection');
const MockQuestion = require('./MockQuestion');
const MockOption = require('./MockOption');
const MockExplanation = require('./MockExplanation');
const UserMockExam = require('./UserMockExam');
const Achievement = require('./Achievement');
const UserAchievement = require('./UserAchievement');
const DailyStreak = require('./DailyStreak');
const Notification = require('./Notification');
const SubscriptionPlan = require('./SubscriptionPlan');
const Subscription = require('./Subscription');
const Payment = require('./Payment');
const DiscountCode = require('./DiscountCode');
const AdminActivityLog = require('./AdminActivityLog');
const QuestionReport = require('./QuestionReport');
const Referral = require('./Referral');
const NotificationTemplate = require('./NotificationTemplate');
const ContentUpdate = require('./ContentUpdate');
const UserMockExamAnswer = require('./UserMockExamAnswer');
const SectionQuestion = require('./SectionQuestion');
const UserProgress = require('./UserProgress');
const AppSetting = require('./AppSetting');


// --- User Associations ---
User.hasMany(RefreshToken, { foreignKey: 'userId', as: 'refreshTokens' });
RefreshToken.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasOne(StudyPlan, { foreignKey: 'userId', as: 'studyPlan' });
StudyPlan.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// User <-> Specialty (Many-to-Many)
User.belongsToMany(Specialty, { through: UserSpecialty, as: 'specialties', foreignKey: 'userId' });
Specialty.belongsToMany(User, { through: UserSpecialty, as: 'users', foreignKey: 'specialtyId' });

// --- Specialty, Topic, Question Associations ---
Specialty.hasMany(Topic, { foreignKey: 'specialtyId', as: 'topics', onDelete: 'CASCADE' });
Topic.belongsTo(Specialty, { foreignKey: 'specialtyId', as: 'specialty' });

Topic.hasMany(Question, { foreignKey: 'topicId', as: 'questions' });
Question.belongsTo(Topic, { foreignKey: 'topicId', as: 'topic' });

Specialty.hasMany(Question, { foreignKey: 'specialtyId', as: 'questions' });
Question.belongsTo(Specialty, { foreignKey: 'specialtyId', as: 'specialty' });

Question.hasMany(Option, { foreignKey: 'questionId', as: 'options', onDelete: 'CASCADE' });
Option.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

Question.hasOne(Explanation, { foreignKey: 'questionId', as: 'explanation', onDelete: 'CASCADE' });
Explanation.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

Question.hasOne(QuestionStats, { foreignKey: 'questionId', as: 'stats', onDelete: 'CASCADE' });
QuestionStats.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

// User <-> Question (Attempts & Bookmarks)
User.hasMany(QuestionAttempt, { foreignKey: 'userId', as: 'attempts' });
QuestionAttempt.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Question.hasMany(QuestionAttempt, { foreignKey: 'questionId', as: 'attempts' });
QuestionAttempt.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

User.hasMany(UserProgress, { foreignKey: 'userId', as: 'progress' });
UserProgress.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Question.hasMany(UserProgress, { foreignKey: 'questionId', as: 'progress' });
UserProgress.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

User.hasMany(Bookmark, { foreignKey: 'userId', as: 'bookmarks' });
Bookmark.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Question.hasMany(Bookmark, { foreignKey: 'questionId', as: 'bookmarkedBy' });
Bookmark.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

// Reports
User.hasMany(QuestionReport, { foreignKey: 'userId', as: 'reports' });
QuestionReport.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Question.hasMany(QuestionReport, { foreignKey: 'questionId', as: 'reports' });
QuestionReport.belongsTo(Question, { foreignKey: 'questionId', as: 'question' });

// --- Mock Exam Associations ---
MockExam.hasMany(MockExamSection, { foreignKey: 'mockExamId', as: 'sections' });
MockExamSection.belongsTo(MockExam, { foreignKey: 'mockExamId', as: 'mockExam' });

// MockExam <-> Specialty
Specialty.hasMany(MockExam, { foreignKey: 'specialtyId', as: 'mockExams' });
MockExam.belongsTo(Specialty, { foreignKey: 'specialtyId', as: 'specialty' });

// MockExam <-> Achievement
Achievement.hasMany(MockExam, { foreignKey: 'achievementId', as: 'mockExams' });
MockExam.belongsTo(Achievement, { foreignKey: 'achievementId', as: 'achievement' });

MockExamSection.belongsToMany(MockQuestion, { through: SectionQuestion, as: 'questions', foreignKey: 'sectionId' });
MockQuestion.belongsToMany(MockExamSection, { through: SectionQuestion, as: 'examSections', foreignKey: 'mockQuestionId' });

// MockQuestion Associations
MockQuestion.hasMany(MockOption, { foreignKey: 'mockQuestionId', as: 'options', onDelete: 'CASCADE' });
MockOption.belongsTo(MockQuestion, { foreignKey: 'mockQuestionId', as: 'question' });

MockQuestion.hasOne(MockExplanation, { foreignKey: 'mockQuestionId', as: 'explanation', onDelete: 'CASCADE' });
MockExplanation.belongsTo(MockQuestion, { foreignKey: 'mockQuestionId', as: 'question' });

MockQuestion.belongsTo(Specialty, { foreignKey: 'specialtyId', as: 'specialty' });
Specialty.hasMany(MockQuestion, { foreignKey: 'specialtyId', as: 'mockQuestions' });

// User <-> MockExam
User.hasMany(UserMockExam, { foreignKey: 'userId', as: 'mockExamAttempts' });
UserMockExam.belongsTo(User, { foreignKey: 'userId', as: 'user' });
MockExam.hasMany(UserMockExam, { foreignKey: 'mockExamId', as: 'attempts' });
UserMockExam.belongsTo(MockExam, { foreignKey: 'mockExamId', as: 'mockExam' });

// Mock Exam Detailed Answers
UserMockExam.hasMany(UserMockExamAnswer, { foreignKey: 'userMockExamId', as: 'answers' });
UserMockExamAnswer.belongsTo(UserMockExam, { foreignKey: 'userMockExamId', as: 'attempt' });
MockQuestion.hasMany(UserMockExamAnswer, { foreignKey: 'mockQuestionId', as: 'mockAnswers' });
UserMockExamAnswer.belongsTo(MockQuestion, { foreignKey: 'mockQuestionId', as: 'question' });
MockOption.hasMany(UserMockExamAnswer, { foreignKey: 'selectedOptionId', as: 'mockSelections' });
UserMockExamAnswer.belongsTo(MockOption, { foreignKey: 'selectedOptionId', as: 'selectedOption' });


// --- Gamification Associations ---
User.belongsToMany(Achievement, { through: UserAchievement, as: 'achievements', foreignKey: 'userId' });
Achievement.belongsToMany(User, { through: UserAchievement, as: 'users', foreignKey: 'achievementId' });

User.hasOne(DailyStreak, { foreignKey: 'userId', as: 'streak' });
DailyStreak.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// --- Subscription & Payment Associations ---
User.hasMany(Subscription, { foreignKey: 'userId', as: 'subscriptions' });
Subscription.belongsTo(User, { foreignKey: 'userId', as: 'user' });

SubscriptionPlan.hasMany(Subscription, { foreignKey: 'planId', as: 'subscriptions' });
Subscription.belongsTo(SubscriptionPlan, { foreignKey: 'planId', as: 'plan' });

User.hasMany(Payment, { foreignKey: 'userId', as: 'payments' });
Payment.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// --- Referral Associations ---
User.hasMany(Referral, { foreignKey: 'referrerUserId', as: 'referralsSent' });
Referral.belongsTo(User, { foreignKey: 'referrerUserId', as: 'referrer' });
User.hasOne(Referral, { foreignKey: 'referredUserId', as: 'referredBy' });
Referral.belongsTo(User, { foreignKey: 'referredUserId', as: 'referee' });

// --- Notification Associations ---
User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

const AIFeedback = require('./AIFeedback');
const StudySession = require('./StudySession');

// User <-> AI Feedback
User.hasMany(AIFeedback, { foreignKey: 'userId', as: 'aiFeedbacks' });
AIFeedback.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// User <-> StudySession
User.hasMany(StudySession, { foreignKey: 'userId', as: 'studySessions' });
StudySession.belongsTo(User, { foreignKey: 'userId', as: 'user' });


module.exports = {
    User,
    RefreshToken,
    Specialty,
    Topic,
    UserSpecialty,
    StudyPlan,
    Question,
    Option,
    Explanation,
    QuestionAttempt,
    Bookmark,
    QuestionStats,
    MockExam,
    MockExamSection,
    UserMockExam,
    UserMockExamAnswer,
    Achievement,
    UserAchievement,
    DailyStreak,
    Notification,
    NotificationTemplate,
    SubscriptionPlan,
    Subscription,
    Payment,
    DiscountCode,
    Referral,
    ContentUpdate,
    QuestionReport,
    SectionQuestion,
    MockQuestion,
    MockOption,
    MockExplanation,
    AdminActivityLog,
    UserProgress,
    AIFeedback,
    StudySession,
    AppSetting,
    sequelize
};
