Phase 0: Architecture & Core Setup (Completed ✅)
[x] Initialize project with Clean Architecture (Data, Domain, Presentation).

[x] Setup Material 3 Theme (Light/Dark mode) - Optimized for medical reading.

[x] Setup Localization (l10n): Arabic & English support.

[x] Setup API Client (Dio) with JWT Interceptors.

[x] Setup Secure Storage for Auth tokens.

[x] Setup Global Error Handling & Loaders.

📁 Phase 1: Authentication & User Management (Completed ✅)
[x] Onboarding Screen: Introduction to the "Mastery" learning method.

[x] Register: Form with validation (Name, Email, Specialty selection).

[x] Login: Email/Password with "Remember Me".

[x] Forgot/Reset Password flow.

[x] Email Verification (OTP Screen).

[x] Profile Screen (Lama Edition): Display user name, email, and mastery stats.

[x] Subscription Guard: Logic to lock premium Dental content.

📁 Phase 2: Specialty & Study Plan (Completed ✅)
[x] Specialty Selector: Multi-select Dental specialties (Orthodontics, Endodontics, etc.).

[x] Study Goal Setup: Exam date countdown + Daily study hours.

[x] User Interests: Syncing selected specialties with Backend.

📁 Phase 3: Home Dashboard (The Pulse)
[x] Progress Overview: Circular bars for overall completion.

[x] Mastery Stats: Quick view of (Know 🟢 / Somewhat 🟡 / Don't Know 🔴) counts.

[x] Weak Areas: Bar charts showing lower-performing Dental sub-topics.

[x] Recent Activity: Quick resume last studied sub-topic.

[x] Notifications Center: Updates on new dental guidelines or question banks.

📁 Phase 4: Practice Mode (The Mastery Engine - CRITICAL 🔴)
[x] Sub-Topic Navigation: Clicking a specialty opens a list of sub-categories (e.g., Endodontics -> Trauma, Obturation).

[x] Question Player (Mastery Edition):

[x] Multiple-choice UI with smooth transitions.

[x] Confidence Buttons: Add (Don't Know 🔴, Somewhat Know 🟡, Know 🟢) below each question.

[x] Immediate Feedback: (Green/Red) + Scientific Explanation.

[x] AI Insights: Toggle for AI-generated mnemonics (طرق حفظ) and summaries.

[x] Clinical Media: High-res X-rays and clinical photos with Zoom functionality.

[x] Bookmark Toggle: Save difficult cases.

[x] Report Button: Report scientific errors in dental questions.

[x] Filters: Filter by (New, Mistaken, or Confidence Level).

📁 Phase 5: Mock Exam System (Simulation Mode)
[x] Exam Start Screen: Instructions for the 420-question challenge.

[x] Exam Interface:

[x] Countdown Timer: 2-hour limit per section.

[x] Question Navigator: Grid for 210 questions.

[x] Section Transition: Logic for Part 1 & Part 2 with a scheduled break.

[x] Flag for Review: Mark questions to return to later.

[x] Results Summary: Score %, Passing status, and "Review Mode" (Hide answers until the end).

📁 Phase 6: Statistics & Gamification
[x] Performance Trends: Line charts (Weekly/Monthly).

[x] Mastery Growth: Animation showing questions moving from "Red" to "Green".

[x] Achievements Gallery: Badges like "Endo King", "Fast Learner", "Streak Master".

[x] Analytics:

[x] Peer Comparison: Compare your mastery level with the average of other dental students.

[x] Time Report: Time spent per dental specialty.

📁 Phase 7: Subscription & Monetization
[x] Free Tier: 15 free questions limit per dental specialty.

[x] Pricing Table: Monthly, 6 Months, and Yearly "Full Access" plans.

[x] Payment Integration: Moyasar / Apple Pay / Mada.

[x] Discount & Referral System: Promo codes for dental groups/interns.

📁 Phase 8: Offline Mode & Advanced UX
[x] Dental Bank Downloader: Download specific specialties for offline study.

[x] Local DB (SQLite): Store questions and images locally.

[x] Smart Reminders: "You haven't studied Ortho in 3 days!"

📁 Phase 9: Admin Dashboard (The Control Room) (Completed ✅)
[x] User Management: Track student progress and subscriptions.

[x] Question Manager:

[x] Add/Edit Questions + Mapping to Sub-categories.

[x] Ordering: Manual sorting of questions.

[x] Media Upload: Attach X-rays and Clinical photos to questions.

[x] Report Review: Fix reported scientific errors.

[x] Content Updates: Push notifications for new dental board updates.