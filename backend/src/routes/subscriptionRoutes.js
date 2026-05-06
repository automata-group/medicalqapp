const express = require('express');
const { protect } = require('../middleware/auth');
const { getSubscription, createCheckoutSession, handleWebhook, getPlans, validatePromoCode, renderCheckoutPage } = require('../controllers/subscriptionController');
const router = express.Router();

router.get('/plans', getPlans);
router.get('/current', protect, getSubscription);
router.get('/checkout-page/:token', renderCheckoutPage); // Serves the custom Moyasar JS SDK page
router.post('/pay', protect, createCheckoutSession);
router.post('/validate-promo', protect, validatePromoCode);
router.post('/webhook', handleWebhook); // Webhook uses its own signature verification

module.exports = router;
