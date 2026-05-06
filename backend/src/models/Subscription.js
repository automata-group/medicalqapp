const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Subscription = sequelize.define('Subscription', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
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
    planId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'SubscriptionPlans',
            key: 'id'
        }
    },
    status: {
        type: DataTypes.ENUM('active', 'canceled', 'expired', 'past_due'),
        defaultValue: 'active'
    },
    startDate: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    endDate: {
        type: DataTypes.DATE,
        allowNull: false
    },
    paymentId: {
        type: DataTypes.STRING,
        allowNull: true
    },
    autoRenew: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, {
    timestamps: true,
    tableName: 'subscriptions'
});

// Instance method to check expiry
Subscription.prototype.isExpired = function () {
    return new Date() > this.endDate;
};

// Instance method to check if subscription is currently valid
Subscription.prototype.isValid = function () {
    return this.status === 'active' && !this.isExpired();
};

module.exports = Subscription;
