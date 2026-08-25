const express = require('express');
const { updateProfile, changePassword, deleteAccount, getPublicSettings } = require('../controllers/settingsController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/config', getPublicSettings);
router.put('/profile', protect, updateProfile);
router.put('/change-password', protect, changePassword);
router.delete('/account', protect, deleteAccount);

module.exports = router;

