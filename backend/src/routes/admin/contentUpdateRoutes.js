const express = require('express');
const { getContentUpdates, createContentUpdate, deleteContentUpdate, notifyUsers } = require('../../controllers/admin/contentUpdateController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getContentUpdates);
router.post('/', createContentUpdate);
router.delete('/:id', deleteContentUpdate);
router.post('/:id/notify', notifyUsers);

module.exports = router;
