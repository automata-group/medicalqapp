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

// @desc    Get Public App Settings (e.g. showQuestionCount)
// @route   GET /api/v1/user/config
// @access  Public
exports.getPublicSettings = async (req, res, next) => {
    try {
        const { AppSetting } = require('../models');
        const setting = await AppSetting.findOne({ where: { key: 'system_settings' } });
        const values = setting ? setting.value : { showQuestionCount: false };
        res.status(200).json({
            success: true,
            data: {
                showQuestionCount: values.showQuestionCount === true || values.showQuestionCount === 'true'
            }
        });
    } catch (error) {
        next(error);
    }
};

