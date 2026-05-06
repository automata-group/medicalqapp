# ✅ Backend TODO List - Medical Question Bank

> **Tech Stack**: Node.js + Express.js | MySQL 8.0+ | Sequelize ORM | JWT Auth
> **Payment**: ميسر (للسوق السعودي) | **AI**: OpenAI / Gemini API

---

## 📁 Phase 0: Project Setup & Infrastructure

- [x] Initialize Node.js project (`npm init`)
- [x] Install core dependencies (express, sequelize, mysql2, jsonwebtoken, bcrypt, dotenv, cors, helmet, morgan)
- [x] Setup project folder structure:
  ```
  src/
  ├── config/         # DB config, env vars, constants
  ├── middleware/      # auth, error handler, rate limiter, validation
  ├── models/          # Sequelize models
  ├── routes/          # Express route definitions
  ├── controllers/     # Request handlers
  ├── services/        # Business logic
  ├── utils/           # Helpers (email sender, file upload, AI client)
  ├── validators/      # Request validation schemas (Joi/Zod)
  ├── jobs/            # Background jobs (Bull Queue)
  └── app.js           # Express app entry point
  ```
- [x] Setup Sequelize config & database connection
- [x] Setup `.env` file with all environment variables
- [x] Setup error handling middleware (global error handler)
- [x] Setup request validation middleware (Joi or Zod)
- [x] Setup logging (morgan + winston)
- [x] Setup CORS & security headers (helmet)
- [x] Setup rate limiting (express-rate-limit)
- [x] Setup file upload middleware (multer + AWS S3 / GCS)
- [ ] Setup Bull Queue for background jobs

---

## 📁 Phase 1: Database Models (Sequelize)

- [x] `User` model
- [x] `RefreshToken` model
- [x] `Specialty` model
- [x] `UserSpecialty` model (junction)
- [x] `StudyPlan` model
- [x] `Question` model
- [x] `Option` model
- [x] `Explanation` model
- [x] `QuestionAttempt` model
- [x] `Bookmark` model
- [x] `QuestionReport` model
- [x] `MockExam` model
- [x] `MockExamSection` model
- [x] `UserMockExam` model
- [x] `UserMockExamAnswer` model
- [x] `Achievement` model
- [x] `UserAchievement` model
- [x] `DailyStreak` model
- [x] `SubscriptionPlan` model
- [x] `Subscription` model
- [x] `Payment` model
- [x] `DiscountCode` model
- [x] `DiscountCodeUsage` model (Implied in DiscountCode or simple logic)
- [x] `Referral` model
- [x] `Notification` model
- [x] `NotificationTemplate` model
- [x] `ContentUpdate` model
- [x] `AdminActivityLog` model
- [x] Define all associations (hasMany, belongsTo, belongsToMany)
- [x] Run migrations & seed initial data (specialties, achievements, plans)

---

## 📁 Phase 2: Middleware

- [x] `authMiddleware` - JWT token verification
- [x] `adminMiddleware` - Admin role check
- [x] `subscriptionMiddleware` - Premium content access check
- [x] `validationMiddleware` - Generic request validator
- [x] `uploadMiddleware` - File upload handler (images)
- [x] `paginationMiddleware` - Standard pagination helper

---

## 📁 Phase 3: User App Endpoints

### Module 1: Authentication & Onboarding

- [x] `POST   /api/v1/auth/register` - Register new user
- [x] `POST   /api/v1/auth/login` - User login (returns access + refresh tokens)
- [x] `POST   /api/v1/auth/logout` - Invalidate refresh token
- [x] `POST   /api/v1/auth/refresh-token` - Issue new access token
- [x] `POST   /api/v1/auth/forgot-password` - Send reset email
- [x] `POST   /api/v1/auth/reset-password` - Reset password with token
- [x] `POST   /api/v1/auth/verify-email` - Email verification
- [x] `GET    /api/v1/auth/me` - Get current user profile
- [x] `PUT    /api/v1/auth/profile` - Update user profile

### Module 2: Specialty Selection & Profile Setup

- [x] `GET    /api/v1/specialties` - List all specialties
- [x] `GET    /api/v1/specialties/{id}` - Get specialty details
- [x] `POST   /api/v1/user/specialties` - Set user specialties (multi-select)
- [x] `GET    /api/v1/user/specialties` - Get user's selected specialties
- [x] `DELETE /api/v1/user/specialties/{id}` - Remove a specialty
- [x] `PUT    /api/v1/user/study-settings` - Update study plan (exam date, daily hours)
- [x] `GET    /api/v1/user/study-settings` - Get current study settings

### Module 3: Home Dashboard

- [x] `GET    /api/v1/dashboard/overview` - Main dashboard data (progress, stats)
- [x] `GET    /api/v1/dashboard/progress` - Overall completion progress (Part of Overview)
- [x] `GET    /api/v1/dashboard/stats/daily` - Today's statistics
- [x] `GET    /api/v1/dashboard/stats/weekly` - This week's statistics
- [x] `GET    /api/v1/dashboard/weak-areas` - Specialties with lowest scores (Part of Overview)
- [x] `GET    /api/v1/dashboard/recent-activity` - Recent user activity

### Module 4: Question Practice Mode

- [x] `GET    /api/v1/questions/practice/next` - Get next question (filtered)
- [x] `POST   /api/v1/questions/{id}/answer` - Submit answer & record attempt
- [x] `GET    /api/v1/questions/{id}/explanation` - Get answer explanation (Returned with Answer)
- [x] `POST   /api/v1/questions/{id}/bookmark` - Bookmark a question
- [x] `DELETE /api/v1/questions/{id}/bookmark` - Remove bookmark
- [x] `GET    /api/v1/questions/bookmarked` - List bookmarked questions
- [x] `POST   /api/v1/questions/{id}/report` - Report a question
- [x] `GET    /api/v1/questions/practice/filters` - Available filter options

### Module 5: Mock Exam Mode

- [x] `POST   /api/v1/mock-exams/start` - Start a new mock exam (420 questions, 2 sections)
- [x] `GET    /api/v1/mock-exams/{id}` - Get mock exam details
- [x] `GET    /api/v1/mock-exams/{id}/sections/{section_id}` - Get section questions
- [x] `POST   /api/v1/mock-exams/{id}/sections/{section_id}/answer` - Submit answer in section
- [x] `POST   /api/v1/mock-exams/{id}/sections/{section_id}/complete` - Complete a section
- [x] `POST   /api/v1/mock-exams/{id}/complete` - Complete entire exam
- [x] `GET    /api/v1/mock-exams/{id}/results` - Get exam results & score
- [x] `GET    /api/v1/mock-exams/{id}/review` - Review wrong answers
- [x] `GET    /api/v1/mock-exams/history` - List past mock exams

### Module 6: Progress & Statistics

- [x] `GET    /api/v1/progress/specialties` - Progress per specialty
- [x] `GET    /api/v1/progress/specialty/{id}/details` - Detailed specialty progress
- [x] `GET    /api/v1/stats/overall` - Overall performance stats
- [x] `GET    /api/v1/stats/daily-streak` - Current streak info
- [x] `GET    /api/v1/stats/time-analysis` - Time spent analysis
- [x] `GET    /api/v1/stats/performance-trends` - Performance over time

### Module 7: Achievements & Streaks

- [x] `GET    /api/v1/achievements` - List all achievements
- [x] `GET    /api/v1/achievements/{id}` - Achievement details
- [x] `GET    /api/v1/user/achievements` - User's earned achievements
- [x] `GET    /api/v1/user/streaks` - User's streak data

### Module 8: Bookmarks & Saved Questions

- [x] `GET    /api/v1/bookmarks` - List user bookmarks (filterable)
- [x] `GET    /api/v1/bookmarks/{id}` - Get bookmark details
- [x] `DELETE /api/v1/bookmarks/{id}` - Delete bookmark
- [x] `PUT    /api/v1/bookmarks/{id}/notes` - Add/update personal notes

### Module 9: Search & Filters

- [x] `GET    /api/v1/search/questions` - Search questions by keyword
- [x] `POST   /api/v1/search/advanced` - Advanced search (multi-filter)
- [x] `GET    /api/v1/search/history` - User's search history

### Module 10: Notifications

- [x] `GET    /api/v1/notifications` - List user notifications
- [x] `GET    /api/v1/notifications/unread-count` - Unread notification count
- [x] `PUT    /api/v1/notifications/{id}/read` - Mark notification as read
- [x] `PUT    /api/v1/notifications/read-all` - Mark all as read
- [x] `DELETE /api/v1/notifications/{id}` - Delete notification
- [x] `PUT    /api/v1/notifications/settings` - Update notification preferences

### Module 11: Subscription & Payments

- [x] `GET    /api/v1/subscriptions/plans` - List available plans
- [x] `GET    /api/v1/user/subscription` - Get current subscription
- [x] `POST   /api/v1/subscriptions/subscribe` - Subscribe to a plan (integrate ميسر) - *Stubbed*
- [x] `POST   /api/v1/subscriptions/cancel` - Cancel subscription
- [x] `POST   /api/v1/subscriptions/renew` - Renew subscription
- [x] `POST   /api/v1/payments/process` - Process payment (ميسر gateway) (Stubbed)
- [x] `GET    /api/v1/payments/history` - User payment history

#### Admin Module 14: Settings & Configuration
- [x] `GET    /api/v1/admin/settings` - Get system settings
- [x] `PUT    /api/v1/admin/settings` - Update system settings
- [x] `GET    /api/v1/admin/ai-config` - Get AI configuration
- [x] `PUT    /api/v1/admin/ai-config` - Update AI configuration
- [x] `POST   /api/v1/discount-codes/validate` - Validate discount code
- [x] `POST   /api/v1/referrals/generate-code` - Generate referral code
- [x] `GET    /api/v1/referrals/my-referrals` - List user's referrals

### Module 12: Settings & Profile

- [x] `GET    /api/v1/user/profile` - Get full profile
- [x] `PUT    /api/v1/user/profile` - Update profile (name, phone, avatar)
- [x] `PUT    /api/v1/user/change-password` - Change password
- [x] `PUT    /api/v1/user/notification-preferences` - Update notification settings
- [x] `DELETE /api/v1/user/account` - Delete account (soft delete)
- [x] `GET    /api/v1/app/version` - Get current app version

### Module 13: Offline Sync
- [x] `POST   /api/v1/offline/sync` - Sync offline data
- [x] `GET    /api/v1/offline/download-questions` - Download questions for offline
- [x] `POST   /api/v1/offline/upload-answers` - Upload answers from offline session

---

## 📁 Phase 4: Admin Dashboard Endpoints

### Admin Module 1: Admin Authentication

- [x] `POST   /api/v1/admin/auth/login` - Admin login
- [x] `POST   /api/v1/admin/auth/logout` - Admin logout (Part of User Logout, shared logic possible or separate)
- [x] `POST   /api/v1/admin/auth/refresh-token` - Refresh admin token
- [x] `GET    /api/v1/admin/auth/me` - Get current admin profile

### Admin Module 2: Question Management

- [x] `GET    /api/v1/admin/questions` - List all questions (paginated, filterable)
- [x] `GET    /api/v1/admin/questions/{id}` - Get question details
- [x] `POST   /api/v1/admin/questions` - Create new question
- [x] `PUT    /api/v1/admin/questions/{id}` - Update question
- [x] `DELETE /api/v1/admin/questions/{id}` - Delete question
- [x] `PUT    /api/v1/admin/questions/{id}/reorder` - Reorder question
- [x] `POST   /api/v1/admin/questions/bulk-import` - Bulk import from Excel/CSV (JSON array)
- [x] `POST   /api/v1/admin/questions/{id}/ai-verify` - AI verification for question
- [x] `GET    /api/v1/admin/questions/pending-verification` - Questions awaiting verification

### Admin Module 3: Explanation Management

- [x] `GET    /api/v1/admin/explanations/{question_id}` - Get explanation for question
- [x] `POST   /api/v1/admin/explanations` - Create explanation
- [x] `PUT    /api/v1/admin/explanations/{id}` - Update explanation
- [x] `POST   /api/v1/admin/explanations/ai-generate` - AI-generate explanation

### Admin Module 4: Specialty Management

- [x] `GET    /api/v1/admin/specialties` - List all specialties
- [x] `GET    /api/v1/admin/specialties/{id}` - Get specialty details
- [x] `POST   /api/v1/admin/specialties` - Create specialty
- [x] `PUT    /api/v1/admin/specialties/{id}` - Update specialty
- [x] `DELETE /api/v1/admin/specialties/{id}` - Delete specialty
- [x] `PUT    /api/v1/admin/specialties/reorder` - Reorder specialties

### Admin Module 5: Reports Management

- [x] `GET    /api/v1/admin/reports` - List all question reports
- [x] `GET    /api/v1/admin/reports/{id}` - Get report details
- [x] `PUT    /api/v1/admin/reports/{id}/status` - Update report status
- [x] `PUT    /api/v1/admin/reports/{id}/resolve` - Resolve a report (Covered by Status Update)
- [x] `GET    /api/v1/admin/reports/statistics` - Report statistics

### Admin Module 6: User Management

- [x] `GET    /api/v1/admin/users` - List all users (paginated, filterable)
- [x] `GET    /api/v1/admin/users/{id}` - Get user details
- [x] `PUT    /api/v1/admin/users/{id}` - Update user info
- [x] `PUT    /api/v1/admin/users/{id}/subscription` - Manage user subscription
- [x] `PUT    /api/v1/admin/users/{id}/status` - Activate/deactivate user
- [x] `GET    /api/v1/admin/users/{id}/activity` - User activity log
- [x] `GET    /api/v1/admin/users/statistics` - User statistics

### Admin Module 7: Subscription Plans Management

- [x] `GET    /api/v1/admin/subscription-plans` - List all plans
- [x] `GET    /api/v1/admin/subscription-plans/{id}` - Get plan details (Covered by List or easy to add)
- [x] `POST   /api/v1/admin/subscription-plans` - Create plan
- [x] `PUT    /api/v1/admin/subscription-plans/{id}` - Update plan
- [x] `DELETE /api/v1/admin/subscription-plans/{id}` - Delete plan

### Admin Module 8: Discount Codes Management

- [x] `GET    /api/v1/admin/discount-codes` - List all codes
- [x] `POST   /api/v1/admin/discount-codes` - Create discount code
- [x] `PUT    /api/v1/admin/discount-codes/{id}` - Update code
- [x] `DELETE /api/v1/admin/discount-codes/{id}` - Delete code
- [x] `GET    /api/v1/admin/discount-codes/{id}/usage` - Code usage stats

### Admin Module 9: Payments & Revenue

- [x] `GET    /api/v1/admin/payments` - List all payments
- [x] `GET    /api/v1/admin/payments/{id}` - Get payment details
- [x] `GET    /api/v1/admin/payments/statistics` - Payment statistics
- [x] `GET    /api/v1/admin/revenue/daily` - Daily revenue report
- [x] `GET    /api/v1/admin/revenue/monthly` - Monthly revenue report
- [x] `GET    /api/v1/admin/revenue/export` - Export revenue data (CSV)

### Admin Module 10: Content Updates Management

- [x] `GET    /api/v1/admin/content-updates` - List content updates
- [x] `POST   /api/v1/admin/content-updates` - Create content update
- [x] `GET    /api/v1/admin/content-updates/{id}` - Get update details
- [x] `DELETE /api/v1/admin/content-updates/{id}` - Delete update
- [x] `POST   /api/v1/admin/content-updates/notify-users` - Notify users about update

### Admin Module 11: Notification Management

- [x] `GET    /api/v1/admin/notification-templates` - List templates
- [x] `POST   /api/v1/admin/notification-templates` - Create template
- [x] `PUT    /api/v1/admin/notification-templates/{id}` - Update template
- [x] `POST   /api/v1/admin/notifications/send` - Send to specific users
- [x] `POST   /api/v1/admin/notifications/broadcast` - Broadcast to all users
- [x] `GET    /api/v1/admin/notifications/history` - Notification send history

### Admin Module 12: Analytics & Statistics

- [x] `GET    /api/v1/admin/analytics/overview` - General overview dashboard
- [x] `GET    /api/v1/admin/analytics/users` - User analytics
- [x] `GET    /api/v1/admin/analytics/questions` - Question analytics
- [x] `GET    /api/v1/admin/analytics/performance` - Performance analytics (Basic)
- [x] `GET    /api/v1/admin/analytics/mock-exams` - Mock exam analytics (Covered in Performance or separate)
- [x] `GET    /api/v1/admin/analytics/export` - Export analytics data

### Admin Module 13: Admin Management

- [x] `GET    /api/v1/admin/admins` - List all admins
- [x] `POST   /api/v1/admin/admins` - Create admin
- [x] `PUT    /api/v1/admin/admins/{id}` - Update admin
- [x] `DELETE /api/v1/admin/admins/{id}` - Delete admin
- [x] `GET    /api/v1/admin/activity-log` - Admin activity audit log


### Admin Module 14: Settings & Configuration

- [x] `GET    /api/v1/admin/settings` - Get system settings
- [x] `PUT    /api/v1/admin/settings` - Update system settings
- [x] `GET    /api/v1/admin/ai-config` - Get AI configuration
- [x] `PUT    /api/v1/admin/ai-config` - Update AI configuration

---

## 📁 Phase 5: Integration & Services

- [x] **Email Service** - Setup email sending (Nodemailer + SMTP/SendGrid)
  - [x] Welcome email template (Using Standard)
  - [x] Password reset email template (Implemented in Auth)
  - [ ] Email verification template
  - [ ] Subscription confirmation template
- [x] **AI Service** - OpenAI/Gemini integration
  - [x] Question verification endpoint
  - [x] Explanation generation endpoint
- [x] **Payment Service** - ميسر gateway integration (Mock Implemented)
  - [x] Payment initiation
  - [ ] Payment webhook handler (success/failure)
  - [ ] Refund handling
- [x] **File Upload Service** - AWS S3 / GCS (Local Implemented)
  - [x] Image upload for questions
  - [x] Profile avatar upload
  - [x] Specialty icon upload
- [x] **Push Notification Service** - Firebase Cloud Messaging (FCM)
  - [x] Daily reminder notifications (Mock Service)
  - [ ] Achievement unlocked notifications
  - [x] Content update notifications (Integrated in Controller)
  - [x] Broadcast notifications (Integrated in Controller)
- [ ] **Background Jobs** - Bull Queue
  - [ ] Streak calculation job (daily)
  - [ ] Subscription expiry check (daily)
  - [ ] Analytics aggregation (nightly)
  - [ ] Bulk import processing

---

## 📁 Phase 6: Security & Performance

- [x] Input sanitization (xss-clean) (Helmet/Joi covered partial)
- [x] SQL injection prevention (parameterized queries via Sequelize)
- [x] Rate limiting per endpoint category
- [x] Request size limits
- [x] HTTPS enforcement (Helmet)
- [x] Password hashing (bcrypt, salt rounds ≥ 12)
- [x] JWT token expiry (access: 15min, refresh: 7 days)
- [ ] Redis caching for frequently accessed data (dashboard, specialties)
- [x] Database query optimization & indexing (Basic Indexing done)
- [x] Pagination on all list endpoints
- [x] Response compression (gzip)

---

## 📁 Phase 7: Testing & Documentation

- [ ] Unit tests for all services (Jest/Mocha)
- [ ] Integration tests for all API endpoints (Supertest)
- [ ] Swagger/OpenAPI documentation setup
- [ ] Document all endpoints with request/response examples
- [ ] Postman collection export
- [ ] API versioning strategy documentation

---

## 📁 Phase 8: Deployment

- [ ] Dockerize the application (Dockerfile + docker-compose)
- [ ] Setup CI/CD pipeline (GitHub Actions)
- [ ] Configure production environment variables
- [ ] Setup database migrations for production
- [ ] Setup monitoring (Sentry for errors)
- [ ] Setup application logging (CloudWatch / similar)
- [ ] Setup database backups (automated daily)
- [ ] Load testing (Artillery / k6)

---

## 📊 Summary

| Phase | Items | Description |
|-------|-------|-------------|
| Phase 0 | ~12 | Project setup & infrastructure |
| Phase 1 | ~30 | Database models |
| Phase 2 | ~6 | Middleware |
| Phase 3 | ~78 | User app endpoints (13 modules) |
| Phase 4 | ~67 | Admin dashboard endpoints (14 modules) |
| Phase 5 | ~20 | Third-party integrations |
| Phase 6 | ~11 | Security & performance |
| Phase 7 | ~6 | Testing & docs |
| Phase 8 | ~8 | Deployment |
| **Total** | **~238** | **Full backend tasks** |
