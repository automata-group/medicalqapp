const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Explanation = sequelize.define('Explanation', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    text: {
        type: DataTypes.TEXT, // General explanation for correct answer
        allowNull: false
    },
    whyWrong: {
        type: DataTypes.JSON, // Object explaining why other options are wrong: { "A": "...", "B": "..." }
        allowNull: true
    },
    references: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    aiGenerated: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    timestamps: true
});

module.exports = Explanation;
