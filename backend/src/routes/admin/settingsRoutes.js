const express = require('express');
const { getSettings, updateSettings, getAiConfig, updateAiConfig } = require('../../controllers/admin/settingsController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/settings', getSettings);
router.put('/settings', updateSettings);
router.get('/ai-config', getAiConfig);
router.put('/ai-config', updateAiConfig);

module.exports = router;
