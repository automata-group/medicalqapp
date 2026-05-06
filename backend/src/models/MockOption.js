const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MockOption = sequelize.define('MockOption', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    mockQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'MockQuestions',
            key: 'id'
        }
    },
    text: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    isCorrect: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    order: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: true
});

module.exports = MockOption;
