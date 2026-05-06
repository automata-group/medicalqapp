const express = require('express');
const { getTemplates, createTemplate, updateTemplate, broadcastNotification, sendToUser } = require('../../controllers/admin/notificationController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/templates', getTemplates);
router.post('/templates', createTemplate);
router.put('/templates/:id', updateTemplate);
router.post('/send', sendToUser);
router.post('/broadcast', broadcastNotification);

module.exports = router;
