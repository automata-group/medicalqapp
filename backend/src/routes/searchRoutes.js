const express = require('express');
const { searchQuestions, advancedSearch } = require('../controllers/searchController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/questions', protect, searchQuestions);
router.post('/advanced', protect, advancedSearch);

module.exports = router;
