const express = require('express');
const { downloadQuestions, syncOfflineData } = require('../controllers/offlineController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/download-questions', protect, downloadQuestions);
router.post('/sync', protect, syncOfflineData);

module.exports = router;
