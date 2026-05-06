const express = require('express');
const router = express.Router();
const { getMockExams, createMockExam, updateMockExam, deleteMockExam, aiGenerateMockQuestions } = require('../../controllers/admin/mockExamController');
const { protect, admin } = require('../../middleware/auth');

router.use(protect);
router.use(admin);

router.route('/')
    .get(getMockExams)
    .post(createMockExam);

router.route('/:id')
    .put(updateMockExam)
    .delete(deleteMockExam);

router.post('/:id/ai-generate', aiGenerateMockQuestions);

module.exports = router;
