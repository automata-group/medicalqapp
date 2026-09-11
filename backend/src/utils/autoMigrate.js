const sequelize = require('../config/database');

/**
 * Safely ensure newly introduced columns exist in tables
 * without requiring destructive migrations or failing on older schemas.
 */
async function autoMigrate() {
    try {
        const queryInterface = sequelize.getQueryInterface();

        // 1. Users table
        try {
            const userTableDesc = await queryInterface.describeTable('Users');
            if (!userTableDesc.googleId) {
                await sequelize.query("ALTER TABLE `Users` ADD COLUMN `googleId` VARCHAR(255) NULL");
                console.log("✅ AutoMigrate: Added googleId to Users");
            }
            if (!userTableDesc.appleId) {
                await sequelize.query("ALTER TABLE `Users` ADD COLUMN `appleId` VARCHAR(255) NULL");
                console.log("✅ AutoMigrate: Added appleId to Users");
            }
            if (!userTableDesc.authProvider) {
                await sequelize.query("ALTER TABLE `Users` ADD COLUMN `authProvider` VARCHAR(50) DEFAULT 'local'");
                console.log("✅ AutoMigrate: Added authProvider to Users");
            }
        } catch (e) {
            console.warn("⚠️ AutoMigrate Users check:", e.message);
        }

        // 2. MockExams table
        try {
            const mockTableDesc = await queryInterface.describeTable('MockExams');
            if (!mockTableDesc.breakDuration) {
                await sequelize.query("ALTER TABLE `MockExams` ADD COLUMN `breakDuration` INT DEFAULT 30");
                console.log("✅ AutoMigrate: Added breakDuration to MockExams");
            }
            if (!mockTableDesc.hasBreak) {
                await sequelize.query("ALTER TABLE `MockExams` ADD COLUMN `hasBreak` TINYINT(1) DEFAULT 0");
                console.log("✅ AutoMigrate: Added hasBreak to MockExams");
            }
            if (!mockTableDesc.breakScheduleType) {
                await sequelize.query("ALTER TABLE `MockExams` ADD COLUMN `breakScheduleType` ENUM('between_sections', 'every_n_questions') DEFAULT 'between_sections'");
                console.log("✅ AutoMigrate: Added breakScheduleType to MockExams");
            }
            if (!mockTableDesc.breakIntervalQuestions) {
                await sequelize.query("ALTER TABLE `MockExams` ADD COLUMN `breakIntervalQuestions` INT NULL");
                console.log("✅ AutoMigrate: Added breakIntervalQuestions to MockExams");
            }
            if (!mockTableDesc.allowBreakSkip) {
                await sequelize.query("ALTER TABLE `MockExams` ADD COLUMN `allowBreakSkip` TINYINT(1) DEFAULT 1");
                console.log("✅ AutoMigrate: Added allowBreakSkip to MockExams");
            }
        } catch (e) {
            console.warn("⚠️ AutoMigrate MockExams check:", e.message);
        }

    } catch (err) {
        console.warn("⚠️ AutoMigrate general error:", err.message);
    }
}

module.exports = { autoMigrate };
