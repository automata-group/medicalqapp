const { QuestionContribution, Specialty, Topic, ContributionCluster } = require('../models');
const { detectDuplicateAndCluster } = require('../services/duplicateDetectionService');

/**
 * Submit an exam question recall contribution (Mobile App)
 */
exports.createContribution = async (req, res) => {
    try {
        const userId = req.user.id;
        const {
            specialtyId,
            topicId,
            questionText,
            options,
            userAnswer,
            notes,
            examDate,
            confidenceLevel
        } = req.body;

        if (!questionText || questionText.trim().length < 5) {
            return res.status(400).json({
                success: false,
                message: 'يرجى كتابة نص السؤال أو ما تتذكره منه'
            });
        }

        if (!specialtyId) {
            return res.status(400).json({
                success: false,
                message: 'يرجى اختيار التخصص'
            });
        }

        // Parse options if sent as string
        let parsedOptions = [];
        if (options) {
            if (typeof options === 'string') {
                try {
                    parsedOptions = JSON.parse(options);
                } catch (e) {
                    parsedOptions = [];
                }
            } else if (Array.isArray(options)) {
                parsedOptions = options;
            }
        }

        // Image file if uploaded
        let imageUrl = null;
        if (req.file) {
            imageUrl = `/uploads/${req.file.filename}`;
        }

        // Valid confidence levels
        const validConfidence = ['high', 'medium', 'low'];
        const normalizedConfidence = validConfidence.includes(confidenceLevel) ? confidenceLevel : 'high';

        // Create the contribution record
        const contribution = await QuestionContribution.create({
            userId,
            specialtyId: parseInt(specialtyId, 10),
            topicId: topicId ? parseInt(topicId, 10) : null,
            questionText: questionText.trim(),
            options: parsedOptions,
            userAnswer: userAnswer || null,
            notes: notes ? notes.trim() : null,
            examDate: examDate || null,
            confidenceLevel: normalizedConfidence,
            imageUrl,
            status: 'pending'
        });

        // Run duplicate detection & clustering in background / inline
        try {
            const clusterResult = await detectDuplicateAndCluster(contribution);
            if (clusterResult && clusterResult.clusterId) {
                await contribution.update({ clusterId: clusterResult.clusterId });
            }
        } catch (clusterErr) {
            console.error('Error during cluster check:', clusterErr);
        }

        return res.status(201).json({
            success: true,
            message: 'تم استلام مساهمتك بنجاح 🎉 شكرًا لمساعدتك في تطوير SDLE. سيقوم فريقنا بمراجعة السؤال والتحقق منه قبل إضافته إلى بنك الأسئلة.',
            data: {
                id: contribution.id,
                status: contribution.status,
                createdAt: contribution.createdAt
            }
        });
    } catch (error) {
        console.error('Create contribution error:', error);
        return res.status(500).json({
            success: false,
            message: 'حدث خطأ أثناء إرسال المساهمة. يرجى المحاولة مرة أخرى.',
            error: error.message
        });
    }
};

/**
 * Get current user's submitted contributions
 */
exports.getMyContributions = async (req, res) => {
    try {
        const userId = req.user.id;
        const contributions = await QuestionContribution.findAll({
            where: { userId },
            include: [
                {
                    model: Specialty,
                    as: 'specialty',
                    attributes: ['id', 'name']
                },
                {
                    model: Topic,
                    as: 'topic',
                    attributes: ['id', 'name']
                },
                {
                    model: ContributionCluster,
                    as: 'cluster',
                    attributes: ['id', 'title', 'totalReports']
                }
            ],
            order: [['createdAt', 'DESC']]
        });

        return res.json({
            success: true,
            data: contributions
        });
    } catch (error) {
        console.error('Get my contributions error:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve your contributions',
            error: error.message
        });
    }
};
