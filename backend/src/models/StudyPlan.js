const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const StudyPlan = sequelize.define('StudyPlan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true, // One plan per user
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    examDate: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    targetScore: {
        type: DataTypes.INTEGER,
        defaultValue: 80,
        validate: { min: 0, max: 100 }
    },
    dailyHours: {
        type: DataTypes.FLOAT,
        defaultValue: 2.0,
        validate: { min: 0.5, max: 12.0 }
    },
    studyDays: {
        type: DataTypes.JSON, // Array of days e.g., ['Mon', 'Tue', ...]
        defaultValue: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    },
    notificationEnabled: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    notificationTime: {
        type: DataTypes.TIME,
        defaultValue: '09:00:00'
    }
}, {
    timestamps: true
});

module.exports = StudyPlan;
