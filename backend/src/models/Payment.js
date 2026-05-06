const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Payment = sequelize.define('Payment', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    currency: {
        type: DataTypes.STRING(3),
        defaultValue: 'SAR'
    },
    status: {
        type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'),
        defaultValue: 'pending'
    },
    provider: {
        type: DataTypes.STRING, // 'moyasar', 'stripe', etc.
        allowNull: false
    },
    transactionId: {
        type: DataTypes.STRING, // External transaction ID
        allowNull: true,
        unique: true
    },
    paymentMethod: {
        type: DataTypes.STRING, // 'credit_card', 'apple_pay', 'stc_pay'
        allowNull: true
    },
    description: {
        type: DataTypes.STRING,
        allowNull: true
    },
    metadata: {
        type: DataTypes.JSON,
        allowNull: true
    }
}, {
    timestamps: true,
    indexes: [
        {
            fields: ['userId']
        },
        {
            fields: ['transactionId']
        }
    ]
});

module.exports = Payment;
