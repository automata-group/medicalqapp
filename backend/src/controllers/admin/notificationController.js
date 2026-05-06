const { Notification, NotificationTemplate, User, AdminActivityLog } = require('../../models');
const pushNotificationService = require('../../services/pushNotificationService');

// @desc    Get all notification templates
// @route   GET /api/v1/admin/notification-templates
// @access  Private (Admin)
exports.getTemplates = async (req, res, next) => {
    try {
        const templates = await NotificationTemplate.findAll();
        res.status(200).json({ success: true, data: templates });
    } catch (error) {
        next(error);
    }
};

// @desc    Create notification template
// @route   POST /api/v1/admin/notification-templates
// @access  Private (Admin)
exports.createTemplate = async (req, res, next) => {
    try {
        const template = await NotificationTemplate.create(req.body);
        res.status(201).json({ success: true, data: template });
    } catch (error) {
        next(error);
    }
};

// @desc    Update notification template
// @route   PUT /api/v1/admin/notification-templates/:id
// @access  Private (Admin)
exports.updateTemplate = async (req, res, next) => {
    try {
        const template = await NotificationTemplate.findByPk(req.params.id);
        if (!template) {
            return res.status(404).json({ success: false, message: 'Template not found' });
        }
        await template.update(req.body);
        res.status(200).json({ success: true, data: template });
    } catch (error) {
        next(error);
    }
};

// @desc    Broadcast notification
// @route   POST /api/v1/admin/notifications/broadcast
// @access  Private (Admin)
exports.broadcastNotification = async (req, res, next) => {
    try {
        const { title, message, type = 'system' } = req.body;

        if (!title || !message) {
            return res.status(400).json({ success: false, message: 'title and message are required' });
        }

        const users = await User.findAll({ attributes: ['id', 'firebaseToken'] });

        if (users.length > 0) {
            // 1. Create in-app notifications for all users
            const notifications = users.map(user => ({
                userId: user.id,
                title,
                message,
                type
            }));
            await Notification.bulkCreate(notifications);

            // 2. Send real push notifications via FCM
            const fcmTokens = users
                .filter(u => u.firebaseToken)
                .map(u => u.firebaseToken);

            let pushResult = { successCount: 0, failureCount: 0 };

            if (fcmTokens.length > 0) {
                try {
                    // FCM allows max 500 tokens per multicast
                    const batchSize = 500;
                    for (let i = 0; i < fcmTokens.length; i += batchSize) {
                        const batch = fcmTokens.slice(i, i + batchSize);
                        const result = await pushNotificationService.sendMulticastNotification(
                            batch, title, message, { type }
                        );
                        pushResult.successCount += (result.successCount || 0);
                        pushResult.failureCount += (result.failureCount || 0);
                    }
                } catch (pushError) {
                    console.warn('[Broadcast] Push notification error:', pushError.message);
                }
            }

            // Also send via topic for devices that might have missed individual push
            try {
                await pushNotificationService.sendTopicNotification('all_users', title, message, { type });
            } catch (topicError) {
                console.warn('[Broadcast] Topic notification skipped:', topicError.message);
            }

            await AdminActivityLog.create({
                adminId: req.user.id,
                action: 'BROADCAST_NOTIFICATION',
                targetResource: 'All Users',
                details: `Sent "${title}" to ${users.length} users (Push: ${pushResult.successCount} delivered, ${pushResult.failureCount} failed)`,
                ipAddress: req.ip
            });

            res.status(200).json({
                success: true,
                message: `Broadcast sent to ${users.length} users`,
                push: {
                    totalTokens: fcmTokens.length,
                    delivered: pushResult.successCount,
                    failed: pushResult.failureCount
                }
            });
        } else {
            res.status(200).json({ success: true, message: 'No users to broadcast to' });
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Send to specific user
// @route   POST /api/v1/admin/notifications/send
// @access  Private (Admin)
exports.sendToUser = async (req, res, next) => {
    try {
        const { userId, title, message, type = 'system' } = req.body;

        // 1. Create in-app notification
        await Notification.create({
            userId,
            title,
            message,
            type
        });

        // 2. Send real push notification if user has FCM token
        const targetUser = await User.findByPk(userId, { attributes: ['id', 'firebaseToken'] });
        if (targetUser && targetUser.firebaseToken) {
            try {
                await pushNotificationService.sendPushNotification(
                    targetUser.firebaseToken, title, message, { type }
                );
            } catch (pushErr) {
                console.warn('[SendToUser] Push failed:', pushErr.message);
            }
        }

        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'SEND_NOTIFICATION',
            targetResource: `User:${userId}`,
            details: `Sent "${title}"`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Notification sent' });
    } catch (error) {
        next(error);
    }
};
