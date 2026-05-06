const express = require('express');
const { getOverview, getRecentActivity, getDailyStats, getWeeklyStats, getMonthlyStats, getAchievements } = require('../controllers/dashboardController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/overview', protect, getOverview);
router.get('/recent-activity', protect, getRecentActivity);
router.get('/stats/daily', protect, getDailyStats);
router.get('/stats/weekly', protect, getWeeklyStats);
router.get('/stats/monthly', protect, getMonthlyStats);
router.get('/achievements', protect, getAchievements);

module.exports = router;
