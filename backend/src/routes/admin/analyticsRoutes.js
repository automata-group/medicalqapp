const express = require('express');
const {
    getAnalyticsOverview,
    getUserAnalytics,
    getQuestionAnalytics,
    getPerformanceAnalytics,
    getMockExamAnalytics,
    exportAnalytics,
    getBusinessAnalytics
} = require('../../controllers/admin/analyticsController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/overview', getAnalyticsOverview);
router.get('/users', getUserAnalytics);
router.get('/questions', getQuestionAnalytics);
router.get('/performance', getPerformanceAnalytics);
router.get('/mock-exams', getMockExamAnalytics);
router.get('/business', getBusinessAnalytics);
router.get('/export', exportAnalytics);

module.exports = router;
