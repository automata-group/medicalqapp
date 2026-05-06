const { User, Subscription, SubscriptionPlan } = require('../../models');

// @desc    Get all users
// @route   GET /api/v1/admin/users
// @access  Private (Admin)
exports.getUsers = async (req, res, next) => {
    try {
        const { page = 1, limit = 10, role } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = {};
        if (role) whereClause.role = role;

        const { count, rows } = await User.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit),
            offset: parseInt(offset),
            attributes: { exclude: ['password'] },
            include: [{ model: Subscription, as: 'subscriptions', required: false, where: { status: 'active' } }],
            order: [['createdAt', 'DESC']]
        });

        // Map 'isPremium' for the frontend based on active subscriptions
        const data = rows.map(u => {
            const userJson = u.toJSON();
            userJson.isPremium = userJson.subscriptions && userJson.subscriptions.length > 0;
            return userJson;
        });

        res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            data
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single user
// @route   GET /api/v1/admin/users/:id
// @access  Private (Admin)
exports.getUser = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id, {
            attributes: { exclude: ['password'] },
            include: [{ model: Subscription, as: 'subscriptions' }]
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        res.status(200).json({ success: true, data: user });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user (Admin)
// @route   PUT /api/v1/admin/users/:id
// @access  Private (Admin)
exports.updateUser = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id);
        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        const { fullName, role, isVerified } = req.body;

        if (fullName) user.fullName = fullName;
        if (role) user.role = role;
        if (isVerified !== undefined) user.isVerified = isVerified;

        await user.save();

        res.status(200).json({ success: true, data: user });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user status
// @route   PUT /api/v1/admin/users/:id/status
// @access  Private (Admin)
exports.updateUserStatus = async (req, res, next) => {
    try {
        const { isActive } = req.body;
        const user = await User.findByPk(req.params.id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        user.isActive = isActive; // Assuming User model has isActive or similar
        await user.save();

        res.status(200).json({ success: true, message: `User ${isActive ? 'activated' : 'deactivated'}` });
    } catch (error) {
        next(error);
    }
};

// @desc    Manage user subscription (Manual override)
// @route   PUT /api/v1/admin/users/:id/subscription
// @access  Private (Admin)
exports.manageUserSubscription = async (req, res, next) => {
    try {
        const { planId, status, endDate, isPremium } = req.body;
        const user = await User.findByPk(req.params.id);

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        // Handle the simple '{ isPremium: boolean }' UI toggle
        if (isPremium !== undefined) {
            if (isPremium) {
                // Grant PRO (Needs a default plan)
                const defaultPlan = await SubscriptionPlan.findOne({ where: { isActive: true } });
                if (!defaultPlan) return res.status(400).json({ success: false, message: 'No active plans available to assign' });

                await Subscription.create({
                    userId: user.id,
                    planId: defaultPlan.id,
                    status: 'active',
                    startDate: new Date(),
                    endDate: new Date(Date.now() + defaultPlan.durationInDays * 24 * 60 * 60 * 1000)
                });
            } else {
                // Revoke PRO (Cancel all active subscriptions)
                await Subscription.update(
                    { status: 'canceled' },
                    { where: { userId: user.id, status: 'active' } }
                );
            }
            return res.status(200).json({ success: true, message: `Subscription ${isPremium ? 'activated' : 'deactivated'}` });
        }

        // Legacy/Direct way to create or update subscription record
        await Subscription.create({
            userId: user.id,
            planId,
            status: status || 'active',
            startDate: new Date(),
            endDate: endDate ? new Date(endDate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        });

        res.status(200).json({ success: true, message: 'Subscription updated' });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user activity log
// @route   GET /api/v1/admin/users/:id/activity
// @access  Private (Admin)
exports.getUserActivity = async (req, res, next) => {
    try {
        // Mock or real activity if we track user actions (e.g. login history, attempts)
        // Assuming we use QuestionAttempt as "Activity"
        const attempts = await require('../../models').QuestionAttempt.findAll({
            where: { userId: req.params.id },
            limit: 50,
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({ success: true, data: attempts });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user statistics
// @route   GET /api/v1/admin/users/statistics
// @access  Private (Admin)
exports.getUserStatistics = async (req, res, next) => {
    try {
        const totalUsers = await User.count();
        const activeUsers = await User.count({ where: { isVerified: true } }); // or isActive
        const premiumUsers = await Subscription.count({ where: { status: 'active' }, distinct: true, col: 'userId' });

        res.status(200).json({
            success: true,
            data: {
                total: totalUsers,
                active: activeUsers,
                premium: premiumUsers
            }
        });
    } catch (error) {
        next(error);
    }
};
