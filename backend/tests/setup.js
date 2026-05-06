/**
 * Jest Setup File
 * Runs before each test file.
 * Loads test env and reconnects to test DB.
 */
const path = require('path');
const dotenv = require('dotenv');

// Load test environment
dotenv.config({ path: path.join(__dirname, '..', '.env.test'), override: true });
