const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AppSetting = sequelize.define('AppSetting', {
    key: {
        type: DataTypes.STRING(100),
        primaryKey: true,
        allowNull: false
    },
    value: {
        type: DataTypes.JSON,
        allowNull: false
    },
    description: {
        type: DataTypes.STRING(255),
        allowNull: true
    }
}, {
    tableName: 'AppSettings',
    timestamps: true
});

module.exports = AppSetting;
