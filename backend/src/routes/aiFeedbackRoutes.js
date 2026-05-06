const express = require('express');
const router = express.Router();
const { generateFeedback, getLatestFeedback } = require('../controllers/aiFeedbackController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.post('/generate', generateFeedback);
router.get('/latest', getLatestFeedback);

module.exports = router;
