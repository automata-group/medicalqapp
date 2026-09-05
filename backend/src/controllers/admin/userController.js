const { 
    User, 
    Subscription, 
    SubscriptionPlan, 
    UserMockExam, 
    UserMockExamAnswer, 
    QuestionAttempt, 
    UserProgress, 
    Bookmark, 
    QuestionReport, 
    RefreshToken, 
    StudyPlan, 
    UserSpecialty, 
    UserAchievement, 
    DailyStreak, 
    Notification, 
    AIFeedback, 
    StudySession, 
    Payment, 
    Referral, 
    AdminActivityLog,
    sequelize 
} = require('../../models');
const { Op } = require('sequelize');

// @desc    Get all users
// @route   GET /api/v1/admin/users
// @access  Private (Admin)
exports.getUsers = async (req, res, next) => {
    try {
        const { page = 1, limit = 50, role, search } = req.query;
        const pageNum = parseInt(page, 10) || 1;
        const limitNum = parseInt(limit, 10) || 50;
        const offset = (pageNum - 1) * limitNum;

        const whereClause = {};
        if (role) whereClause.role = role;
        if (search && search.trim()) {
            whereClause[Op.or] = [
                { fullName: { [Op.like]: `%${search.trim()}%` } },
                { email: { [Op.like]: `%${search.trim()}%` } }
            ];
        }

        const { count, rows } = await User.findAndCountAll({
            where: whereClause,
            limit: limitNum,
            offset: offset,
            attributes: { exclude: ['password'] },
            include: [{ model: Subscription, as: 'subscriptions', required: false, where: { status: 'active' } }],
            order: [['createdAt', 'DESC']]
        });

        // Map 'isPremium' for the frontend based on active subscriptions
        const data = rows.map(u => {
            const userJson = u.toJSON();
            userJson.isPremium = Boolean(userJson.subscriptions && userJson.subscriptions.length > 0);
            return userJson;
        });

        res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / limitNum),
            currentPage: pageNum,
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

// Helper function to safely delete all associated data for a user before deleting the user row
async function deleteUserData(userId, transaction) {
    // 1. Delete user's mock exam answers first (references UserMockExam)
    if (UserMockExam && UserMockExamAnswer) {
        const userMockExams = await UserMockExam.findAll({
            where: { userId },
            attributes: ['id'],
            transaction
        });
        const examIds = userMockExams.map(e => e.id);
        if (examIds.length > 0) {
            await UserMockExamAnswer.destroy({
                where: { userMockExamId: examIds },
                transaction
            });
        }
        await UserMockExam.destroy({ where: { userId }, transaction });
    }

    // 2. Delete all related user records in parallel
    const deleteTasks = [];
    if (QuestionAttempt) deleteTasks.push(QuestionAttempt.destroy({ where: { userId }, transaction }));
    if (UserProgress) deleteTasks.push(UserProgress.destroy({ where: { userId }, transaction }));
    if (Bookmark) deleteTasks.push(Bookmark.destroy({ where: { userId }, transaction }));
    if (QuestionReport) deleteTasks.push(QuestionReport.destroy({ where: { userId }, transaction }));
    if (RefreshToken) deleteTasks.push(RefreshToken.destroy({ where: { userId }, transaction }));
    if (StudyPlan) deleteTasks.push(StudyPlan.destroy({ where: { userId }, transaction }));
    if (UserSpecialty) deleteTasks.push(UserSpecialty.destroy({ where: { userId }, transaction }));
    if (UserAchievement) deleteTasks.push(UserAchievement.destroy({ where: { userId }, transaction }));
    if (DailyStreak) deleteTasks.push(DailyStreak.destroy({ where: { userId }, transaction }));
    if (Notification) deleteTasks.push(Notification.destroy({ where: { userId }, transaction }));
    if (AIFeedback) deleteTasks.push(AIFeedback.destroy({ where: { userId }, transaction }));
    if (StudySession) deleteTasks.push(StudySession.destroy({ where: { userId }, transaction }));
    if (Subscription) deleteTasks.push(Subscription.destroy({ where: { userId }, transaction }));
    if (Payment) deleteTasks.push(Payment.destroy({ where: { userId }, transaction }));
    if (Referral) {
        deleteTasks.push(Referral.destroy({
            where: {
                [Op.or]: [{ referrerUserId: userId }, { referredUserId: userId }]
            },
            transaction
        }));
    }
    if (AdminActivityLog) {
        deleteTasks.push(AdminActivityLog.destroy({ where: { userId }, transaction }).catch(() => {}));
    }

    await Promise.all(deleteTasks);

    // 3. Delete the user row
    await User.destroy({ where: { id: userId }, transaction });
}

// @desc    Delete user and all associated data
// @route   DELETE /api/v1/admin/users/:id
// @access  Private (Admin)
exports.deleteUser = async (req, res, next) => {
    const t = await sequelize.transaction();
    try {
        const { id } = req.params;
        const currentAdminId = req.user?.id;

        // Prevent admin from deleting their own currently logged-in account
        if (currentAdminId && (currentAdminId === parseInt(id, 10) || currentAdminId.toString() === id.toString())) {
            await t.rollback();
            return res.status(400).json({
                success: false,
                message: 'لا يمكنك حذف حساب المسؤول المسجل دخولك به حالياً'
            });
        }

        const user = await User.findByPk(id, { transaction: t });
        if (!user) {
            await t.rollback();
            return res.status(404).json({
                success: false,
                message: 'المستخدم غير موجود'
            });
        }

        await deleteUserData(user.id, t);
        await t.commit();

        res.status(200).json({
            success: true,
            message: 'تم حذف المستخدم وجميع بياناته بنجاح'
        });
    } catch (error) {
        await t.rollback();
        next(error);
    }
};

// @desc    Bulk delete users
// @route   POST /api/v1/admin/users/bulk-delete
// @access  Private (Admin)
exports.bulkDeleteUsers = async (req, res, next) => {
    const t = await sequelize.transaction();
    try {
        const { ids } = req.body;
        if (!Array.isArray(ids) || ids.length === 0) {
            await t.rollback();
            return res.status(400).json({
                success: false,
                message: 'يرجى تحديد مستخدمين للحذف'
            });
        }

        const currentAdminId = req.user?.id;
        const validIds = ids.filter(id => !currentAdminId || (currentAdminId !== parseInt(id, 10) && currentAdminId.toString() !== id.toString()));

        if (validIds.length === 0) {
            await t.rollback();
            return res.status(400).json({
                success: false,
                message: 'لا يمكنك حذف حساب المسؤول الحالي'
            });
        }

        for (const id of validIds) {
            await deleteUserData(id, t);
        }

        await t.commit();

        res.status(200).json({
            success: true,
            message: `تم حذف ${validIds.length} مستخدم بنجاح`,
            deletedCount: validIds.length
        });
    } catch (error) {
        await t.rollback();
        next(error);
    }
};

