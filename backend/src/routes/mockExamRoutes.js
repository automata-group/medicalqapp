const express = require('express');
const { startMockExam, completeMockExam, getSectionQuestions, submitAnswer, getMockExamHistory, reviewMockExam, getMockExam, getMockExams } = require('../controllers/mockExamController');
const { protect, subscription } = require('../middleware/auth');

const router = express.Router();

router.post('/start', protect, subscription({ allowFreePreview: true }), startMockExam);
router.get('/', protect, subscription({ allowFreePreview: true }), getMockExams); // List all exams
router.get('/history', protect, getMockExamHistory); // Must be before parameters
router.get('/:id', protect, subscription({ allowFreePreview: true }), getMockExam);
router.post('/:attemptId/complete', protect, completeMockExam);
router.get('/:attemptId/sections/:sectionId', protect, getSectionQuestions);
router.post('/:attemptId/answer', protect, submitAnswer);
router.get('/:attemptId/review', protect, reviewMockExam);

module.exports = router;
