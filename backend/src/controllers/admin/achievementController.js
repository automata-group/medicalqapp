const { Achievement } = require('../../models');

// @desc    Get all achievements
// @route   GET /api/v1/admin/achievements
// @access  Private/Admin
exports.getAchievements = async (req, res, next) => {
    try {
        const achievements = await Achievement.findAll();
        res.status(200).json({ success: true, data: achievements });
    } catch (error) {
        next(error);
    }
};

// @desc    Create achievement
// @route   POST /api/v1/admin/achievements
// @access  Private/Admin
exports.createAchievement = async (req, res, next) => {
    try {
        const achievement = await Achievement.create(req.body);
        res.status(201).json({ success: true, data: achievement });
    } catch (error) {
        next(error);
    }
};

// @desc    Update achievement
// @route   PUT /api/v1/admin/achievements/:id
// @access  Private/Admin
exports.updateAchievement = async (req, res, next) => {
    try {
        let achievement = await Achievement.findByPk(req.params.id);
        if (!achievement) return res.status(404).json({ success: false, message: 'Not found' });

        achievement = await achievement.update(req.body);
        res.status(200).json({ success: true, data: achievement });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete achievement
// @route   DELETE /api/v1/admin/achievements/:id
// @access  Private/Admin
exports.deleteAchievement = async (req, res, next) => {
    try {
        const achievement = await Achievement.findByPk(req.params.id);
        if (!achievement) return res.status(404).json({ success: false, message: 'Not found' });

        await achievement.destroy();
        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        next(error);
    }
};
