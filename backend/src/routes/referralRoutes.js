const express = require('express');
const { generateReferralCode, getMyReferrals } = require('../controllers/referralController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.post('/generate-code', protect, generateReferralCode);
router.get('/my-referrals', protect, getMyReferrals);

module.exports = router;
