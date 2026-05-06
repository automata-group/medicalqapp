/**
 * Jest Global Teardown
 * Runs once after all test suites complete.
 */
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.join(__dirname, '..', '.env.test') });

module.exports = async () => {
    const sequelize = require('../src/config/database');
    try {
        await sequelize.authenticate();
        const dbName = sequelize.config.database;
        await sequelize.query(`DROP DATABASE IF EXISTS \`${dbName}\``);
        console.log('\n✅ Test database dropped');
        await sequelize.close();
    } catch (error) {
        console.error('Warning: Could not drop test database:', error.message);
    }
};
