const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MockExamSection = sequelize.define('MockExamSection', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    mockExamId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    timeLimit: { // in minutes
        type: DataTypes.INTEGER,
        defaultValue: 120
    },
    questionCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    sortOrder: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: true
});

module.exports = MockExamSection;
