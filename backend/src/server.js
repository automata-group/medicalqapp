// Server entry point - force refresh
const app = require('./app');
const sequelize = require('./config/database');
const models = require('./models'); // Import models to register associations
const dotenv = require('dotenv');

dotenv.config();

// Cleanup expired AI feedback every 24 hours
const { cleanupExpired } = require('./controllers/admin/aiFeedbackController');
setInterval(() => {
    console.log('Running AI Feedback cleanup...');
    cleanupExpired();
}, 24 * 60 * 60 * 1000);

const PORT = process.env.PORT || 5000;

// Test Database Connection and Start Server
const startServer = async () => {
    let authenticated = false;
    let retries = 5;
    
    while (!authenticated && retries > 0) {
        try {
            await sequelize.authenticate();
            authenticated = true;
            console.log('✅ Database connected successfully.');
        } catch (error) {
            retries--;
            console.error(`❌ Database connection failed. Retries left: ${retries}`);
            if (retries === 0) {
                console.error('Final attempt failed. Exiting...');
                process.exit(1);
            }
            await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5 seconds
        }
    }

    try {
        // Sync all models - creates tables if they don't exist
        await sequelize.sync({ alter: false });
        console.log('✅ All models synchronized successfully.');

        // Ensure official subscription plans exist
        try {
            const { seedOfficialPlans } = require('./utils/seedPlans');
            await seedOfficialPlans();
        } catch (seedErr) {
            console.error('Seed plans error:', seedErr.message);
        }

        app.listen(PORT, () => {
            console.log(`🚀 Server running on port ${PORT}`);
            console.log(`👉 http://localhost:${PORT}`);
        });
    } catch (error) {
        console.error('❌ Server failed to start:', error);
        process.exit(1);
    }
};

startServer();
