const express = require('express');
const {
    getDiscountCodes,
    createDiscountCode,
    updateDiscountCode,
    deleteDiscountCode,
    getDiscountUsage
} = require('../../controllers/admin/discountCodeController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.route('/')
    .get(getDiscountCodes)
    .post(createDiscountCode);

router.route('/:id')
    .put(updateDiscountCode)
    .delete(deleteDiscountCode);

router.get('/:id/usage', getDiscountUsage);

module.exports = router;
