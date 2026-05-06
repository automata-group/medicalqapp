const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DailyStreak = sequelize.define('DailyStreak', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true,
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    currentStreak: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    longestStreak: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    lastActivityDate: {
        type: DataTypes.DATEONLY,
        allowNull: true
    },
    freezeUsed: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    timestamps: true
});

module.exports = DailyStreak;
