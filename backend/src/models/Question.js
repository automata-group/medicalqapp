const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Question = sequelize.define('Question', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    text: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    topicId: {
        type: DataTypes.INTEGER,
        allowNull: true, // Optional for backward compatibility at first
        references: {
            model: 'Topics',
            key: 'id'
        }
    },
    subTopic: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: 'General'
    },
    image: {
        type: DataTypes.STRING,
        allowNull: true
    },
    difficulty: {
        type: DataTypes.ENUM('easy', 'medium', 'hard'),
        defaultValue: 'medium'
    },
    timeEstimate: {
        type: DataTypes.INTEGER, // in seconds
        defaultValue: 60
    },
    isPremium: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    source: {
        type: DataTypes.STRING,
        allowNull: true
    },
    verifiedByAI: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    timestamps: true,
    underscored: false
});

module.exports = Question;
