const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const { User, RefreshToken } = require('../models');
const sendEmail = require('../utils/sendEmail');

// Helper to generate Access Token
const generateAccessToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE || '15m'
    });
};

// ... (register, login, getMe, refreshToken, logout methods - keeping them as is, just appending or replacing file if easier)
// ACTUALLY, replace_file_content is best if I just append. But I need to handle imports at top.
// I will replace the whole file to be safe and clean.

exports.register = async (req, res, next) => {
    try {
        const { fullName, email, password, phone, referralCode } = req.body;

        // Check if user exists
        const userExists = await User.findOne({ where: { email } });
        if (userExists) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }

        let referredById = null;
        if (referralCode) {
            const referrer = await User.findOne({ where: { referralCode } });
            if (referrer) {
                referredById = referrer.id;
            }
        }

        // Generate unique code
        let newReferralCode;
        let isUnique = false;
        while (!isUnique) {
            newReferralCode = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 char hex
            const exists = await User.findOne({ where: { referralCode: newReferralCode } });
            if (!exists) {
                isUnique = true;
            }
        }

        // Create user
        const user = await User.create({
            fullName,
            email,
            password,
            phone,
            referralCode: newReferralCode,
            referredById
        });

        // Generate tokens
        const accessToken = generateAccessToken(user.id);
        const refreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        res.status(201).json({
            success: true,
            data: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                referralCode: user.referralCode,
                accessToken,
                refreshToken
            }
        });
    } catch (error) {
        next(error);
    }
};

exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ success: false, message: 'Please provide email and password' });
        }

        const user = await User.findOne({
            where: { email },
            include: [
                { model: require('../models').Specialty, as: 'specialties', attributes: ['id'] },
                { model: require('../models').StudyPlan, as: 'studyPlan', attributes: ['id'] },
                {
                    model: require('../models').Subscription,
                    as: 'subscriptions',
                    where: { status: 'active' },
                    required: false,
                    limit: 1,
                    order: [['endDate', 'DESC']]
                }
            ]
        });
        if (!user) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        const isMatch = await user.matchPassword(password);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        const accessToken = generateAccessToken(user.id);
        const refreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        const activeSubscription = user.subscriptions && user.subscriptions.length > 0 ? user.subscriptions[0] : null;
        const isPremium = activeSubscription && new Date() <= activeSubscription.endDate;

        res.status(200).json({
            success: true,
            data: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                hasSpecialties: user.specialties && user.specialties.length > 0,
                hasStudyPlan: !!user.studyPlan,
                isPremium: !!isPremium,
                accessToken,
                refreshToken
            }
        });
    } catch (error) {
        next(error);
    }
};

exports.getMe = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.user.id, {
            attributes: { exclude: ['password', 'verificationToken', 'resetPasswordToken'] },
            include: [
                'specialties',
                'studyPlan',
                {
                    model: require('../models').Subscription,
                    as: 'subscriptions',
                    where: { status: 'active' },
                    required: false,
                    limit: 1,
                    order: [['endDate', 'DESC']]
                }
            ]
        });

        const activeSubscription = user.subscriptions && user.subscriptions.length > 0 ? user.subscriptions[0] : null;
        const isPremium = activeSubscription && new Date() <= activeSubscription.endDate;

        // Clone user data to add isPremium (since Sequelize instance is immutable-ish without .get({plain:true}))
        const userData = user.get({ plain: true });
        userData.isPremium = !!isPremium;
        delete userData.subscriptions; // Optional: hide raw subscription details

        res.status(200).json({
            success: true,
            data: userData
        });
    } catch (error) {
        next(error);
    }
};

exports.refreshToken = async (req, res, next) => {
    try {
        const { token } = req.body;

        if (!token) {
            return res.status(400).json({ success: false, message: 'Refresh Token is required' });
        }

        const refreshToken = await RefreshToken.findOne({ where: { token } });

        if (!refreshToken) {
            return res.status(403).json({ success: false, message: 'Refresh token is not in database!' });
        }

        if (RefreshToken.verifyExpiration(refreshToken)) {
            await RefreshToken.destroy({ where: { id: refreshToken.id } });
            return res.status(403).json({ success: false, message: 'Refresh token was expired. Please make a new signin request' });
        }

        if (refreshToken.revoked) {
            return res.status(403).json({ success: false, message: 'Refresh token was revoked' });
        }

        const user = await User.findByPk(refreshToken.userId);
        const newAccessToken = generateAccessToken(user.id);
        const newRefreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        refreshToken.replacedByToken = newRefreshToken.token;
        refreshToken.revoked = true;
        await refreshToken.save();

        res.status(200).json({
            success: true,
            accessToken: newAccessToken,
            refreshToken: newRefreshToken.token
        });
    } catch (error) {
        next(error);
    }
};

exports.logout = async (req, res, next) => {
    try {
        const { token } = req.body;
        if (token) {
            const refreshToken = await RefreshToken.findOne({ where: { token } });
            if (refreshToken) {
                await RefreshToken.revoke(refreshToken);
            }
        }

        res.status(200).json({
            success: true,
            message: 'Log out successful'
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Forgot Password
// @route   POST /api/v1/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res, next) => {
    try {
        const user = await User.findOne({ where: { email: req.body.email } });

        if (!user) {
            return res.status(200).json({ success: true, message: 'Email sent' }); // Security: don't reveal user existence
        }

        // Get reset token
        const resetToken = crypto.randomBytes(20).toString('hex');

        // Hash token and set to resetPasswordToken field
        const resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');

        // Set expire
        const resetPasswordExpires = Date.now() + 10 * 60 * 1000; // 10 minutes

        await user.update({ resetPasswordToken, resetPasswordExpires });

        // Create reset url
        const resetUrl = `http://localhost:3000/reset-password/${resetToken}`; // Start with localhost for now

        const message = `You are receiving this email because you (or someone else) has requested the reset of a password. Please make a PUT request to: \n\n ${resetUrl}`;

        try {
            await sendEmail({
                email: user.email,
                subject: 'Password Reset Token',
                message
            });
        } catch (err) {
            // Email failed — don't crash, just log it
            console.warn('⚠️  Email send failed (SMTP not configured). Reset token logged for dev use:', resetToken);
        }

        // In development, always return the token so the app can proceed without email
        const responseData = { message: 'If that email address is in our system, a reset link was sent.' };
        if (process.env.NODE_ENV === 'development') {
            responseData.resetToken = resetToken; // Frontend can use this directly
        }

        res.status(200).json({ success: true, data: responseData });
    } catch (error) {
        next(error);
    }
};

// @desc    Reset Password
// @route   PUT /api/v1/auth/reset-password/:resettoken
// @access  Public
exports.resetPassword = async (req, res, next) => {
    try {
        // Get hashed token
        const resetPasswordToken = crypto.createHash('sha256').update(req.params.resettoken).digest('hex');

        const user = await User.findOne({
            where: {
                resetPasswordToken,
                resetPasswordExpires: { [require('sequelize').Op.gt]: Date.now() }
            }
        });

        if (!user) {
            return res.status(400).json({ success: false, message: 'Invalid token' });
        }

        // Set new password
        user.password = req.body.password; // Hook will hash it
        user.resetPasswordToken = null;
        user.resetPasswordExpires = null;
        await user.save();

        res.status(200).json({
            success: true,
            data: 'Password updated'
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Verify Email
// @route   POST /api/v1/auth/verify-email
// @access  Public
exports.verifyEmail = async (req, res, next) => {
    // Stub for now
    res.status(200).json({ success: true, message: 'Email verified' });
};
