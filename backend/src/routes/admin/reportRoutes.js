const express = require('express');
const { getReports, getReport, updateReportStatus, getReportStats } = require('../../controllers/admin/reportController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getReports);
router.get('/statistics', getReportStats);
router.get('/:id', getReport);
router.put('/:id/status', updateReportStatus);
router.put('/:id', updateReportStatus);

module.exports = router;
