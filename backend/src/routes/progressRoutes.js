const express = require('express');
const { getSpecialtyProgress, getOverallStats, getPerformanceTrends, getSpecialtyDetails, getTimeAnalysis } = require('../controllers/progressController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/specialties', protect, getSpecialtyProgress);
router.get('/specialty/:id/details', protect, getSpecialtyDetails);
router.get('/overall', protect, getOverallStats);
router.get('/time-analysis', protect, getTimeAnalysis);
router.get('/performance-trends', protect, getPerformanceTrends);

module.exports = router;
