const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

// Load env from parent directory since we are in src/utils
dotenv.config({ path: path.join(__dirname, '../../.env') });

async function reset() {
    try {
        console.log('Connecting to MySQL server...');
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || '127.0.0.1',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASS || ''
        });

        const dbName = process.env.DB_NAME || 'medical_qbank';

        console.log(`🔄 Dropping database ${dbName}...`);
        await connection.query(`DROP DATABASE IF EXISTS \`${dbName}\``);

        console.log(`🔄 Creating database ${dbName}...`);
        await connection.query(`CREATE DATABASE \`${dbName}\``);

        console.log('✅ Database reset successfully.');
        await connection.end();
        process.exit(0);
    } catch (err) {
        console.error('❌ Error:', err);
        process.exit(1);
    }
}

reset();
