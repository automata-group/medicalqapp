const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ContributionCluster = sequelize.define('ContributionCluster', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    specialtyId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    topicId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false,
        defaultValue: 'Reported Exam Question'
    },
    totalReports: {
        type: DataTypes.INTEGER,
        defaultValue: 1
    },
    status: {
        type: DataTypes.ENUM('open', 'resolved', 'dismissed'),
        defaultValue: 'open'
    },
    createdQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: true
    }
}, {
    timestamps: true
});

module.exports = ContributionCluster;
