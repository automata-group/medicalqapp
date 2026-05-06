const express = require('express');
const { getNotifications, markAsRead, getUnreadCount, markAllAsRead, deleteNotification, registerFcmToken } = require('../controllers/notificationController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/', protect, getNotifications);
router.get('/unread-count', protect, getUnreadCount);
router.put('/read-all', protect, markAllAsRead);
router.put('/:id/read', protect, markAsRead);
router.post('/register-token', protect, registerFcmToken);
router.delete('/:id', protect, deleteNotification);

module.exports = router;
