const express = require('express');
const { getNextQuestion, submitAnswer, bookmarkQuestion, reportQuestion, getPracticeFilters, getSpecialtyTopics } = require('../controllers/questionController');
const { protect, subscription } = require('../middleware/auth');

const router = express.Router();

router.get('/practice/filters', protect, getPracticeFilters);
router.get('/specialties/:id/topics', protect, subscription({ allowFreePreview: true }), getSpecialtyTopics);
router.get('/practice/next', protect, subscription({ allowFreePreview: true }), getNextQuestion);
router.post('/:id/answer', protect, submitAnswer);
router.post('/:id/bookmark', protect, bookmarkQuestion);
router.post('/:id/report', protect, reportQuestion);

module.exports = router;
