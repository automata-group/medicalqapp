-- =============================================
-- MIGRATION: Add Missing Tables
-- Run this if ai_feedbacks or study_sessions
-- tables don't exist in your database.
-- =============================================

USE medical_qbank;

-- =============================================
-- AI FEEDBACK TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS `AIFeedbacks` (
  `id`           INT NOT NULL AUTO_INCREMENT,
  `userId`       BIGINT NOT NULL,
  `content`      TEXT NOT NULL,
  `analysisType` ENUM('mistake_analysis','study_plan','performance_summary')
                 NOT NULL DEFAULT 'mistake_analysis',
  `isRead`       TINYINT(1) NOT NULL DEFAULT 0,
  `expiresAt`    DATETIME NOT NULL,
  `createdAt`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_expires` (`userId`, `expiresAt`),
  CONSTRAINT `fk_aifeedback_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`user_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- STUDY SESSIONS TABLE (for Resume feature)
-- =============================================
CREATE TABLE IF NOT EXISTS `StudySessions` (
  `id`              INT NOT NULL AUTO_INCREMENT,
  `userId`          BIGINT NOT NULL,
  `specialtyId`     VARCHAR(50) NULL,
  `subTopic`        VARCHAR(255) NULL,
  `filter`          VARCHAR(100) NULL,
  `sessionType`     VARCHAR(50) NOT NULL DEFAULT 'general',
  `attemptedIds`    TEXT NULL,
  `lastQuestionId`  INT NULL,
  `isActive`        TINYINT(1) NOT NULL DEFAULT 1,
  `createdAt`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_active`    (`userId`, `isActive`),
  INDEX `idx_user_specialty` (`userId`, `specialtyId`, `subTopic`, `sessionType`),
  CONSTRAINT `fk_studysession_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`user_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- QuestionAttempts TABLE (if missing)
-- =============================================
CREATE TABLE IF NOT EXISTS `QuestionAttempts` (
  `id`               INT NOT NULL AUTO_INCREMENT,
  `userId`           BIGINT NOT NULL,
  `questionId`       INT NOT NULL,
  `selectedOptionId` INT NOT NULL,
  `isCorrect`        TINYINT(1) NOT NULL,
  `confidenceLevel`  ENUM('low','medium','high') NULL,
  `timeTaken`        INT NOT NULL DEFAULT 0,
  `mode`             ENUM('practice','mock','daily') NOT NULL DEFAULT 'practice',
  `createdAt`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                     ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_correct` (`userId`, `isCorrect`),
  INDEX `idx_user_question` (`userId`, `questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
