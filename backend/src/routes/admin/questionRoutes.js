const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const upload = multer({ dest: 'uploads/' });

// Ensure question uploads directory exists
const questionUploadDir = path.join(__dirname, '../../../uploads/questions');
if (!fs.existsSync(questionUploadDir)) {
    fs.mkdirSync(questionUploadDir, { recursive: true });
}

const questionStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, questionUploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname) || '.jpg';
        cb(null, 'q_img_' + uniqueSuffix + ext);
    }
});

const questionImageUpload = multer({
    storage: questionStorage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
    fileFilter: (req, file, cb) => {
        const isImage = file.mimetype.startsWith('image/') ||
            file.originalname.match(/\.(jpg|jpeg|png|gif|webp|jfif|heic|heif)$/i);
        if (isImage) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'), false);
        }
    }
});

const {
    getQuestions,
    createQuestion,
    getQuestion,
    updateQuestion,
    deleteQuestion,
    moveQuestion,
    bulkMoveQuestions,
    bulkImportQuestions,
    bulkImportDocx,
    reorderQuestion,
    aiVerify,
    aiGenerateExplanation,
    aiGenerateQuestion,
    uploadQuestionImage
} = require('../../controllers/admin/questionController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getQuestions);
router.post('/', createQuestion);
router.post('/upload-image', questionImageUpload.single('image'), uploadQuestionImage);
router.post('/bulk-import', upload.single('file'), bulkImportQuestions);
router.post('/bulk-import-docx', upload.single('file'), bulkImportDocx);
router.post('/bulk-move', bulkMoveQuestions);
router.post('/ai-generate', aiGenerateQuestion);
router.get('/:id', getQuestion);
router.put('/:id', updateQuestion);
router.put('/:id/move', moveQuestion);
router.delete('/:id', deleteQuestion);
router.put('/:id/reorder', reorderQuestion);
router.post('/:id/ai-verify', aiVerify);
router.post('/:id/ai-explain', aiGenerateExplanation);

module.exports = router;
