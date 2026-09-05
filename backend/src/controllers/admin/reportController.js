const {
    QuestionReport,
    User,
    Question,
    Specialty,
    Topic,
    Option,
    Explanation,
    AdminActivityLog
} = require('../../models');
const { Op } = require('sequelize');

// @desc    Get all reports with filtering, pagination, and KPI metrics
// @route   GET /api/v1/admin/reports
// @access  Private (Admin)
exports.getReports = async (req, res, next) => {
    try {
        const {
            page = 1,
            limit = 15,
            status,
            reason,
            search
        } = req.query;

        const offset = (parseInt(page, 10) - 1) * parseInt(limit, 10);
        const whereClause = {};

        if (status && status !== 'all') {
            whereClause.status = status;
        }

        if (reason && reason !== 'all') {
            whereClause.reason = reason;
        }

        const queryTerm = (search || '').trim();
        if (queryTerm) {
            whereClause[Op.or] = [
                { description: { [Op.like]: `%${queryTerm}%` } },
                { adminNotes: { [Op.like]: `%${queryTerm}%` } }
            ];
        }

        const { count, rows } = await QuestionReport.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit, 10),
            offset,
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'fullName', ['fullName', 'name'], 'email']
                },
                {
                    model: Question,
                    as: 'question',
                    attributes: ['id', 'text', 'difficulty', 'specialtyId', 'topicId'],
                    include: [
                        { model: Specialty, as: 'specialty', attributes: ['id', 'name'] },
                        { model: Topic, as: 'topic', attributes: ['id', 'name'] },
                        { model: Option, as: 'options', attributes: ['id', 'order', 'text', 'isCorrect'] },
                        { model: Explanation, as: 'explanation', attributes: ['id', 'text', 'references'] }
                    ]
                }
            ],
            order: [['createdAt', 'DESC']]
        });

        // KPI Summary Counters
        const [totalAll, pendingCount, reviewingCount, resolvedCount, dismissedCount] = await Promise.all([
            QuestionReport.count(),
            QuestionReport.count({ where: { status: 'pending' } }),
            QuestionReport.count({ where: { status: 'reviewing' } }),
            QuestionReport.count({ where: { status: 'resolved' } }),
            QuestionReport.count({ where: { status: 'dismissed' } })
        ]);

        return res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / parseInt(limit, 10)),
            currentPage: parseInt(page, 10),
            stats: {
                total: totalAll,
                pending: pendingCount,
                reviewing: reviewingCount,
                resolved: resolvedCount,
                dismissed: dismissedCount
            },
            data: rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single report with full question context
// @route   GET /api/v1/admin/reports/:id
// @access  Private (Admin)
exports.getReport = async (req, res, next) => {
    try {
        const report = await QuestionReport.findByPk(req.params.id, {
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'fullName', ['fullName', 'name'], 'email', 'phone']
                },
                {
                    model: Question,
                    as: 'question',
                    include: [
                        { model: Specialty, as: 'specialty', attributes: ['id', 'name'] },
                        { model: Topic, as: 'topic', attributes: ['id', 'name'] },
                        { model: Option, as: 'options', attributes: ['id', 'order', 'text', 'isCorrect'] },
                        { model: Explanation, as: 'explanation', attributes: ['id', 'text', 'whyWrong', 'references'] }
                    ]
                }
            ]
        });

        if (!report) {
            return res.status(404).json({ success: false, message: 'Report not found' });
        }

        return res.status(200).json({ success: true, data: report });
    } catch (error) {
        next(error);
    }
};

// @desc    Update report status and admin notes
// @route   PUT /api/v1/admin/reports/:id/status or /api/v1/admin/reports/:id
// @access  Private (Admin)
exports.updateReportStatus = async (req, res, next) => {
    try {
        const { status, adminNotes, adminComment } = req.body;

        const report = await QuestionReport.findByPk(req.params.id, {
            include: [
                {
                    model: User,
                    as: 'user',
                    attributes: ['id', 'fullName', ['fullName', 'name'], 'email']
                },
                {
                    model: Question,
                    as: 'question',
                    include: [
                        { model: Specialty, as: 'specialty', attributes: ['id', 'name'] },
                        { model: Topic, as: 'topic', attributes: ['id', 'name'] },
                        { model: Option, as: 'options', attributes: ['id', 'order', 'text', 'isCorrect'] }
                    ]
                }
            ]
        });

        if (!report) {
            return res.status(404).json({ success: false, message: 'Report not found' });
        }

        const validStatuses = ['pending', 'reviewing', 'resolved', 'dismissed'];
        if (status && !validStatuses.includes(status)) {
            return res.status(400).json({ success: false, message: 'Invalid status' });
        }

        if (status) report.status = status;
        const note = adminNotes !== undefined ? adminNotes : adminComment;
        if (note !== undefined) report.adminNotes = note;

        await report.save();

        // Log admin activity
        if (req.user) {
            await AdminActivityLog.create({
                userId: req.user.id,
                action: 'UPDATE_REPORT_STATUS',
                targetResource: `Report:${report.id}`,
                details: JSON.stringify({ reportId: report.id, status: report.status, adminNotes: report.adminNotes }),
                ipAddress: req.ip
            }).catch(e => console.error('Admin log error:', e));
        }

        return res.status(200).json({
            success: true,
            message: 'Report updated successfully',
            data: report
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get report statistics
// @route   GET /api/v1/admin/reports/statistics
// @access  Private (Admin)
exports.getReportStats = async (req, res, next) => {
    try {
        const [totalAll, pendingCount, reviewingCount, resolvedCount, dismissedCount] = await Promise.all([
            QuestionReport.count(),
            QuestionReport.count({ where: { status: 'pending' } }),
            QuestionReport.count({ where: { status: 'reviewing' } }),
            QuestionReport.count({ where: { status: 'resolved' } }),
            QuestionReport.count({ where: { status: 'dismissed' } })
        ]);

        return res.status(200).json({
            success: true,
            data: {
                total: totalAll,
                pending: pendingCount,
                reviewing: reviewingCount,
                resolved: resolvedCount,
                dismissed: dismissedCount
            }
        });
    } catch (error) {
        next(error);
    }
};
