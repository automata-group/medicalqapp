const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const DiscountCode = sequelize.define('DiscountCode', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    code: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    type: {
        type: DataTypes.ENUM('percentage', 'fixed_amount'),
        allowNull: false
    },
    value: {
        type: DataTypes.DECIMAL(10, 2), // Should be integer for percentage (0-100) or decimal for amount
        allowNull: false
    },
    maxUses: {
        type: DataTypes.INTEGER,
        allowNull: true // Null means unlimited
    },
    usedCount: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    expiresAt: {
        type: DataTypes.DATE,
        allowNull: true
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, {
    timestamps: true
});

DiscountCode.prototype.isValid = function () {
    const now = new Date();
    if (!this.isActive) return false;
    if (this.expiresAt && this.expiresAt < now) return false;
    if (this.maxUses && this.usedCount >= this.maxUses) return false;
    return true;
};

module.exports = DiscountCode;
