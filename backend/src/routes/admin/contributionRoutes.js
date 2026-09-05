const express = require('express');
const router = express.Router();
const contributionController = require('../../controllers/admin/contributionController');
const { protect, admin } = require('../../middleware/auth');

// Protected admin routes
router.use(protect);
router.use(admin);

router.get('/', contributionController.getAllContributions);
router.get('/:id', contributionController.getContributionById);
router.patch('/:id/status', contributionController.updateContributionStatus);
router.post('/:id/convert-to-question', contributionController.convertToOfficialQuestion);

module.exports = router;
