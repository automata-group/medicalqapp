const { User, AdminActivityLog } = require('../../models');

// @desc    Get all admins
// @route   GET /api/v1/admin/admins
// @access  Private (Admin)
exports.getAdmins = async (req, res, next) => {
    try {
        const admins = await User.findAll({
            where: { role: 'admin' },
            attributes: { exclude: ['password'] }
        });

        res.status(200).json({ success: true, count: admins.length, data: admins });
    } catch (error) {
        next(error);
    }
};

// @desc    Create new admin
// @route   POST /api/v1/admin/admins
// @access  Private (Admin)
exports.createAdmin = async (req, res, next) => {
    try {
        const { fullName, email, password } = req.body;

        const userExists = await User.findOne({ where: { email } });
        if (userExists) {
            return res.status(400).json({ success: false, message: 'User already exists' });
        }

        const user = await User.create({
            fullName,
            email,
            password,
            role: 'admin'
        });

        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'CREATE_ADMIN',
            targetResource: 'User',
            targetId: user.id,
            details: `Created admin ${email}`,
            ipAddress: req.ip
        });

        res.status(201).json({ success: true, data: user });
    } catch (error) {
        next(error);
    }
};

// @desc    Update admin
// @route   PUT /api/v1/admin/admins/:id
// @access  Private (Admin)
exports.updateAdmin = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id);

        if (!user || user.role !== 'admin') {
            return res.status(404).json({ success: false, message: 'Admin not found' });
        }

        // Prevent deleting oneself? No, update logic.
        const { fullName, email, password } = req.body;

        user.fullName = fullName || user.fullName;
        user.email = email || user.email;
        if (password) {
            user.password = password;
        }

        await user.save();

        res.status(200).json({ success: true, data: user });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete admin
// @route   DELETE /api/v1/admin/admins/:id
// @access  Private (Admin)
exports.deleteAdmin = async (req, res, next) => {
    try {
        const user = await User.findByPk(req.params.id);

        if (!user || user.role !== 'admin') {
            return res.status(404).json({ success: false, message: 'Admin not found' });
        }

        // Prevent self-delete
        if (user.id === req.user.id) {
            return res.status(400).json({ success: false, message: 'Cannot delete yourself' });
        }

        await user.destroy();

        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'DELETE_ADMIN',
            targetResource: 'User',
            targetId: user.id,
            details: `Deleted admin ${user.email}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        next(error);
    }
};

// @desc    Get system activity log
// @route   GET /api/v1/admin/activity-log
// @access  Private (Admin)
exports.getActivityLog = async (req, res, next) => {
    try {
        const { page = 1, limit = 20, adminId } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = {};
        if (adminId) whereClause.adminId = adminId;

        const logs = await AdminActivityLog.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit),
            offset: parseInt(offset),
            include: [{ model: User, attributes: ['fullName', 'email'] }], // As log has adminId foreign key to User
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count: logs.count,
            totalPages: Math.ceil(logs.count / limit),
            currentPage: parseInt(page),
            data: logs.rows
        });
    } catch (error) {
        next(error);
    }
};
