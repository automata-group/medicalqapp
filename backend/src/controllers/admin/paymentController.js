const { Payment, User, SubscriptionPlan, sequelize } = require('../../models');
const { Op } = require('sequelize');

// @desc    Get all payments
// @route   GET /api/v1/admin/payments
// @access  Private (Admin)
exports.getPayments = async (req, res, next) => {
    try {
        const { page = 1, limit = 10, status, startDate, endDate } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = {};
        if (status) whereClause.status = status;
        if (startDate && endDate) {
            whereClause.createdAt = { [Op.between]: [startDate, endDate] };
        }

        const payments = await Payment.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit),
            offset: parseInt(offset),
            order: [['createdAt', 'DESC']],
            include: [
                { model: User, as: 'user', attributes: ['id', 'fullName', 'email'] }
            ]
        });

        res.status(200).json({
            success: true,
            count: payments.count,
            totalPages: Math.ceil(payments.count / limit),
            currentPage: parseInt(page),
            data: payments.rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get payment details
// @route   GET /api/v1/admin/payments/:id
// @access  Private (Admin)
exports.getPayment = async (req, res, next) => {
    try {
        const payment = await Payment.findByPk(req.params.id, {
            include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'email'] }]
        });

        if (!payment) {
            return res.status(404).json({ success: false, message: 'Payment not found' });
        }

        res.status(200).json({ success: true, data: payment });
    } catch (error) {
        next(error);
    }
};

// @desc    Get payment statistics
// @route   GET /api/v1/admin/payments/statistics
// @access  Private (Admin)
exports.getPaymentStatistics = async (req, res, next) => {
    try {
        const totalRevenue = await Payment.sum('amount', { where: { status: 'completed' } });
        const countByStatus = await Payment.findAll({
            attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
            group: ['status']
        });

        res.status(200).json({
            success: true,
            data: {
                totalRevenue: totalRevenue || 0,
                breakdown: countByStatus
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get daily revenue
// @route   GET /api/v1/admin/revenue/daily
// @access  Private (Admin)
exports.getDailyRevenue = async (req, res, next) => {
    try {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30); // Last 30 days

        const revenue = await Payment.findAll({
            attributes: [
                [sequelize.fn('DATE', sequelize.col('createdAt')), 'date'],
                [sequelize.fn('SUM', sequelize.col('amount')), 'dailyTotal']
            ],
            where: {
                status: 'completed',
                createdAt: { [Op.between]: [startDate, endDate] }
            },
            group: [sequelize.fn('DATE', sequelize.col('createdAt'))],
            order: [[sequelize.fn('DATE', sequelize.col('createdAt')), 'ASC']]
        });

        res.status(200).json({ success: true, data: revenue });
    } catch (error) {
        next(error);
    }
};

// @desc    Get monthly revenue
// @route   GET /api/v1/admin/revenue/monthly
// @access  Private (Admin)
exports.getMonthlyRevenue = async (req, res, next) => {
    try {
        const revenue = await Payment.findAll({
            attributes: [
                [sequelize.fn('YEAR', sequelize.col('createdAt')), 'year'],
                [sequelize.fn('MONTH', sequelize.col('createdAt')), 'month'],
                [sequelize.fn('SUM', sequelize.col('amount')), 'monthlyTotal']
            ],
            where: { status: 'completed' },
            group: [
                sequelize.fn('YEAR', sequelize.col('createdAt')),
                sequelize.fn('MONTH', sequelize.col('createdAt'))
            ],
            order: [
                [sequelize.fn('YEAR', sequelize.col('createdAt')), 'DESC'],
                [sequelize.fn('MONTH', sequelize.col('createdAt')), 'DESC']
            ]
        });

        res.status(200).json({ success: true, data: revenue });
    } catch (error) {
        next(error);
    }
};
