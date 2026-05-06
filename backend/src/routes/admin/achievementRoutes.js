const express = require('express');
const router = express.Router();
const { getAchievements, createAchievement, updateAchievement, deleteAchievement } = require('../../controllers/admin/achievementController');
const { protect, admin } = require('../../middleware/auth');

router.use(protect);
router.use(admin);

router.route('/')
    .get(getAchievements)
    .post(createAchievement);

router.route('/:id')
    .put(updateAchievement)
    .delete(deleteAchievement);

module.exports = router;
