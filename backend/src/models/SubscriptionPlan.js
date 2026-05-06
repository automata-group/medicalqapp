const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const SubscriptionPlan = sequelize.define('SubscriptionPlan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false, // e.g., "Monthly Premium", "Golden Yearly"
        unique: true
    },
    slug: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
        comment: 'URL-friendly identifier'
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    price: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
        defaultValue: 0.00
    },
    currency: {
        type: DataTypes.STRING(3),
        defaultValue: 'SAR',
        allowNull: false
    },
    durationInDays: {
        type: DataTypes.INTEGER,
        allowNull: false,
        comment: '30 for monthly, 365 for yearly'
    },
    features: {
        type: DataTypes.JSON, // Array of feature strings or objects
        allowNull: true,
        defaultValue: []
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    isPopular: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    discountPercentage: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        validate: { min: 0, max: 100 }
    }
}, {
    timestamps: true
});

module.exports = SubscriptionPlan;
