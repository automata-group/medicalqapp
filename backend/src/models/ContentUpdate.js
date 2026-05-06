const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ContentUpdate = sequelize.define('ContentUpdate', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    version: {
        type: DataTypes.STRING, // e.g., "v1.2.0"
        allowNull: false
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    releaseDate: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    },
    type: {
        type: DataTypes.ENUM('major', 'minor', 'patch', 'content_drop'),
        defaultValue: 'minor'
    }
}, {
    timestamps: true
});

module.exports = ContentUpdate;
