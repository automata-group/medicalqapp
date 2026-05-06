const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Achievement = sequelize.define('Achievement', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    slug: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        comment: 'Identifier for code logic e.g., "first_100_questions"'
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    icon: {
        type: DataTypes.STRING,
        allowNull: true
    },
    criteriaType: {
        type: DataTypes.ENUM('questions_solved', 'streak_days', 'mock_score', 'specialty_mastery'),
        allowNull: false
    },
    criteriaValue: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: 'Threshold to unlock (e.g., 100 questions)'
    },
    xpReward: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: true
});

module.exports = Achievement;
