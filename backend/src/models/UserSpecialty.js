const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserSpecialty = sequelize.define('UserSpecialty', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    // Foreign keys will be added by association in index.js
}, {
    timestamps: true
});

module.exports = UserSpecialty;
