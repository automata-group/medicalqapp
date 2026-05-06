const { User } = require('./src/models');
const sequelize = require('./src/config/database');

const createAdmin = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ Connected to database');

        const email = 'admin@healthlicenseprep.com';
        const password = 'Admin#2026!Health';
        const fullName = 'Main Admin';

        // Check if user exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
            console.log('⚠️ User already exists. Updating to Admin...');
            existingUser.role = 'admin';
            existingUser.password = password; // Hook will hash it
            await existingUser.save();
            console.log('✅ User updated to Admin successfully');
        } else {
            await User.create({
                fullName,
                email,
                password,
                role: 'admin',
                isVerified: true
            });
            console.log('✅ Admin user created successfully');
        }

        process.exit(0);
    } catch (error) {
        console.error('❌ Error:', error);
        process.exit(1);
    }
};

createAdmin();
