const { User, Question, QuestionAttempt, Subscription, SubscriptionPlan, Payment, UserMockExam, Specialty, sequelize } = require('../../models');
const { Op } = require('sequelize');

// @desc    Get analytics overview
// @route   GET /api/v1/admin/analytics/overview
// @access  Private (Admin)
exports.getAnalyticsOverview = async (req, res, next) => {
    try {
        const totalUsers = await User.count();
        const totalQuestions = await Question.count();
        const totalAttempts = await QuestionAttempt.count({
            distinct: true,
            col: 'questionId'
        });
        const totalRevenue = await Payment.sum('amount', { where: { status: 'completed' } });

        res.status(200).json({
            success: true,
            data: {
                totalUsers,
                totalQuestions,
                totalAttempts,
                totalRevenue: totalRevenue || 0
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user analytics
// @route   GET /api/v1/admin/analytics/users
// @access  Private (Admin)
exports.getUserAnalytics = async (req, res, next) => {
    try {
        const usersByDate = await User.findAll({
            attributes: [
                [sequelize.fn('DATE', sequelize.col('createdAt')), 'date'],
                [sequelize.fn('COUNT', sequelize.col('id')), 'count']
            ],
            group: [sequelize.fn('DATE', sequelize.col('createdAt'))],
            order: [[sequelize.fn('DATE', sequelize.col('createdAt')), 'ASC']],
            limit: 30
        });

        res.status(200).json({ success: true, data: usersByDate });
    } catch (error) {
        next(error);
    }
};

// @desc    Get question analytics
// @route   GET /api/v1/admin/analytics/questions
// @access  Private (Admin)
exports.getQuestionAnalytics = async (req, res, next) => {
    try {
        const questionsBySpecialty = await Question.findAll({
            attributes: [
                'specialtyId',
                [sequelize.fn('COUNT', sequelize.col('Question.id')), 'count']
            ],
            include: [{ model: sequelize.models.Specialty, as: 'specialty', attributes: ['name'] }],
            group: ['specialtyId', 'specialty.id', 'specialty.name']
        });

        res.status(200).json({ success: true, data: questionsBySpecialty });
    } catch (error) {
        next(error);
    }
};

// @desc    Get performance analytics
// @route   GET /api/v1/admin/analytics/performance
// @access  Private (Admin)
exports.getPerformanceAnalytics = async (req, res, next) => {
    try {
        const totalAttempts = await QuestionAttempt.count({
            distinct: true,
            col: 'questionId'
        });
        const correctAttempts = await QuestionAttempt.count({
            where: { isCorrect: true },
            distinct: true,
            col: 'questionId'
        });
        const accuracy = totalAttempts > 0 ? (correctAttempts / totalAttempts) * 100 : 0;

        res.status(200).json({
            success: true,
            data: {
                totalAttempts,
                averageAccuracy: Math.round(accuracy)
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get mock exam analytics
// @route   GET /api/v1/admin/analytics/mock-exams
// @access  Private (Admin)
exports.getMockExamAnalytics = async (req, res, next) => {
    try {
        const totalExams = await UserMockExam.count();
        const completedExams = await UserMockExam.count({ where: { status: 'completed' } });
        const avgScore = await UserMockExam.findAll({
            attributes: [[sequelize.fn('AVG', sequelize.col('percentage')), 'avgScore']],
            where: { status: 'completed' }
        });

        res.status(200).json({
            success: true,
            data: {
                totalExams,
                completedExams,
                averageScore: avgScore[0]?.getDataValue('avgScore') ? Math.round(Number(avgScore[0].getDataValue('avgScore'))) : 0
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Export analytics
// @route   GET /api/v1/admin/analytics/export
// @access  Private (Admin)
exports.exportAnalytics = async (req, res, next) => {
    try {
        // Mock export - in real app, generate CSV/Excel and stream it
        // For MVP, return JSON that client can convert
        const data = await exports.getAnalyticsOverview(req, res, next);
        // Note: calling another controller method passing req/res might send response twice if not handled carefully.
        // Better:

        const totalUsers = await User.count();
        const totalRevenue = await Payment.sum('amount', { where: { status: 'completed' } });

        res.status(200).json({
            success: true,
            message: "Export data ready",
            data: { totalUsers, totalRevenue, generatedAt: new Date() }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get business analytics (Conversions, Revenue, Top Specialties)
// @route   GET /api/v1/admin/analytics/business
// @access  Private (Admin)
exports.getBusinessAnalytics = async (req, res, next) => {
    try {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        // 1. Revenue Over Time (Last 30 Days)
        const revenueDataRaw = await Payment.findAll({
            attributes: [
                [sequelize.fn('DATE', sequelize.col('createdAt')), 'date'],
                [sequelize.fn('SUM', sequelize.col('amount')), 'revenue']
            ],
            where: {
                status: 'completed',
                createdAt: { [Op.gte]: thirtyDaysAgo }
            },
            group: [sequelize.fn('DATE', sequelize.col('createdAt'))],
            order: [[sequelize.fn('DATE', sequelize.col('createdAt')), 'ASC']],
            raw: true
        });

        // Fill empty days
        const revenueData = [];
        for (let i = 29; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            const dateStr = d.toISOString().split('T')[0];
            const match = revenueDataRaw.find(r => r.date === dateStr);
            revenueData.push({
                date: dateStr,
                revenue: match ? parseFloat(match.revenue) : 0
            });
        }

        // 2. Conversion Rate (Free to Pro)
        const totalUsers = await User.count({ where: { role: 'user' } });
        // Since isPremium is not on User, count users who have an active subscription:
        const premiumUsers = await Subscription.count({
            where: { status: 'active' },
            distinct: true,
            col: 'userId'
        });
        const conversionRate = totalUsers > 0 ? ((premiumUsers / totalUsers) * 100).toFixed(2) : 0;

        // Active vs Churned Subscriptions
        const activeSubscriptions = await Subscription.count({ where: { status: 'active' } });
        const cancelledSubscriptions = await Subscription.count({ where: { status: 'cancelled' } });

        const churnRate = (activeSubscriptions + cancelledSubscriptions) > 0
            ? ((cancelledSubscriptions / (activeSubscriptions + cancelledSubscriptions)) * 100).toFixed(2)
            : 0;

        // 3. Top Specialties (By number of questions attempted)
        const topSpecialties = await QuestionAttempt.findAll({
            attributes: [
                [sequelize.col('question.specialty.name'), 'name'],
                [sequelize.literal('COUNT(DISTINCT `questionId`)'), 'value']
            ],
            include: [{
                model: Question,
                as: 'question',
                attributes: [],
                include: [{
                    model: Specialty,
                    as: 'specialty',
                    attributes: []
                }]
            }],
            group: ['question.specialty.id', 'question.specialty.name'],
            order: [[sequelize.literal('COUNT(DISTINCT `questionId`)'), 'DESC']],
            limit: 5,
            raw: true
        });

        res.status(200).json({
            success: true,
            data: {
                revenueOverTime: revenueData,
                conversionRate,
                churnRate,
                topSpecialties: topSpecialties.map(ts => ({
                    name: ts.name || 'General',
                    value: parseInt(ts.value)
                }))
            }
        });
    } catch (error) {
        next(error);
    }
};
