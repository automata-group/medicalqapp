const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const QuestionAttempt = sequelize.define('QuestionAttempt', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    questionId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    selectedOptionId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    isCorrect: {
        type: DataTypes.BOOLEAN,
        allowNull: false
    },
    confidenceLevel: {
        type: DataTypes.ENUM('low', 'medium', 'high'), // low=Don't Know, medium=Somewhat, high=Know
        allowNull: true
    },
    timeTaken: {
        type: DataTypes.INTEGER, // seconds
        defaultValue: 0
    },
    mode: {
        type: DataTypes.ENUM('practice', 'mock', 'daily'),
        defaultValue: 'practice'
    }
}, {
    timestamps: true
});

module.exports = QuestionAttempt;
