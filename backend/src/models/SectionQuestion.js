const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SectionQuestion = sequelize.define('SectionQuestion', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    sectionId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    mockQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    sortOrder: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: false
});

module.exports = SectionQuestion;
