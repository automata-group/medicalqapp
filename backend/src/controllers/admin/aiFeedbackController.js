const { AIFeedback, User } = require('../../models');
const { Op } = require('sequelize');

// @desc    Get all active feedback (Admin)
exports.getAllFeedbacks = async (req, res, next) => {
    try {
        const feedbacks = await AIFeedback.findAll({
            include: [{ model: User, as: 'user', attributes: ['id', 'fullName', 'email'] }],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count: feedbacks.length,
            data: feedbacks
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete feedback (Admin)
exports.deleteFeedback = async (req, res, next) => {
    try {
        const feedback = await AIFeedback.findByPk(req.params.id);
        if (!feedback) return res.status(404).json({ success: false, message: 'Not found' });

        await feedback.destroy();

        res.status(200).json({
            success: true,
            message: 'Feedback deleted successfully'
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Cleanup Expired Feedback (Manual trigger or can be used by cron)
exports.cleanupExpired = async (req, res, next) => {
    try {
        const count = await AIFeedback.destroy({
            where: {
                expiresAt: { [Op.lt]: new Date() }
            }
        });

        res.status(200).json({
            success: true,
            message: `Deleted ${count} expired feedbacks`
        });
    } catch (error) {
        if (next) next(error);
        else console.error('Cleanup Error:', error);
    }
};
