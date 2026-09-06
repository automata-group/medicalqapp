const express = require('express');
const router = express.Router();
const contributionController = require('../controllers/contributionController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { contributionLimiter } = require('../middleware/rateLimiter');

// Protected routes (Student app)
router.use(protect);

router.post('/', contributionLimiter, upload.single('image'), contributionController.createContribution);
router.get('/my-contributions', contributionController.getMyContributions);

module.exports = router;
