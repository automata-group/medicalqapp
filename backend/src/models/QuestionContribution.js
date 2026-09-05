const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const QuestionContribution = sequelize.define('QuestionContribution', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    specialtyId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    topicId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    clusterId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    questionText: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    options: {
        type: DataTypes.JSON,
        allowNull: true,
        defaultValue: []
    },
    userAnswer: {
        type: DataTypes.STRING(20), // 'A', 'B', 'C', 'D', 'unsure'
        allowNull: true
    },
    notes: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    examDate: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    confidenceLevel: {
        type: DataTypes.ENUM('high', 'medium', 'low'),
        allowNull: false,
        defaultValue: 'high'
    },
    imageUrl: {
        type: DataTypes.STRING,
        allowNull: true
    },
    status: {
        type: DataTypes.ENUM('pending', 'reviewing', 'needs_info', 'approved', 'rejected', 'duplicate'),
        defaultValue: 'pending'
    },
    priority: {
        type: DataTypes.ENUM('normal', 'high', 'urgent'),
        defaultValue: 'normal'
    },
    adminNotes: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    reviewedBy: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    convertedQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: true
    }
}, {
    timestamps: true
});

module.exports = QuestionContribution;
