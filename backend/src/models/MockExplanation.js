const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MockExplanation = sequelize.define('MockExplanation', {
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
    references: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    image: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    timestamps: true
});

module.exports = MockExplanation;
