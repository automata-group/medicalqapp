const express = require('express');
const { getBookmarks, deleteBookmark, updateNote, getBookmark } = require('../controllers/bookmarkController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/', protect, getBookmarks);
router.get('/:id', protect, getBookmark);
router.delete('/:id', protect, deleteBookmark);
router.put('/:id/notes', protect, updateNote);

module.exports = router;
