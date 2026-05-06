const express = require('express');
const {
    getPayments,
    getPayment,
    getPaymentStatistics,
    getDailyRevenue,
    getMonthlyRevenue
} = require('../../controllers/admin/paymentController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/', getPayments);
router.get('/statistics', getPaymentStatistics);
router.get('/revenue/daily', getDailyRevenue);
router.get('/revenue/monthly', getMonthlyRevenue);
router.get('/:id', getPayment);

module.exports = router;
