const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Referral = sequelize.define('Referral', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    status: {
        type: DataTypes.ENUM('pending', 'completed', 'expired'),
        defaultValue: 'pending'
    },
    rewardType: {
        type: DataTypes.ENUM('days_access', 'discount'),
        defaultValue: 'days_access'
    },
    rewardValue: {
        type: DataTypes.INTEGER,
        defaultValue: 7, // e.g. 7 days free
        comment: 'Value of the reward (days or percentage)'
    }
}, {
    timestamps: true
});

module.exports = Referral;
