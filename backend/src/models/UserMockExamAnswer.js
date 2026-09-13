const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserMockExamAnswer = sequelize.define('UserMockExamAnswer', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userMockExamId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    mockQuestionId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    selectedOptionId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    isCorrect: {
        type: DataTypes.BOOLEAN,
        allowNull: false
    },
    timeSpentSeconds: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
}, {
    timestamps: true,
    indexes: [
        {
            unique: true,
            fields: ['userMockExamId', 'mockQuestionId']
        }
    ]
});

module.exports = UserMockExamAnswer;
