const { User, Subscription, Question, DiscountCode, AdminActivityLog, QuestionReport } = require('../models');
const { Op } = require('sequelize');

// --- Helper Functions ---
const logActivity = async (adminId, action, targetResource, details) => {
    try {
        await AdminActivityLog.create({ adminId, action, targetResource, details });
    } catch (e) {
        console.error('Failed to log admin activity:', e);
    }
};

// ==========================================
// 1. Content Management
// ==========================================

// @desc    Bulk Upload Questions (Placeholder)
// @route   POST /api/v1/admin/questions/bulk
// @access  Private/Admin
exports.bulkUploadQuestions = async (req, res, next) => {
    try {
        // Expected to process req.file (CSV/Excel) and insert into DB
        // For now, this is a stub.
        const file = req.file;
        if (!file) {
            return res.status(400).json({ success: false, message: 'No file uploaded' });
        }

        // Simulating processing...
        const processedCount = 0;

        await logActivity(req.user.id, 'BULK_UPLOAD', 'Question', { count: processedCount, file: file.originalname });

        res.status(200).json({ success: true, message: `Parsed and inserted ${processedCount} questions.` });
    } catch (error) {
        next(error);
    }
};

// @desc    Reorder Questions
// @route   PUT /api/v1/admin/questions/reorder
// @access  Private/Admin
exports.reorderQuestions = async (req, res, next) => {
    try {
        const { orderedIds } = req.body; // e.g., [id1, id2, id3]
        if (!orderedIds || !Array.isArray(orderedIds)) {
            return res.status(400).json({ success: false, message: 'Provide an array of orderedIds' });
        }

        // Simulating reorder... (Actual implementation depends on SectionQuestion join table or sortOrder column)
        await logActivity(req.user.id, 'REORDER_QUESTIONS', 'Question', { count: orderedIds.length });

        res.status(200).json({ success: true, message: 'Questions reordered successfully (stub)' });
    } catch (error) {
        next(error);
    }
};

// ==========================================
// 2. Users & Revenue
// ==========================================

// @desc    Get all users with pagination and stats
// @route   GET /api/v1/admin/users
// @access  Private/Admin
exports.getUsers = async (req, res, next) => {
    try {
        const page = parseInt(req.query.page, 10) || 1;
        const limit = parseInt(req.query.limit, 10) || 20;
        const offset = (page - 1) * limit;

        const users = await User.findAndCountAll({
            attributes: ['id', 'fullName', 'email', 'createdAt', 'role'],
            limit,
            offset,
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            total: users.count,
            page,
            pages: Math.ceil(users.count / limit),
            data: users.rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Manual Override: Grant PRO status
// @route   POST /api/v1/admin/users/:id/override-pro
// @access  Private/Admin
exports.overrideProStatus = async (req, res, next) => {
    try {
        const userId = req.params.id;
        const { durationDays = 30 } = req.body;

        const user = await User.findByPk(userId);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });

        const endDate = new Date();
        endDate.setDate(endDate.getDate() + durationDays);

        await Subscription.create({
            userId: user.id,
            planId: 2, // Assuming planId 2 is a generic PRO plan from seeders
            provider: 'manual_override',
            status: 'active',
            startDate: new Date(),
            endDate: endDate
        });

        await logActivity(req.user.id, 'MANUAL_OVERRIDE_PRO', `User:${user.id}`, { durationDays });

        res.status(200).json({ success: true, message: `Granted ${durationDays} days of PRO access to ${user.email}` });
    } catch (error) {
        next(error);
    }
};

// @desc    Get Revenue Statistics
// @route   GET /api/v1/admin/revenue
// @access  Private/Admin
exports.getRevenueStats = async (req, res, next) => {
    try {
        // Stub: In a real app, query the Payments table grouped by date
        // e.g. SELECT DATE(createdAt), SUM(amount) FROM Payments WHERE status='paid' GROUP BY DATE(createdAt)

        res.status(200).json({
            success: true,
            data: {
                totalRevenue: 25000.00,
                thisMonth: 4500.00,
                today: 1299.00
            },
            message: 'Stub data'
        });
    } catch (error) {
        next(error);
    }
};

// ==========================================
// 3. Promo Codes
// ==========================================

// @desc    Create a Discount/Promo Code
// @route   POST /api/v1/admin/promos
// @access  Private/Admin
exports.createPromoCode = async (req, res, next) => {
    try {
        const { code, type, value, maxUses, expiresAt } = req.body;

        const newPromo = await DiscountCode.create({
            code: code.toUpperCase(),
            type, // 'percentage' or 'fixed_amount'
            value,
            maxUses,
            expiresAt
        });

        await logActivity(req.user.id, 'CREATE_PROMO', `DiscountCode:${newPromo.id}`, { code });

        res.status(201).json({ success: true, data: newPromo });
    } catch (error) {
        next(error);
    }
};

// @desc    Get all active promos
// @route   GET /api/v1/admin/promos
// @access  Private/Admin
exports.getPromos = async (req, res, next) => {
    try {
        const promos = await DiscountCode.findAll({ order: [['createdAt', 'DESC']] });
        res.status(200).json({ success: true, data: promos });
    } catch (error) {
        next(error);
    }
};

// ==========================================
// 4. Moderation & Notifications
// ==========================================

// @desc    Get all question reports
// @route   GET /api/v1/admin/reports
// @access  Private/Admin
exports.getReports = async (req, res, next) => {
    try {
        const reports = await QuestionReport.findAll({
            include: [{ model: User, as: 'user', attributes: ['id', 'email', 'fullName'] }],
            order: [['createdAt', 'DESC']]
        });
        res.status(200).json({ success: true, count: reports.length, data: reports });
    } catch (error) {
        next(error);
    }
};

// @desc    Send Push Notification Broadcast
// @route   POST /api/v1/admin/notifications/broadcast
// @access  Private/Admin
exports.sendBroadcast = async (req, res, next) => {
    try {
        const { title, body, targetGroup = 'all' } = req.body;

        if (!title || !body) {
            return res.status(400).json({ success: false, message: 'Please provide notification title and body' });
        }

        // Stub logic for FCM integration
        // const fcmTokens = await User.findAll({ where: { firebaseToken: { [Op.not]: null } }, attributes: ['firebaseToken'] });
        // firebaseAdmin.messaging().sendMulticast({ tokens, notification: { title, body } })

        await logActivity(req.user.id, 'SEND_BROADCAST', 'Notification', { title, targetGroup });

        res.status(200).json({ success: true, message: `Notification broadcasted to ${targetGroup}` });
    } catch (error) {
        next(error);
    }
};
