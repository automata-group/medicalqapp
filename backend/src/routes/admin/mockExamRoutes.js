const express = require('express');
const router = express.Router();
const { 
    getMockExams, 
    createMockExam, 
    updateMockExam, 
    deleteMockExam, 
    aiGenerateMockQuestions,
    getMockExamQuestions,
    addQuestionsFromBank,
    addCustomMockQuestion,
    deleteMockQuestion
} = require('../../controllers/admin/mockExamController');
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

// Mock Exam Questions
router.get('/:id/questions', getMockExamQuestions);
router.post('/:id/add-from-bank', addQuestionsFromBank);
router.post('/:id/add-custom-question', addCustomMockQuestion);
router.delete('/:id/questions/:questionId', deleteMockQuestion);

module.exports = router;

