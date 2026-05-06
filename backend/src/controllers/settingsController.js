const { User } = require('../models');
const bcrypt = require('bcryptjs');

// @desc    Update user profile
// @route   PUT /api/v1/user/profile
// @access  Private
exports.updateProfile = async (req, res, next) => {
    try {
        const { fullName, phone, avatar } = req.body;
        const user = await User.findByPk(req.user.id);

        if (fullName) user.fullName = fullName;
        if (phone) user.phone = phone;
        if (avatar) user.avatar = avatar;

        await user.save();

        res.status(200).json({
            success: true,
            data: {
                id: user.id,
                fullName: user.fullName,
                email: user.email,
                phone: user.phone,
                avatar: user.avatar
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Change password
// @route   PUT /api/v1/user/change-password
// @access  Private
exports.changePassword = async (req, res, next) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const user = await User.findByPk(req.user.id);

        if (!(await user.matchPassword(currentPassword))) {
            return res.status(401).json({ success: false, message: 'Incorrect current password' });
        }

        user.password = newPassword; // Hook will hash it
        await user.save();

        res.status(200).json({ success: true, message: 'Password updated successfully' });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete account
// @route   DELETE /api/v1/user/account
// @access  Private
exports.deleteAccount = async (req, res, next) => {
    try {
        // Soft delete or anonymize? Logic depends on policy.
        // For now, let's just deactivate.
        // user.isActive = false; await user.save(); 
        // Or actual delete:
        await User.destroy({ where: { id: req.user.id } }); // This destroys related data if CASCADE is set

        res.status(200).json({ success: true, message: 'Account deleted' });
    } catch (error) {
        next(error);
    }
};

// @desc    Get App Version
// @route   GET /api/v1/user/version
// @access  Public (or Private) -> user app usually public or protected. Todo said /app/version.
exports.getAppVersion = async (req, res, next) => {
    try {
        res.status(200).json({
            success: true,
            data: {
                version: process.env.npm_package_version || '1.0.0',
                minSupportedVersion: '1.0.0'
            }
        });
    } catch (error) {
        next(error);
    }
};
