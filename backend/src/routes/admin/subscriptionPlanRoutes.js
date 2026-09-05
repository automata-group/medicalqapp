const express = require('express');
const { getPlans, createPlan, updatePlan, deletePlan, seedDefaultPlans } = require('../../controllers/admin/subscriptionPlanController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getPlans);
router.post('/', createPlan);
router.post('/seed-defaults', seedDefaultPlans);
router.put('/:id', updatePlan);
router.delete('/:id', deletePlan);

module.exports = router;
