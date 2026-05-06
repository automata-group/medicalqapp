module.exports = {
    testEnvironment: 'node',
    testTimeout: 30000,
    testMatch: ['**/tests/**/*.test.js'],
    globalSetup: './tests/globalSetup.js',
    globalTeardown: './tests/globalTeardown.js',
    setupFiles: ['./tests/setup.js'],
    verbose: true
};
