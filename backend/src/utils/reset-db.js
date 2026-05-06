const sequelize = require('../config/database');
const models = require('../models');

const reset = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Connected to database.');

        console.log('🔄 Disabling Foreign Key Checks...');
        await sequelize.query('SET FOREIGN_KEY_CHECKS = 0', { raw: true });

        console.log('🔄 Resetting database (dropping and recreating tables)...');
        await sequelize.sync({ force: true });
        console.log('✅ Database reset successfully.');

        process.exit(0);
    } catch (error) {
        console.error('❌ Error resetting database:', error);
        process.exit(1);
    }
};

reset();
