const express = require('express');
const { getAchievements, getStreaks, getAchievementDetails, getUserAchievements } = require('../controllers/gamificationController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/lists', protect, getAchievements); // Mapped to /api/v1/achievements in app.js
router.get('/:id', protect, getAchievementDetails);
router.get('/user/list', protect, getUserAchievements); // Mapped under /api/v1/achievements or /user/achievements? App.js says /gamification
router.get('/streaks', protect, getStreaks);

module.exports = router;
