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
        allowNull: false,
        references: {
            model: 'MockExamSections',
            key: 'id'
        }
    },
    mockQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'MockQuestions',
            key: 'id'
        }
    },
    sortOrder: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: false
});

module.exports = SectionQuestion;
