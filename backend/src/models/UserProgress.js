const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserProgress = sequelize.define('UserProgress', {
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
    interval: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        comment: 'Interval in days for the next review'
    },
    repetition: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        comment: 'Number of consecutive successful reviews'
    },
    easeFactor: {
        type: DataTypes.FLOAT,
        defaultValue: 2.5,
        comment: 'Easiness factor for SM-2 algorithm'
    },
    nextReviewDate: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW
    }
}, {
    timestamps: true,
    indexes: [
        {
            unique: true,
            fields: ['userId', 'questionId']
        },
        {
            fields: ['userId', 'nextReviewDate']
        }
    ]
});

module.exports = UserProgress;
