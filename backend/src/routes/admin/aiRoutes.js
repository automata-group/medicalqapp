const express = require('express');
const { verifyQuestion, generateExplanation } = require('../../controllers/admin/aiController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.post('/verify-question', verifyQuestion);
router.post('/generate-explanation', generateExplanation);

// Feedback Management
const { getAllFeedbacks, deleteFeedback, cleanupExpired } = require('../../controllers/admin/aiFeedbackController');
router.get('/feedbacks', getAllFeedbacks);
router.delete('/feedbacks/:id', deleteFeedback);
router.post('/cleanup', cleanupExpired);

module.exports = router;
