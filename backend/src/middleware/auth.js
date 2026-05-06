const jwt = require('jsonwebtoken');
const { User } = require('../models');

const protect = async (req, res, next) => {
    let token;

    if (
        req.headers.authorization &&
        req.headers.authorization.startsWith('Bearer')
    ) {
        try {
            // Get token from header and ensure it's not empty
            const authHeader = req.headers.authorization;
            if (authHeader && authHeader.split(' ').length === 2) {
                token = authHeader.split(' ')[1];
            }

            if (!token || token === 'null' || token === 'undefined') {
                return res.status(401).json({ success: false, message: 'Not authorized, invalid token format' });
            }

            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            console.log('🔹 Auth Debug: Decoded ID:', decoded.id);

            // Get user from the token
            req.user = await User.findByPk(decoded.id, {
                attributes: { exclude: ['password', 'verificationToken', 'resetPasswordToken'] }
            });

            if (!req.user) {
                console.log('🔹 Auth Debug: User not found for ID:', decoded.id);
                return res.status(401).json({ success: false, message: 'Not authorized, user not found' });
            }

            console.log('🔹 Auth Debug: User found:', req.user.email);
            next();
        } catch (error) {
            console.error(error);
            return res.status(401).json({ success: false, message: 'Not authorized, token failed' });
        }
    }

    if (!token) {
        return res.status(401).json({ success: false, message: 'Not authorized, no token' });
    }
};

const admin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next();
    } else {
        res.status(403).json({ success: false, message: 'Not authorized as an admin' });
    }
};

// @desc    Check if user has an active premium subscription
// @usage   router.get('/premium-content', protect, subscription, handler)
//          router.get('/preview', protect, subscription({ allowFreePreview: true }), handler)
const subscription = (options = {}) => {
    // Support both subscription (as function call) and subscription (as direct middleware)
    const middleware = async (req, res, next) => {
        try {
            const { Subscription, SubscriptionPlan } = require('../models');

            const activeSubscription = await Subscription.findOne({
                where: {
                    userId: req.user.id,
                    status: 'active'
                },
                include: [{
                    model: SubscriptionPlan,
                    as: 'plan',
                    attributes: ['id', 'name', 'slug', 'features']
                }],
                order: [['endDate', 'DESC']]
            });

            if (!activeSubscription || !activeSubscription.isValid()) {
                // If allowFreePreview is enabled, let the request through but flag it
                if (options.allowFreePreview) {
                    req.subscription = null;
                    req.isPremium = false;
                    return next();
                }

                return res.status(403).json({
                    success: false,
                    message: 'يتطلب اشتراك مفعّل للوصول لهذا المحتوى',
                    code: 'SUBSCRIPTION_REQUIRED',
                    data: {
                        requiresSubscription: true,
                        currentStatus: activeSubscription ? activeSubscription.status : 'none',
                        expiredAt: activeSubscription ? activeSubscription.endDate : null
                    }
                });
            }

            // Attach subscription info to request for downstream use
            req.subscription = activeSubscription;
            req.isPremium = true;
            next();
        } catch (error) {
            next(error);
        }
    };

    // Allow usage as both subscription() and subscription (without calling)
    if (typeof options === 'function') {
        // Called as middleware directly: subscription (not subscription())
        const actualReq = options;
        const actualRes = arguments[1];
        const actualNext = arguments[2];
        options = {};
        return middleware(actualReq, actualRes, actualNext);
    }

    return middleware;
};

module.exports = { protect, admin, subscription };
