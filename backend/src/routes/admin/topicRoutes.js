const express = require('express');
const { getTopics, getTopic, createTopic, updateTopic, deleteTopic } = require('../../controllers/admin/topicController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin); // All routes require admin

router.route('/')
    .get(getTopics)
    .post(createTopic);

router.route('/:id')
    .get(getTopic)
    .put(updateTopic)
    .delete(deleteTopic);

module.exports = router;
