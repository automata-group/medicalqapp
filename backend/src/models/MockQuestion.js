const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MockQuestion = sequelize.define('MockQuestion', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    text: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    specialtyId: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'Specialties',
            key: 'id'
        }
    },
    topicId: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'Topics',
            key: 'id'
        }
    },
    image: {
        type: DataTypes.STRING,
        allowNull: true
    },
    difficulty: {
        type: DataTypes.ENUM('easy', 'medium', 'hard'),
        defaultValue: 'medium'
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
    }
}, {
    timestamps: true
});

module.exports = MockQuestion;
