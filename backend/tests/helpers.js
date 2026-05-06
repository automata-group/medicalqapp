/**
 * Test Helpers
 * Shared utilities for all test files.
 */
const path = require('path');
const dotenv = require('dotenv');
dotenv.config({ path: path.join(__dirname, '..', '.env.test'), override: true });

const supertest = require('supertest');
const jwt = require('jsonwebtoken');
const app = require('../src/app');

const request = supertest(app);

/**
 * Generate a JWT token for a user
 */
function generateToken(userId, role = 'user') {
    return jwt.sign(
        { id: userId, role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
    );
}

/**
 * Get auth header for admin user (ID: 1)
 */
function adminAuth() {
    const token = generateToken(1, 'admin');
    return `Bearer ${token}`;
}

/**
 * Get auth header for test user (ID: 2)
 */
function userAuth() {
    const token = generateToken(2, 'user');
    return `Bearer ${token}`;
}

module.exports = {
    request,
    generateToken,
    adminAuth,
    userAuth
};
