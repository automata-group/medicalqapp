const express = require('express');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const { getQuestions, createQuestion, getQuestion, updateQuestion, deleteQuestion, bulkImportQuestions, bulkImportDocx, reorderQuestion, aiVerify, aiGenerateExplanation, aiGenerateQuestion } = require('../../controllers/admin/questionController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getQuestions);
router.post('/', createQuestion);
router.post('/bulk-import', upload.single('file'), bulkImportQuestions);
router.post('/bulk-import-docx', upload.single('file'), bulkImportDocx);
router.post('/ai-generate', aiGenerateQuestion);
router.get('/:id', getQuestion);
router.put('/:id', updateQuestion);
router.delete('/:id', deleteQuestion);
router.put('/:id/reorder', reorderQuestion);
router.post('/:id/ai-verify', aiVerify);
router.post('/:id/ai-explain', aiGenerateExplanation);

module.exports = router;
