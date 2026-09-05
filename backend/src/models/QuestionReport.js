const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const QuestionReport = sequelize.define('QuestionReport', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    reason: {
        type: DataTypes.ENUM('wrong_answer', 'typo', 'confusing', 'scientific_error', 'other'),
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    status: {
        type: DataTypes.ENUM('pending', 'reviewing', 'resolved', 'dismissed'),
        defaultValue: 'pending'
    },
    adminNotes: {
        type: DataTypes.TEXT,
        allowNull: true
    }
}, {
    timestamps: true
});

module.exports = QuestionReport;
