const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const AdminActivityLog = sequelize.define('AdminActivityLog', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    adminId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    action: {
        type: DataTypes.STRING,
        allowNull: false, // e.g., 'CREATE_QUESTION', 'DELETE_USER'
    },
    targetResource: {
        type: DataTypes.STRING,
        allowNull: true // e.g., 'Question:123'
    },
    details: {
        type: DataTypes.JSON, // Detailed change log or original values
        allowNull: true
    },
    ipAddress: {
        type: DataTypes.STRING,
        allowNull: true
    },
    userAgent: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    timestamps: true,
    updatedAt: false, // Activity logs are immutable history
    indexes: [
        {
            fields: ['adminId']
        },
        {
            fields: ['action']
        },
        {
            fields: ['createdAt'] // For querying logs by date range
        }
    ]
});

module.exports = AdminActivityLog;
