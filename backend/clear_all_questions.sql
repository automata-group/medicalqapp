-- ==============================================================================
-- WIPE ALL QUESTIONS, OPTIONS, EXPLANATIONS, AND ATTEMPTS FROM PRODUCTION
-- Preserves Users, Specialties, Topics, Subscriptions, and Payments intact.
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Options;
TRUNCATE TABLE Explanations;
TRUNCATE TABLE QuestionStats;
TRUNCATE TABLE QuestionAttempts;
TRUNCATE TABLE Bookmarks;
TRUNCATE TABLE QuestionReports;
TRUNCATE TABLE UserProgresses;
TRUNCATE TABLE Questions;

SET FOREIGN_KEY_CHECKS = 1;

SELECT COUNT(*) AS total_questions_remaining FROM Questions;
