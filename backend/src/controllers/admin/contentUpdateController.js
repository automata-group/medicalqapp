const { ContentUpdate, Notification, User, AdminActivityLog } = require('../../models');

// @desc    Get all content updates
// @route   GET /api/v1/admin/content-updates
// @access  Private (Admin)
exports.getContentUpdates = async (req, res, next) => {
    try {
        const { page = 1, limit = 10 } = req.query;
        const offset = (page - 1) * limit;

        const { count, rows } = await ContentUpdate.findAndCountAll({
            limit: parseInt(limit),
            offset: parseInt(offset),
            order: [['releaseDate', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            data: rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create content update
// @route   POST /api/v1/admin/content-updates
// @access  Private (Admin)
exports.createContentUpdate = async (req, res, next) => {
    try {
        const { title, description, version, type } = req.body;

        const update = await ContentUpdate.create({
            title,
            description,
            version,
            type
        });

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'CREATE_CONTENT_UPDATE',
            targetResource: `ContentUpdate:${update.id}`,
            ipAddress: req.ip
        });

        res.status(201).json({ success: true, data: update });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete content update
// @route   DELETE /api/v1/admin/content-updates/:id
// @access  Private (Admin)
exports.deleteContentUpdate = async (req, res, next) => {
    try {
        const update = await ContentUpdate.findByPk(req.params.id);

        if (!update) {
            return res.status(404).json({ success: false, message: 'Content update not found' });
        }

        await update.destroy();

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'DELETE_CONTENT_UPDATE',
            targetResource: `ContentUpdate:${req.params.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Content update deleted' });
    } catch (error) {
        next(error);
    }
};

// @desc    Notify users about update
// @route   POST /api/v1/admin/content-updates/:id/notify
// @access  Private (Admin)
exports.notifyUsers = async (req, res, next) => {
    try {
        const update = await ContentUpdate.findByPk(req.params.id);

        if (!update) {
            return res.status(404).json({ success: false, message: 'Content update not found' });
        }

        // Broad cast to all users logic
        // For scalability, this should be a background job.
        // For MVP, we'll select ID from Users and BulkCreate Notifications.
        const users = await User.findAll({ attributes: ['id'] });

        if (users.length > 0) {
            const notifications = users.map(user => ({
                userId: user.id,
                title: `New Update: ${update.title} (${update.version})`,
                message: update.description.substring(0, 200) + '...', // Truncate if long
                type: 'update',
                data: { updateId: update.id }
            }));

            await Notification.bulkCreate(notifications);
        }

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'NOTIFY_USERS_UPDATE',
            targetResource: `ContentUpdate:${update.id}`,
            details: `Notified ${users.length} users`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: `Notifications sent to ${users.length} users` });

    } catch (error) {
        next(error);
    }
};
