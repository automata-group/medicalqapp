const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const dotenv = require('dotenv');

const path = require('path');

// Load environment variables
dotenv.config();

// Create Express app
const app = express();

// Middleware
app.use(helmet({
    crossOriginResourcePolicy: false, // Allow images to be loaded cross-origin
}));
app.use(cors({
    origin: process.env.CORS_ORIGIN || '*'
}));
app.use(morgan('dev')); // Logging
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(compression({
    filter: (req, res) => {
        if (req.headers['accept'] === 'text/event-stream' || res.getHeader('Content-Type') === 'text/event-stream') {
            return false; // Skip compression for SSE to avoid buffering
        }
        return compression.filter(req, res);
    }
})); // Compress other responses

// Serve static files from uploads directory
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes
app.use('/api/v1/auth', require('./routes/authRoutes'));
app.use('/api/v1', require('./routes/specialtyRoutes'));
app.use('/api/v1/dashboard', require('./routes/dashboardRoutes'));
app.use('/api/v1/subscription', require('./routes/subscriptionRoutes'));
app.use('/api/v1/questions', require('./routes/questionRoutes'));
app.use('/api/v1/mock-exams', require('./routes/mockExamRoutes'));
app.use('/api/v1/progress', require('./routes/progressRoutes'));
app.use('/api/v1/gamification', require('./routes/gamificationRoutes'));
app.use('/api/v1/bookmarks', require('./routes/bookmarkRoutes'));
app.use('/api/v1/search', require('./routes/searchRoutes'));
app.use('/api/v1/offline', require('./routes/offlineRoutes'));
app.use('/api/v1/notifications', require('./routes/notificationRoutes'));
app.use('/api/v1/subscriptions', require('./routes/subscriptionRoutes'));
app.use('/api/v1/user', require('./routes/settingsRoutes')); // Mounted at /user because routes are /profile, /change-password, etc.
app.use('/api/v1/referrals', require('./routes/referralRoutes'));
app.use('/api/v1/ai-feedback', require('./routes/aiFeedbackRoutes'));
app.use('/api/v1/sessions', require('./routes/sessionRoutes'));

// Admin Routes
app.use('/api/v1/admin/auth', require('./routes/admin/authRoutes'));
app.use('/api/v1/admin/users', require('./routes/admin/userRoutes'));
app.use('/api/v1/admin/questions', require('./routes/admin/questionRoutes'));
app.use('/api/v1/admin/reports', require('./routes/admin/reportRoutes'));
app.use('/api/v1/admin/content-updates', require('./routes/admin/contentUpdateRoutes'));
app.use('/api/v1/admin/notifications', require('./routes/admin/notificationRoutes')); // Note: Check conflict with user notifications path? User is /api/v1/notifications, Admin is /api/v1/admin/notifications. Safe.
app.use('/api/v1/admin/analytics', require('./routes/admin/analyticsRoutes'));
app.use('/api/v1/admin/subscription-plans', require('./routes/admin/subscriptionPlanRoutes'));
app.use('/api/v1/admin/discount-codes', require('./routes/admin/discountCodeRoutes'));
app.use('/api/v1/admin/ai', require('./routes/admin/aiRoutes'));
app.use('/api/v1/admin/config', require('./routes/admin/settingsRoutes'));
app.use('/api/v1/admin/specialties', require('./routes/admin/specialtyRoutes'));
app.use('/api/v1/admin/topics', require('./routes/admin/topicRoutes'));
app.use('/api/v1/admin/admins', require('./routes/admin/adminRoutes'));
app.use('/api/v1/admin/payments', require('./routes/admin/paymentRoutes'));
app.use('/api/v1/admin/mock-exams', require('./routes/admin/mockExamRoutes'));
app.use('/api/v1/admin/achievements', require('./routes/admin/achievementRoutes'));


// Basic Route for testing
app.get('/', (req, res) => {
    res.json({
        message: 'Medical Question Bank API is running',
        version: '0.0.3',
        databaseStatus: 'connected'
    });
});

// Swagger Documentation
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

// 404 Handler
app.use((req, res, next) => {
    res.status(404).json({
        success: false,
        message: 'Resource not found'
    });
});

// Global Error Handler
// Global Error Handler
app.use((err, req, res, next) => {
    // Handle Sequelize Validation Errors
    if (err.name === 'SequelizeValidationError' || err.name === 'SequelizeUniqueConstraintError') {
        const message = err.errors.map(e => e.message).join(', ');
        return res.status(400).json({
            success: false,
            message
        });
    }

    console.error(err.stack);

    res.status(err.status || 500).json({
        success: false,
        message: err.message || 'Internal Server Error'
    });
});

module.exports = app;
