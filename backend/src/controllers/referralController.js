const { Referral, User, DiscountCode } = require('../models');
const { v4: uuidv4 } = require('uuid');

// @desc    Generate referral code
// @route   POST /api/v1/referrals/generate-code
// @access  Private
exports.generateReferralCode = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.user.id);

        if (user.referralCode) {
            return res.status(200).json({ success: true, data: { referralCode: user.referralCode } });
        }

        // Generate simple code: First 4 letters of name + random string
        const base = user.fullName.replace(/[^a-zA-Z]/g, '').substring(0, 4).toUpperCase();
        const code = `${base}-${uuidv4().substring(0, 6).toUpperCase()}`;

        user.referralCode = code;
        await user.save();

        res.status(201).json({ success: true, data: { referralCode: code } });
    } catch (error) {
        next(error);
    }
};

// @desc    Get my referrals
// @route   GET /api/v1/referrals/my-referrals
// @access  Private
exports.getMyReferrals = async (req, res, next) => {
    try {
        const referrals = await Referral.findAll({
            where: { referrerId: req.user.id },
            include: [{ model: User, as: 'referredUser', attributes: ['id', 'fullName', 'createdAt'] }]
        });

        res.status(200).json({
            success: true,
            count: referrals.length,
            data: referrals
        });
    } catch (error) {
        next(error);
    }
};
