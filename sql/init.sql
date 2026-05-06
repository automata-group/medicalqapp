
-- =============================================
-- DATABASE SETUP
-- =============================================
CREATE DATABASE IF NOT EXISTS medical_qbank
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE medical_qbank;

-- =============================================
-- USERS & AUTH
-- =============================================

CREATE TABLE users (
 user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 email VARCHAR(255) UNIQUE NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 full_name VARCHAR(255) NOT NULL,
 phone VARCHAR(50),
 profile_image_url VARCHAR(500),
 is_active BOOLEAN DEFAULT TRUE,
 is_email_verified BOOLEAN DEFAULT FALSE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 last_login_at TIMESTAMP NULL DEFAULT NULL,
 deleted_at TIMESTAMP NULL DEFAULT NULL, -- Soft Delete
 INDEX idx_email (email),
 INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_study_settings (
 user_id BIGINT PRIMARY KEY,
 study_target_date DATE,
 daily_study_hours DECIMAL(3,1),
 marketing_opt_in BOOLEAN DEFAULT FALSE,
 notification_preferences JSON,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_sessions (
 session_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 token_hash VARCHAR(255) NOT NULL,
 device_info VARCHAR(500),
 ip_address VARCHAR(45),
 expires_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 UNIQUE KEY uk_token_hash (token_hash),
 INDEX idx_user_expires (user_id, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SUBSCRIPTIONS & PAYMENTS
-- =============================================

CREATE TABLE subscription_plans (
 plan_id INT PRIMARY KEY AUTO_INCREMENT,
 plan_name VARCHAR(100) NOT NULL,
 duration_months INT NOT NULL,
 price DECIMAL(10,2) NOT NULL,
 currency VARCHAR(3) DEFAULT 'USD',
 features JSON,
 is_active BOOLEAN DEFAULT TRUE,
 display_order INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 deleted_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_subscriptions (
 subscription_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 plan_id INT NOT NULL,
 start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 end_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 is_active BOOLEAN DEFAULT TRUE,
 auto_renew BOOLEAN DEFAULT FALSE,
 payment_method VARCHAR(50),
 price_snapshot DECIMAL(10,2) NOT NULL,
 currency_snapshot VARCHAR(3) DEFAULT 'USD',
 features_snapshot JSON,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id),
 INDEX idx_user_active (user_id, is_active),
 INDEX idx_end_date (end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE discount_codes (
 code_id INT PRIMARY KEY AUTO_INCREMENT,
 code VARCHAR(50) UNIQUE NOT NULL,
 discount_type ENUM('percentage', 'fixed') NOT NULL,
 discount_value DECIMAL(10,2) NOT NULL,
 min_order_amount DECIMAL(10,2) DEFAULT 0,
 max_uses INT,
 current_uses INT DEFAULT 0,
 valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 valid_until TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 is_active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_code (code),
 INDEX idx_valid_dates (valid_from, valid_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payments (
 payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 subscription_id BIGINT,
 amount DECIMAL(10,2) NOT NULL,
 currency VARCHAR(3) DEFAULT 'USD',
 exchange_rate DECIMAL(10,6) DEFAULT 1.000000,
 payment_method VARCHAR(50),
 payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL,
 transaction_id VARCHAR(255),
 discount_code_id INT,
 discount_amount DECIMAL(10,2) DEFAULT 0,
 final_amount DECIMAL(10,2) NOT NULL,
 payment_gateway_response JSON,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT, -- Protect financial history
 FOREIGN KEY (subscription_id) REFERENCES user_subscriptions(subscription_id),
 FOREIGN KEY (discount_code_id) REFERENCES discount_codes(code_id),
 INDEX idx_user_payment (user_id, created_at),
 INDEX idx_status (payment_status),
 INDEX idx_transaction_id (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE referrals (
 referral_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 referrer_user_id BIGINT NOT NULL,
 referred_user_id BIGINT NOT NULL,
 referral_code VARCHAR(50) NOT NULL,
 status ENUM('pending', 'completed', 'expired') DEFAULT 'pending',
 reward_type VARCHAR(50),
 reward_value DECIMAL(10,2),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 completed_at TIMESTAMP NULL DEFAULT NULL,
 FOREIGN KEY (referrer_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (referred_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 INDEX idx_referrer (referrer_user_id),
 INDEX idx_code (referral_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SPECIALTIES & CONTENT STRUCTURE
-- =============================================

CREATE TABLE specialties (
 specialty_id INT PRIMARY KEY AUTO_INCREMENT,
 specialty_name VARCHAR(255) NOT NULL,
 specialty_code VARCHAR(50) UNIQUE NOT NULL,
 description TEXT,
 icon_url VARCHAR(500),
 display_order INT,
 is_active BOOLEAN DEFAULT TRUE,
 total_questions INT DEFAULT 0,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 deleted_at TIMESTAMP NULL DEFAULT NULL,
 INDEX idx_active_order (is_active, display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_specialties (
 user_specialty_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 specialty_id INT NOT NULL,
 selected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) ON DELETE CASCADE,
 UNIQUE KEY uk_user_specialty (user_id, specialty_id),
 INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- QUESTIONS & ANSWERS
-- =============================================

CREATE TABLE questions (
 question_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 specialty_id INT NOT NULL,
 question_text TEXT NOT NULL,
 question_number INT,
 difficulty_level ENUM('easy', 'medium', 'hard'),
 question_source VARCHAR(255),
 image_url VARCHAR(500),
 estimated_time_seconds INT DEFAULT 60,
 is_active BOOLEAN DEFAULT TRUE,
 is_free BOOLEAN DEFAULT FALSE,
 ai_verified BOOLEAN DEFAULT FALSE,
 ai_verification_date TIMESTAMP NULL DEFAULT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 deleted_at TIMESTAMP NULL DEFAULT NULL,
 created_by_admin_id BIGINT,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id),
 INDEX idx_specialty_active (specialty_id, is_active),
 INDEX idx_free (is_free),
 FULLTEXT idx_question_text (question_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_options (
 option_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 question_id BIGINT NOT NULL,
 option_label CHAR(1) NOT NULL,
 option_text TEXT NOT NULL,
 is_correct BOOLEAN NOT NULL DEFAULT FALSE,
 explanation TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 UNIQUE KEY uk_question_label (question_id, option_label),
 INDEX idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_explanations (
 explanation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 question_id BIGINT NOT NULL,
 correct_explanation TEXT NOT NULL,
 why_others_wrong TEXT,
 `references` TEXT,
 ai_generated BOOLEAN DEFAULT TRUE,
 ai_model VARCHAR(100),
 user_feedback_score DECIMAL(3,2) DEFAULT NULL COMMENT 'Rating 1-5',
 verified_by_admin_id BIGINT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 UNIQUE KEY uk_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_tags (
 tag_id INT PRIMARY KEY AUTO_INCREMENT,
 tag_name VARCHAR(100) UNIQUE NOT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_tag_mapping (
 question_id BIGINT NOT NULL,
 tag_id INT NOT NULL,
 PRIMARY KEY (question_id, tag_id),
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 FOREIGN KEY (tag_id) REFERENCES question_tags(tag_id) ON DELETE CASCADE,
 INDEX idx_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- USER INTERACTION (PARTITIONED)
-- =============================================

CREATE TABLE user_answers (
 answer_id BIGINT NOT NULL AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 question_id BIGINT NOT NULL,
 selected_option_id BIGINT NOT NULL,
 is_correct BOOLEAN NOT NULL,
 time_spent_seconds INT,
 answered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 session_type ENUM('practice', 'mock_exam') NOT NULL,
 mock_exam_id BIGINT,
 PRIMARY KEY (answer_id, answered_at),
 INDEX idx_user_question (user_id, question_id),
 INDEX idx_user_session (user_id, session_type, answered_at),
 INDEX idx_mock_exam (mock_exam_id),
 INDEX idx_user_correct (user_id, is_correct)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY RANGE (UNIX_TIMESTAMP(answered_at)) (
 PARTITION p2025 VALUES LESS THAN (UNIX_TIMESTAMP('2026-01-01 00:00:00')),
 PARTITION p2026 VALUES LESS THAN (UNIX_TIMESTAMP('2027-01-01 00:00:00')),
 PARTITION p2027 VALUES LESS THAN (UNIX_TIMESTAMP('2028-01-01 00:00:00')),
 PARTITION p2028 VALUES LESS THAN (UNIX_TIMESTAMP('2029-01-01 00:00:00')),
 PARTITION p_future VALUES LESS THAN MAXVALUE
);

CREATE TABLE user_bookmarks (
 bookmark_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 question_id BIGINT NOT NULL,
 notes TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 UNIQUE KEY uk_user_question (user_id, question_id),
 INDEX idx_user (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_reports (
 report_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 question_id BIGINT NOT NULL,
 report_type ENUM('scientific_error', 'language_error', 'typo', 'other') NOT NULL,
 description TEXT NOT NULL,
 status ENUM('pending', 'under_review', 'resolved', 'rejected') DEFAULT 'pending',
 admin_notes TEXT,
 reviewed_by_admin_id BIGINT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 reviewed_at TIMESTAMP NULL DEFAULT NULL,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 INDEX idx_status (status),
 INDEX idx_question (question_id),
 INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- MOCK EXAMS
-- =============================================

CREATE TABLE mock_exams (
 mock_exam_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 exam_type VARCHAR(100),
 total_questions INT NOT NULL,
 total_sections INT DEFAULT 2,
 time_limit_minutes INT,
 status ENUM('in_progress', 'completed', 'abandoned') DEFAULT 'in_progress',
 started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 completed_at TIMESTAMP NULL DEFAULT NULL,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 INDEX idx_user_status (user_id, status),
 INDEX idx_started (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mock_exam_sections (
 section_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 mock_exam_id BIGINT NOT NULL,
 section_number INT NOT NULL,
 questions_count INT NOT NULL,
 time_limit_minutes INT NOT NULL,
 started_at TIMESTAMP NULL DEFAULT NULL,
 completed_at TIMESTAMP NULL DEFAULT NULL,
 time_spent_seconds INT,
 FOREIGN KEY (mock_exam_id) REFERENCES mock_exams(mock_exam_id) ON DELETE CASCADE,
 UNIQUE KEY uk_exam_section (mock_exam_id, section_number),
 INDEX idx_mock_exam (mock_exam_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mock_exam_questions (
 mock_exam_question_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 mock_exam_id BIGINT NOT NULL,
 section_id BIGINT NOT NULL,
 question_id BIGINT NOT NULL,
 question_order INT NOT NULL,
 FOREIGN KEY (mock_exam_id) REFERENCES mock_exams(mock_exam_id) ON DELETE CASCADE,
 FOREIGN KEY (section_id) REFERENCES mock_exam_sections(section_id) ON DELETE CASCADE,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE RESTRICT,
 UNIQUE KEY uk_exam_question (mock_exam_id, question_id),
 INDEX idx_section_order (section_id, question_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mock_exam_results (
 result_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 mock_exam_id BIGINT NOT NULL,
 user_id BIGINT NOT NULL,
 total_questions INT NOT NULL,
 correct_answers INT NOT NULL,
 wrong_answers INT NOT NULL,
 unanswered INT DEFAULT 0,
 score_percentage DECIMAL(5,2) NOT NULL,
 total_time_spent_seconds INT,
 avg_time_per_question_seconds INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (mock_exam_id) REFERENCES mock_exams(mock_exam_id) ON DELETE CASCADE,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 UNIQUE KEY uk_mock_exam (mock_exam_id),
 INDEX idx_user_score (user_id, score_percentage)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mock_exam_specialty_analysis (
 analysis_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 result_id BIGINT NOT NULL,
 specialty_id INT NOT NULL,
 total_questions INT NOT NULL,
 correct_answers INT NOT NULL,
 accuracy_percentage DECIMAL(5,2) NOT NULL,
 avg_time_seconds INT,
 FOREIGN KEY (result_id) REFERENCES mock_exam_results(result_id) ON DELETE CASCADE,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id),
 INDEX idx_result (result_id),
 INDEX idx_specialty (specialty_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- PROGRESS & STATISTICS
-- =============================================

CREATE TABLE user_specialty_progress (
 progress_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 specialty_id INT NOT NULL,
 total_questions_available INT NOT NULL,
 questions_attempted INT DEFAULT 0,
 questions_correct INT DEFAULT 0,
 completion_percentage DECIMAL(5,2) DEFAULT 0,
 last_activity_at TIMESTAMP NULL DEFAULT NULL,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id) ON DELETE CASCADE,
 UNIQUE KEY uk_user_specialty (user_id, specialty_id),
 INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_daily_stats (
 stat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 stat_date DATE NOT NULL,
 questions_attempted INT DEFAULT 0,
 questions_correct INT DEFAULT 0,
 study_time_minutes INT DEFAULT 0,
 mock_exams_taken INT DEFAULT 0,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 UNIQUE KEY uk_user_date (user_id, stat_date),
 INDEX idx_user_date (user_id, stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_weak_areas (
 weak_area_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 specialty_id INT NOT NULL,
 tag_id INT,
 error_count INT DEFAULT 0,
 total_attempts INT DEFAULT 0,
 error_rate DECIMAL(5,2),
 last_error_at TIMESTAMP NULL DEFAULT NULL,
 is_active BOOLEAN DEFAULT TRUE,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id),
 FOREIGN KEY (tag_id) REFERENCES question_tags(tag_id),
 INDEX idx_user_specialty (user_id, specialty_id),
 INDEX idx_error_rate (user_id, error_rate DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ACHIEVEMENTS & NOTIFICATIONS
-- =============================================

CREATE TABLE achievement_types (
 achievement_type_id INT PRIMARY KEY AUTO_INCREMENT,
 achievement_name VARCHAR(255) NOT NULL,
 achievement_code VARCHAR(50) UNIQUE NOT NULL,
 description TEXT,
 icon_url VARCHAR(500),
 badge_color VARCHAR(7),
 criteria JSON NOT NULL,
 points_reward INT DEFAULT 0,
 display_order INT,
 is_active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_achievements (
 user_achievement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 achievement_type_id INT NOT NULL,
 earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 progress_data JSON,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (achievement_type_id) REFERENCES achievement_types(achievement_type_id),
 UNIQUE KEY uk_user_achievement (user_id, achievement_type_id),
 INDEX idx_user (user_id, earned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_streaks (
 streak_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 current_streak_days INT DEFAULT 0,
 longest_streak_days INT DEFAULT 0,
 last_activity_date DATE,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 UNIQUE KEY uk_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notification_templates (
 template_id INT PRIMARY KEY AUTO_INCREMENT,
 template_code VARCHAR(50) UNIQUE NOT NULL,
 title VARCHAR(255) NOT NULL,
 body TEXT NOT NULL,
 notification_type ENUM('reminder', 'update', 'achievement', 'system') NOT NULL,
 is_active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_notifications (
 notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 template_id INT,
 title VARCHAR(255) NOT NULL,
 body TEXT NOT NULL,
 notification_type ENUM('reminder', 'update', 'achievement', 'system') NOT NULL,
 related_entity_type VARCHAR(50),
 related_entity_id BIGINT,
 is_read BOOLEAN DEFAULT FALSE,
 sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 read_at TIMESTAMP NULL DEFAULT NULL,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 FOREIGN KEY (template_id) REFERENCES notification_templates(template_id),
 INDEX idx_user_unread (user_id, is_read, sent_at),
 INDEX idx_sent (sent_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- CONTENT UPDATES & VERSIONING
-- =============================================

CREATE TABLE content_updates (
 update_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 update_type ENUM('question_added', 'question_modified', 'question_deleted', 'guideline_changed', 'specialty_updated') NOT NULL,
 entity_type VARCHAR(50) NOT NULL,
 entity_id BIGINT NOT NULL,
 description TEXT,
 change_details JSON,
 created_by_admin_id BIGINT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_type_date (update_type, created_at),
 INDEX idx_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE question_history (
 history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 question_id BIGINT NOT NULL,
 question_text TEXT NOT NULL,
 change_type ENUM('created', 'updated', 'deleted') NOT NULL,
 changed_fields JSON,
 changed_by_admin_id BIGINT,
 changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
 INDEX idx_question_date (question_id, changed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ADMIN & MANAGEMENT
-- =============================================

CREATE TABLE admins (
 admin_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 email VARCHAR(255) UNIQUE NOT NULL,
 password_hash VARCHAR(255) NOT NULL,
 full_name VARCHAR(255) NOT NULL,
 role ENUM('super_admin', 'content_manager', 'support') NOT NULL,
 permissions JSON,
 is_active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 last_login_at TIMESTAMP NULL DEFAULT NULL,
 INDEX idx_email (email),
 INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admin_activity_log (
 log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 admin_id BIGINT NOT NULL,
 action_type VARCHAR(100) NOT NULL,
 entity_type VARCHAR(50),
 entity_id BIGINT,
 description TEXT,
 ip_address VARCHAR(45),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE,
 INDEX idx_admin_date (admin_id, created_at),
 INDEX idx_action (action_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- OFFLINE SYNC
-- =============================================

CREATE TABLE user_offline_data (
 sync_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 data_type VARCHAR(50) NOT NULL,
 data_payload JSON NOT NULL,
 sync_status ENUM('pending', 'synced', 'failed') DEFAULT 'pending',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 synced_at TIMESTAMP NULL DEFAULT NULL,
 FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
 INDEX idx_user_status (user_id, sync_status),
 INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- PERFORMANCE COMPARISON
-- =============================================

CREATE TABLE global_performance_stats (
 stat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 specialty_id INT,
 calculation_date DATE NOT NULL,
 total_users INT,
 avg_score_percentage DECIMAL(5,2),
 avg_completion_percentage DECIMAL(5,2),
 avg_time_per_question_seconds INT,
 FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id),
 UNIQUE KEY uk_specialty_date (specialty_id, calculation_date),
 INDEX idx_date (calculation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;