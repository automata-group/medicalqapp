const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const StudySession = sequelize.define('StudySession', {
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
        type: DataTypes.STRING,
        allowNull: true
    },
    subTopic: {
        type: DataTypes.STRING,
        allowNull: true
    },
    filter: {
        type: DataTypes.STRING,
        defaultValue: 'all'
    },
    attemptedIds: {
        type: DataTypes.TEXT,
        allowNull: true,
        comment: 'Comma-separated list of question IDs attempted in this session'
    },
    lastQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    sessionType: {
        type: DataTypes.ENUM('general', 'specialty', 'topic'),
        allowNull: false,
        defaultValue: 'general'
    }
}, {
    timestamps: true,
    indexes: [
        {
            unique: true,
            fields: ['userId', 'specialtyId', 'subTopic', 'sessionType']
        },
        {
            fields: ['userId', 'isActive']
        }
    ]
});

module.exports = StudySession;
