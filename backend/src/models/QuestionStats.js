const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const QuestionStats = sequelize.define('QuestionStats', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    questionId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true
    },
    totalAttempts: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    correctAttempts: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    totalTimeSeconds: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: true
});

module.exports = QuestionStats;
