const jwt = require('jsonwebtoken');
const { User, RefreshToken, AdminActivityLog } = require('../../models');

// Helper
const generateAccessToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '15m'
    });
};

// @desc    Admin Login
// @route   POST /api/v1/admin/auth/login
// @access  Public
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ where: { email } });

        if (!user || !(await user.matchPassword(password))) {
            return res.status(401).json({ success: false, message: 'Invalid credentials' });
        }

        if (user.role !== 'admin') {
            return res.status(403).json({ success: false, message: 'Access denied. Admins only.' });
        }

        const accessToken = generateAccessToken(user.id);
        const refreshToken = await RefreshToken.createToken(user, req.ip, req.headers['user-agent']);

        // Log Activity
        await AdminActivityLog.create({
            adminId: user.id,
            action: 'LOGIN',
            ipAddress: req.ip,
            userAgent: req.headers['user-agent']
        });

        res.status(200).json({
            success: true,
            data: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                role: user.role,
                accessToken,
                refreshToken
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get Current Admin
// @route   GET /api/v1/admin/auth/me
// @access  Private (Admin)
exports.getMe = async (req, res, next) => {
    res.status(200).json({ success: true, data: req.user });
};
