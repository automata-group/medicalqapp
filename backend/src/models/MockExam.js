const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MockExam = sequelize.define('MockExam', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    totalQuestions: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    duration: {
        type: DataTypes.INTEGER, // in minutes
        defaultValue: 60
    },
    breakDuration: {
        type: DataTypes.INTEGER, // in minutes
        defaultValue: 30
    },
    hasBreak: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    breakScheduleType: {
        type: DataTypes.ENUM('between_sections', 'every_n_questions'),
        defaultValue: 'between_sections'
    },
    breakIntervalQuestions: {
        type: DataTypes.INTEGER,
        allowNull: true // e.g. 50 or 105 questions
    },
    allowBreakSkip: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    price: {
        type: DataTypes.DECIMAL(10, 2),
        defaultValue: 0.00
    },
    isPremium: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    specialtyId: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'Specialties',
            key: 'id'
        }
    },
    achievementId: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'Achievements',
            key: 'id'
        }
    }
}, {
    timestamps: true
});

module.exports = MockExam;
