# Medical QBank Application - System Documentation

## 1. Project Overview
The Medical QBank is a high-performance educational platform designed for medical students to practice and master licensing exams. It features a comprehensive question bank, specialized libraries, and an AI-driven learning experience.

---

## 2. System Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.x (Dart)
- **State Management**: `Provider` for reactive UI and clean separation of concerns.
- **Networking**: `Dio` with a centralized `DioClient` for API communication.
- **Local Storage**: Offline support via local data sources.
- **Localization**: Multi-language support (Arabic/English) using `.arb` files.

### Backend (Node.js)
- **Runtime**: Node.js (Express.js framework)
- **Database**: PostgreSQL with `Sequelize` ORM for data integrity and complex queries.
- **Architecture**: Controller-Service-Model pattern.

---

## 3. Core Features

### 3.1 Dashboard (Home)
- **Personalized Stats**: Accuracy, Total Solved, and Study Streaks.
- **Continue Revision Section**: A smart section that allows users to resume their last study session directly.
- **Question Bank Access**: Quick access to random practice from all specialties.

### 3.2 Practice & Exam System
- **Random Mode**: Questions are shuffled, and options are randomized for optimal learning.
- **Sequential Mode**: Optimized for "Continuing Revision" where questions appear in order (ID-based) and options remain fixed.
- **Real-time Feedback**: Instant correct/wrong animations and detailed scientific explanations.
- **Topic Filtering**: Users can filter by "New", "Mastered", or "Bookmarked" questions.

### 3.3 Medical Library
- **Specialty Hierarchy**: Browse by Medical Specialty (e.g., Orthodontics, Endodontics).
- **Sub-topic Mastery**: Drill down into specific topics within a specialty to focus on weak areas.
- **Progress Tracking**: Visual coverage bars for every specialty and topic.

---

## 4. Key Data Models

### `DashboardOverviewModel`
Contains all aggregated stats for the home screen, including `ContinueRevisionModel` items.

### `QuestionModel`
Defines the structure of a question, including text, difficulty, specialty, and a list of `OptionModel` objects.

### `ContinueRevisionModel`
Tracks the user's last interaction with a specific topic or specialty to enable seamless resumption. Fields include:
- `specialtyId`, `topicId`, `topicName`, `timestamp`, `type`.

---

## 5. Recent Enhancements (Session April 2026)

### Direct Resumption Logic
- Updated the "Continue" action to bypass topic selection pages.
- Navigation now goes directly to `ExamScreen` with specific `subTopic` and `specialtyId`.

### Sequential Practice (No-Shuffle)
- Added `shuffle=false` support to the backend `getNextQuestion` API.
- The `QuestionProvider` now conditionally disables option shuffling when in sequential mode.

### Interface Cleanup
- Removed the legacy specialties carousel to focus on the main Question Bank card.
- Standardized navigation from both the Library and Dashboard to use the same logic.

---

## 6. API Endpoints (Highlights)
- `GET /api/dashboard/overview`: Fetches all home screen data.
- `GET /api/questions/practice/next`: Dynamic question fetching with parameters (`specialtyId`, `subTopic`, `shuffle`, `exclude`).
- `POST /api/questions/:id/answer`: Submits answers and updates user progress.

---

## 7. Developer Notes
- **State Management**: Always use `context.read<T>()` for actions and `context.watch<T>()` for UI updates inside `build` methods.
- **Navigation**: Use the constructor of `ExamScreen` to pass parameters rather than setting provider state manually before navigation to avoid race conditions.

---
*Documentation generated on: 2026-04-28*
