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

// Helper for localized response messages (supports AR and EN)
const getMsg = (req, ar, en) => {
    const lang = (req.headers['accept-language'] || req.headers['Accept-Language'] || 'ar').toLowerCase();
    return lang.startsWith('en') ? en : ar;
};

exports.register = async (req, res, next) => {
    try {
        const { fullName, email, password, phone, referralCode } = req.body;

        if (!email || !password || !fullName) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يرجى إدخال الاسم الكامل والبريد الإلكتروني وكلمة المرور.', 'Please provide full name, email, and password.')
            });
        }

        if (fullName.trim().length < 3) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يجب أن يتكون الاسم الكامل من 3 أحرف على الأقل.', 'Full name must be at least 3 characters long.')
            });
        }

        if (password.length < 8) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.', 'Password must be at least 8 characters long.')
            });
        }

        if (!/[A-Z]/.test(password)) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل (A-Z).', 'Password must contain at least one uppercase letter (A-Z).')
            });
        }

        if (!/[0-9]/.test(password)) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل (0-9).', 'Password must contain at least one number (0-9).')
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        // Check if user exists
        let user = await User.findOne({ where: { email: normalizedEmail } });
        if (user && user.isVerified) {
            return res.status(400).json({ 
                success: false, 
                code: 'EMAIL_ALREADY_EXISTS',
                message: getMsg(req, 'هذا البريد الإلكتروني مسجل بالفعل في المنصة. يمكنك تسجيل الدخول مباشرة أو تغيير كلمة المرور.', 'This email is already registered. You can log in directly or change your password.')
            });
        }

        let referredById = null;
        if (referralCode) {
            const referrer = await User.findOne({ where: { referralCode } });
            if (referrer) {
                referredById = referrer.id;
            }
        }

        // Generate unique referral code
        let newReferralCode;
        let isUnique = false;
        while (!isUnique) {
            newReferralCode = crypto.randomBytes(4).toString('hex').toUpperCase(); // 8 char hex
            const exists = await User.findOne({ where: { referralCode: newReferralCode } });
            if (!exists) {
                isUnique = true;
            }
        }

        // Generate 6-digit verification OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const verificationToken = crypto.createHash('sha256').update(otp).digest('hex');
        const resetPasswordExpires = Date.now() + 15 * 60 * 1000; // 15 mins

        if (user && !user.isVerified) {
            // Update unverified user with new password and new OTP
            user.fullName = fullName;
            user.password = password; // Hook hashes it
            user.phone = phone || user.phone;
            user.verificationToken = verificationToken;
            user.resetPasswordExpires = resetPasswordExpires;
            await user.save();
        } else {
            user = await User.create({
                fullName,
                email: normalizedEmail,
                password,
                phone,
                referralCode: newReferralCode,
                referredById,
                isVerified: false,
                verificationToken,
                resetPasswordExpires
            });
        }

        // Send activation email
        try {
            await sendEmail({
                email: user.email,
                subject: 'رمز تفعيل حسابكم الطبي - SDLE | Account Activation Code',
                message: `سعادة الدكتور، نرحب بكم في منصة SDLE. رمز التحقق الخاص بكم لتفعيل حسابكم الطبي هو: ${otp} (صالح لمدة 15 دقيقة).`,
                otp: otp,
                isRegistration: true
            });
        } catch (err) {
            console.warn('⚠️ Verification email send failed. OTP:', otp, err.message);
        }

        const responseData = {
            message: getMsg(req, 'تم إنشاء الحساب بنجاح. تم إرسال رمز التحقق إلى بريدك الإلكتروني.', 'Account created successfully. Verification code sent to your email.'),
            requireVerification: true,
            email: user.email
        };

        if (process.env.NODE_ENV === 'development') {
            responseData.otp = otp;
        }

        res.status(201).json({
            success: true,
            message: getMsg(req, 'تم إنشاء الحساب بنجاح. يرجى إدخال رمز التحقق لتفعيل الحساب.', 'Account created successfully. Please enter the verification code to activate your account.'),
            data: responseData
        });
    } catch (error) {
        next(error);
    }
};

exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يرجى إدخال البريد الإلكتروني وكلمة المرور.', 'Please enter email and password.')
            });
        }

        const normalizedEmail = email.trim().toLowerCase();

        const user = await User.findOne({
            where: { email: normalizedEmail },
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
            return res.status(401).json({ 
                success: false, 
                code: 'USER_NOT_FOUND',
                message: getMsg(req, 'هذا البريد الإلكتروني غير مسجل في المنصة. يرجى إنشاء حساب جديد.', 'This email is not registered on the platform. Please create a new account.')
            });
        }

        if (!user.isVerified) {
            return res.status(403).json({
                success: false,
                code: 'ACCOUNT_NOT_VERIFIED',
                requireVerification: true,
                email: user.email,
                message: getMsg(req, 'حسابكم الطبي غير مفعّل بعد. يرجى إدخال رمز التحقق لتفعيل الحساب.', 'Your medical account is not verified yet. Please enter the verification code.')
            });
        }

        const isMatch = await user.matchPassword(password);
        if (!isMatch) {
            return res.status(401).json({ 
                success: false, 
                code: 'INVALID_PASSWORD',
                message: getMsg(req, 'كلمة المرور غير صحيحة. يرجى التأكد من كتابتها أو استخدام خيار تغيير كلمة المرور.', 'Incorrect password. Please verify your credentials or change your password.')
            });
        }

        const accessToken = generateAccessToken(user.id);
        const refreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        const activeSub = await require('../models').Subscription.findOne({
            where: {
                userId: user.id,
                status: 'active',
                endDate: { [require('sequelize').Op.gt]: new Date() }
            },
            order: [['endDate', 'DESC']]
        });
        const isPremium = (user.role === 'admin') || (!!activeSub);

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
                'studyPlan'
            ]
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        const activeSub = await require('../models').Subscription.findOne({
            where: {
                userId: user.id,
                status: 'active',
                endDate: { [require('sequelize').Op.gt]: new Date() }
            },
            order: [['endDate', 'DESC']]
        });
        const isPremium = (user.role === 'admin') || (!!activeSub);

        // Clone user data to add isPremium
        const userData = user.get({ plain: true });
        userData.isPremium = !!isPremium;
        userData.hasSpecialties = Array.isArray(userData.specialties) && userData.specialties.length > 0;
        userData.hasStudyPlan = !!userData.studyPlan;

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

// @desc    Forgot Password - Send 6-digit OTP
// @route   POST /api/v1/auth/forgot-password
// @access  Public
exports.forgotPassword = async (req, res, next) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يرجى إدخال البريد الإلكتروني.', 'Please provide an email address.') 
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const user = await User.findOne({ where: { email: normalizedEmail } });

        // If user not found, notify immediately
        if (!user) {
            return res.status(404).json({ 
                success: false, 
                code: 'USER_NOT_FOUND',
                message: getMsg(req, 'هذا البريد الإلكتروني غير مسجل في المنصة. يرجى التأكد من البريد أو إنشاء حساب جديد.', 'This email is not registered on the platform. Please check the email or create a new account.') 
            });
        }

        // Generate 6-digit numeric OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Hash OTP and store in resetPasswordToken
        const resetPasswordToken = crypto.createHash('sha256').update(otp).digest('hex');

        // Set expiry to 15 minutes
        const resetPasswordExpires = Date.now() + 15 * 60 * 1000;

        await user.update({ resetPasswordToken, resetPasswordExpires });

        // Attempt to send email
        try {
            await sendEmail({
                email: user.email,
                subject: 'رمز التحقق لتغيير كلمة المرور - SDLE | Password Change Code',
                message: `سعادة الدكتور، رمز التحقق الخاص بكم لتغيير كلمة المرور في تطبيق SDLE هو: ${otp} (صالح لمدة 15 دقيقة).`,
                otp: otp
            });
        } catch (err) {
            console.warn('⚠️ Email send failed. OTP:', otp, err.message);
        }

        const responseData = { 
            message: getMsg(req, 'تم إرسال رمز التحقق إلى بريدك الإلكتروني بنجاح.', 'Verification code has been sent to your email successfully.') 
        };

        // In development or if explicitly enabled, return OTP for easy testing
        if (process.env.NODE_ENV === 'development') {
            responseData.otp = otp;
        }

        res.status(200).json({ success: true, data: responseData });
    } catch (error) {
        next(error);
    }
};

// @desc    Reset Password with 6-digit OTP
// @route   POST /api/v1/auth/reset-password-otp
// @access  Public
exports.resetPasswordWithOtp = async (req, res, next) => {
    try {
        const { email, otp, password } = req.body;

        if (!email || !otp || !password) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يرجى إدخال البريد الإلكتروني ورمز التحقق وكلمة المرور الجديدة', 'Please provide email, verification code, and new password.') 
            });
        }

        if (password.length < 8) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'يجب أن تتكون كلمة المرور من 8 خانات على الأقل.', 'Password must be at least 8 characters long.') 
            });
        }

        if (!/[A-Z]/.test(password)) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل (A-Z).', 'Password must contain at least one uppercase letter (A-Z).')
            });
        }

        if (!/[0-9]/.test(password)) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل (0-9).', 'Password must contain at least one number (0-9).')
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const hashedOtp = crypto.createHash('sha256').update(String(otp).trim()).digest('hex');

        const { Op } = require('sequelize');
        const user = await User.findOne({
            where: {
                email: normalizedEmail,
                resetPasswordToken: hashedOtp,
                resetPasswordExpires: { [Op.gt]: Date.now() }
            }
        });

        if (!user) {
            return res.status(400).json({ 
                success: false, 
                code: 'INVALID_OTP',
                message: getMsg(req, 'رمز التحقق غير صحيح أو انتهت صلاحيته', 'Invalid or expired verification code.') 
            });
        }

        // Check if new password is same as current password
        const isSamePassword = await user.matchPassword(password);
        if (isSamePassword) {
            return res.status(400).json({
                success: false,
                code: 'SAME_AS_OLD_PASSWORD',
                message: getMsg(req, 'لا يمكن استخدام كلمة المرور السابقة. يرجى اختيار كلمة مرور جديدة ومختلفة لضمان أمان حسابكم الطبي.', 'Cannot reuse the previous password. Please choose a new and different password.')
            });
        }

        // Set new password (model hook will hash with bcrypt)
        user.password = password;
        user.resetPasswordToken = null;
        user.resetPasswordExpires = null;
        await user.save();

        res.status(200).json({
            success: true,
            message: getMsg(req, 'تم تحديث كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول.', 'Password updated successfully. You can now log in.')
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Reset Password via URL Token (Legacy / Web fallback)
// @route   PUT /api/v1/auth/reset-password/:resettoken
// @access  Public
exports.resetPassword = async (req, res, next) => {
    try {
        // If request body contains otp and email, delegate to OTP logic
        if (req.body.otp && req.body.email) {
            return exports.resetPasswordWithOtp(req, res, next);
        }

        const token = req.params.resettoken || req.body.token;
        if (!token) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'الرمز غير صحيح أو مفقود', 'Invalid or missing token') 
            });
        }

        const password = req.body.password;
        if (!password || password.length < 8) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'يجب أن تتكون كلمة المرور من 8 خانات على الأقل.', 'Password must be at least 8 characters long.')
            });
        }

        // Get hashed token
        const resetPasswordToken = crypto.createHash('sha256').update(token).digest('hex');

        const user = await User.findOne({
            where: {
                resetPasswordToken,
                resetPasswordExpires: { [require('sequelize').Op.gt]: Date.now() }
            }
        });

        if (!user) {
            return res.status(400).json({ 
                success: false, 
                message: getMsg(req, 'الرمز غير صحيح أو انتهت صلاحيته', 'Invalid or expired token') 
            });
        }

        // Check if new password is same as old
        const isSame = await user.matchPassword(password);
        if (isSame) {
            return res.status(400).json({
                success: false,
                code: 'SAME_AS_OLD_PASSWORD',
                message: getMsg(req, 'لا يمكن استخدام كلمة المرور السابقة. يرجى اختيار كلمة مرور جديدة ومختلفة.', 'Cannot reuse the previous password. Please choose a new and different password.')
            });
        }

        // Set new password
        user.password = password;
        user.resetPasswordToken = null;
        user.resetPasswordExpires = null;
        await user.save();

        res.status(200).json({
            success: true,
            message: getMsg(req, 'تم تحديث كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول.', 'Password updated successfully. You can now log in.')
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Verify Email with 6-digit OTP
// @route   POST /api/v1/auth/verify-email
// @access  Public
exports.verifyEmail = async (req, res, next) => {
    try {
        const { email, otp } = req.body;

        if (!email || !otp) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'يرجى إدخال البريد الإلكتروني ورمز التحقق', 'Please enter email and verification code.')
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const hashedOtp = crypto.createHash('sha256').update(String(otp).trim()).digest('hex');

        const { Op } = require('sequelize');
        const user = await User.findOne({
            where: {
                email: normalizedEmail,
                verificationToken: hashedOtp,
                resetPasswordExpires: { [Op.gt]: Date.now() }
            },
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
            return res.status(400).json({
                success: false,
                code: 'INVALID_OTP',
                message: getMsg(req, 'رمز التحقق غير صحيح أو انتهت صلاحيته', 'Invalid or expired verification code.')
            });
        }

        user.isVerified = true;
        user.verificationToken = null;
        user.resetPasswordExpires = null;
        await user.save();

        const accessToken = generateAccessToken(user.id);
        const refreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        const activeSubscription = user.subscriptions && user.subscriptions.length > 0 ? user.subscriptions[0] : null;
        const isPremium = activeSubscription && new Date() <= activeSubscription.endDate;

        res.status(200).json({
            success: true,
            message: getMsg(req, 'تم تفعيل الحساب الطبي بنجاح!', 'Medical account activated successfully!'),
            data: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                isVerified: true,
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

// @desc    Resend Verification OTP
// @route   POST /api/v1/auth/resend-verification
// @access  Public
exports.resendVerificationCode = async (req, res, next) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'يرجى إدخال البريد الإلكتروني', 'Please provide an email address.')
            });
        }

        const normalizedEmail = email.trim().toLowerCase();
        const user = await User.findOne({ where: { email: normalizedEmail } });

        if (!user) {
            return res.status(404).json({
                success: false,
                code: 'USER_NOT_FOUND',
                message: getMsg(req, 'هذا البريد الإلكتروني غير مسجل في المنصة.', 'This email is not registered on the platform.')
            });
        }

        if (user.isVerified) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'هذا الحساب مفعل بالفعل، يمكنك تسجيل الدخول مباشرة.', 'This account is already verified. You can log in directly.')
            });
        }

        // Generate new 6-digit OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const verificationToken = crypto.createHash('sha256').update(otp).digest('hex');
        const resetPasswordExpires = Date.now() + 15 * 60 * 1000;

        await user.update({ verificationToken, resetPasswordExpires });

        try {
            await sendEmail({
                email: user.email,
                subject: 'رمز تفعيل حسابكم الطبي - SDLE | Account Activation Code',
                message: `سعادة الدكتور، رمز التحقق الجديد الخاص بكم لتفعيل حسابكم الطبي في منصة SDLE هو: ${otp} (صالح لمدة 15 دقيقة).`,
                otp: otp,
                isRegistration: true
            });
        } catch (err) {
            console.warn('⚠️ Verification email resend failed. OTP:', otp, err.message);
        }

        const responseData = {
            message: getMsg(req, 'تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني بنجاح.', 'A new verification code has been sent to your email successfully.')
        };

        if (process.env.NODE_ENV === 'development') {
            responseData.otp = otp;
        }

        res.status(200).json({
            success: true,
            data: responseData
        });
    } catch (error) {
        next(error);
    }
};

// Helper to format auth success response
const sendAuthSuccessResponse = async (user, req, res) => {
    const freshUser = await User.findByPk(user.id, {
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

    const activeSubscription = freshUser.subscriptions && freshUser.subscriptions.length > 0 ? freshUser.subscriptions[0] : null;
    const isPremium = activeSubscription && new Date() <= activeSubscription.endDate;

    const accessToken = generateAccessToken(freshUser.id);
    const refreshToken = await RefreshToken.createToken(freshUser, req.ip, req.headers['user-agent']);

    return res.status(200).json({
        success: true,
        data: {
            id: freshUser.id,
            fullName: freshUser.fullName,
            email: freshUser.email,
            role: freshUser.role,
            hasSpecialties: freshUser.specialties && freshUser.specialties.length > 0,
            hasStudyPlan: !!freshUser.studyPlan,
            isPremium: !!isPremium,
            accessToken,
            refreshToken
        }
    });
};

exports.googleAuth = async (req, res, next) => {
    try {
        let { idToken, email, fullName, googleId, avatar } = req.body;

        if (idToken) {
            try {
                const axios = require('axios');
                const googleRes = await axios.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
                if (googleRes.data) {
                    email = googleRes.data.email || email;
                    fullName = googleRes.data.name || fullName;
                    googleId = googleRes.data.sub || googleId;
                    avatar = googleRes.data.picture || avatar;
                }
            } catch (verifyErr) {
                try {
                    const decoded = jwt.decode(idToken);
                    if (decoded) {
                        email = decoded.email || email;
                        fullName = decoded.name || fullName;
                        googleId = decoded.sub || googleId;
                        avatar = decoded.picture || avatar;
                    }
                } catch (decodeErr) {
                    console.warn('Google idToken decode error:', decodeErr.message);
                }
            }
        }

        if (!email && !googleId) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'فشل التحقق من حساب جوجل. يرجى إعادة المحاولة.', 'Google authentication failed. Please try again.')
            });
        }

        const normalizedEmail = email ? email.trim().toLowerCase() : null;

        let user = null;
        if (googleId) {
            user = await User.findOne({ where: { googleId } });
        }
        if (!user && normalizedEmail) {
            user = await User.findOne({ where: { email: normalizedEmail } });
        }

        if (user) {
            const updates = {};
            if (!user.googleId && googleId) updates.googleId = googleId;
            if (!user.isVerified) updates.isVerified = true;
            if (!user.avatar && avatar) updates.avatar = avatar;
            if (Object.keys(updates).length > 0) {
                await user.update(updates);
            }
        } else {
            let newReferralCode;
            let isUnique = false;
            while (!isUnique) {
                newReferralCode = crypto.randomBytes(4).toString('hex').toUpperCase();
                const exists = await User.findOne({ where: { referralCode: newReferralCode } });
                if (!exists) isUnique = true;
            }

            user = await User.create({
                fullName: fullName || 'Google User',
                email: normalizedEmail || `google_${googleId}@sdle-user.com`,
                password: crypto.randomBytes(24).toString('hex'),
                googleId: googleId || null,
                authProvider: 'google',
                isVerified: true,
                avatar: avatar || null,
                referralCode: newReferralCode
            });
        }

        return await sendAuthSuccessResponse(user, req, res);
    } catch (error) {
        next(error);
    }
};

exports.appleAuth = async (req, res, next) => {
    try {
        let { identityToken, appleId, email, fullName } = req.body;

        if (identityToken) {
            try {
                const decoded = jwt.decode(identityToken);
                if (decoded) {
                    appleId = decoded.sub || appleId;
                    if (!email && decoded.email) email = decoded.email;
                }
            } catch (decodeErr) {
                console.warn('Apple identityToken decode error:', decodeErr.message);
            }
        }

        if (!appleId && !email) {
            return res.status(400).json({
                success: false,
                message: getMsg(req, 'فشل التحقق من حساب آبل. يرجى إعادة المحاولة.', 'Apple authentication failed. Please try again.')
            });
        }

        const normalizedEmail = email ? email.trim().toLowerCase() : null;

        let user = null;
        if (appleId) {
            user = await User.findOne({ where: { appleId } });
        }
        if (!user && normalizedEmail) {
            user = await User.findOne({ where: { email: normalizedEmail } });
        }

        if (user) {
            const updates = {};
            if (!user.appleId && appleId) updates.appleId = appleId;
            if (!user.isVerified) updates.isVerified = true;
            if (fullName && (!user.fullName || user.fullName === 'Apple User')) {
                updates.fullName = fullName;
            }
            if (Object.keys(updates).length > 0) {
                await user.update(updates);
            }
        } else {
            let newReferralCode;
            let isUnique = false;
            while (!isUnique) {
                newReferralCode = crypto.randomBytes(4).toString('hex').toUpperCase();
                const exists = await User.findOne({ where: { referralCode: newReferralCode } });
                if (!exists) isUnique = true;
            }

            user = await User.create({
                fullName: fullName || 'Apple User',
                email: normalizedEmail || `apple_${appleId}@sdle-user.com`,
                password: crypto.randomBytes(24).toString('hex'),
                appleId: appleId || null,
                authProvider: 'apple',
                isVerified: true,
                referralCode: newReferralCode
            });
        }

        return await sendAuthSuccessResponse(user, req, res);
    } catch (error) {
        next(error);
    }
};
