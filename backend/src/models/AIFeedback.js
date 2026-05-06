const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AIFeedback = sequelize.define('AIFeedback', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    content: {
        type: DataTypes.TEXT,
        allowNull: false // The AI response (Markdown/JSON)
    },
    analysisType: {
        type: DataTypes.ENUM('mistake_analysis', 'study_plan', 'performance_summary'),
        defaultValue: 'mistake_analysis'
    },
    isRead: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    expiresAt: {
        type: DataTypes.DATE,
        allowNull: false
    }
}, {
    timestamps: true
});

module.exports = AIFeedback;
