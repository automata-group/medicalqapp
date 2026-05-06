const { QuestionReport, User, Question, AdminActivityLog } = require('../../models');

// @desc    Get all reports
// @route   GET /api/v1/admin/reports
// @access  Private (Admin)
exports.getReports = async (req, res, next) => {
    try {
        const { page = 1, limit = 10, status } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = {};
        if (status) whereClause.status = status;

        const { count, rows } = await QuestionReport.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit),
            offset: parseInt(offset),
            include: [
                { model: User, as: 'user', attributes: ['id', 'fullName', 'email'] },
                { model: Question, as: 'question', attributes: ['id', 'text'] }
            ],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            data: rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single report
// @route   GET /api/v1/admin/reports/:id
// @access  Private (Admin)
exports.getReport = async (req, res, next) => {
    try {
        const report = await QuestionReport.findByPk(req.params.id, {
            include: [
                { model: User, as: 'user', attributes: ['id', 'fullName', 'email'] },
                { model: Question, as: 'question' }
            ]
        });

        if (!report) {
            return res.status(404).json({ success: false, message: 'Report not found' });
        }

        res.status(200).json({ success: true, data: report });
    } catch (error) {
        next(error);
    }
};

// @desc    Update report status
// @route   PUT /api/v1/admin/reports/:id/status
// @access  Private (Admin)
exports.updateReportStatus = async (req, res, next) => {
    try {
        const { status, adminComment } = req.body; // status: 'pending', 'reviewed', 'resolved', 'dismissed'

        const report = await QuestionReport.findByPk(req.params.id);

        if (!report) {
            return res.status(404).json({ success: false, message: 'Report not found' });
        }

        report.status = status || report.status;
        if (adminComment) report.adminComment = adminComment; // If model supports it, assuming flexible or simple update
        // Check model: it likely only has 'status', 'resolution' or similar. 
        // Let's assume standard update.

        await report.save();

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'UPDATE_REPORT_STATUS',
            targetResource: `Report:${report.id}`,
            details: `Status changed to ${status}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, data: report });
    } catch (error) {
        next(error);
    }
};

// @desc    Get report statistics
// @route   GET /api/v1/admin/reports/statistics
// @access  Private (Admin)
exports.getReportStats = async (req, res, next) => {
    try {
        const stats = await QuestionReport.findAll({
            attributes: ['status', [require('sequelize').fn('COUNT', 'id'), 'count']],
            group: ['status']
        });

        res.status(200).json({ success: true, data: stats });
    } catch (error) {
        next(error);
    }
};
