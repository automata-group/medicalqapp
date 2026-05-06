const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserMockExam = sequelize.define('UserMockExam', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    mockExamId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'MockExams',
            key: 'id'
        }
    },
    startTime: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW
    },
    endTime: {
        type: DataTypes.DATE,
        allowNull: true
    },
    score: {
        type: DataTypes.INTEGER, // Raw score (number of correct answers)
        defaultValue: 0
    },
    percentage: {
        type: DataTypes.FLOAT, // Calculated percentage
        defaultValue: 0.0
    },
    totalQuestions: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    correctAnswers: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    wrongAnswers: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    skippedAnswers: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    timeSpentSeconds: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    status: {
        type: DataTypes.ENUM('in-progress', 'completed', 'abandoned', 'paused'),
        defaultValue: 'in-progress'
    },
    lastActiveSectionId: {
        type: DataTypes.INTEGER,
        allowNull: true // To resume from last section
    }
}, {
    timestamps: true,
    indexes: [
        {
            fields: ['userId']
        },
        {
            fields: ['mockExamId']
        }
    ]
});

module.exports = UserMockExam;
