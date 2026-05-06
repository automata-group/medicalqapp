const { Achievement, UserAchievement, DailyStreak } = require('../models');

// @desc    Get all achievements
// @route   GET /api/v1/achievements
// @access  Private
exports.getAchievements = async (req, res, next) => {
    try {
        const achievements = await Achievement.findAll();
        const userAchievements = await UserAchievement.findAll({ where: { userId: req.user.id } });

        const userAwardedIds = new Set(userAchievements.map(ua => ua.achievementId));

        const result = achievements.map(ach => ({
            ...ach.toJSON(),
            isUnlocked: userAwardedIds.has(ach.id),
            unlockedAt: userAchievements.find(ua => ua.achievementId === ach.id)?.earnedAt || null
        }));

        res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get streak status
// @route   GET /api/v1/user/streaks
// @access  Private
exports.getStreaks = async (req, res, next) => {
    try {
        let streak = await DailyStreak.findOne({ where: { userId: req.user.id } });
        if (!streak) {
            streak = { currentStreak: 0, longestStreak: 0, lastActivityDate: null };
        }
        res.status(200).json({ success: true, data: streak });
    } catch (error) {
        next(error);
    }
};

// @desc    Get achievement details
// @route   GET /api/v1/achievements/:id
// @access  Private
exports.getAchievementDetails = async (req, res, next) => {
    try {
        const achievement = await Achievement.findByPk(req.params.id);
        if (!achievement) {
            return res.status(404).json({ success: false, message: 'Achievement not found' });
        }
        res.status(200).json({ success: true, data: achievement });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user's earned achievements
// @route   GET /api/v1/user/achievements
// @access  Private
exports.getUserAchievements = async (req, res, next) => {
    try {
        const userAchievements = await UserAchievement.findAll({
            where: { userId: req.user.id },
            include: [{ model: Achievement }]
        });

        res.status(200).json({
            success: true,
            count: userAchievements.length,
            data: userAchievements
        });
    } catch (error) {
        next(error);
    }
};
