const {
    QuestionContribution,
    ContributionCluster,
    Specialty,
    Topic,
    User,
    Question,
    Option,
    Explanation,
    AdminActivityLog,
    sequelize
} = require('../../models');
const { Op } = require('sequelize');
const aiService = require('../../services/aiService');

/**
 * Get all question contributions with filtering, sorting, and clustering metrics
 */
exports.getAllContributions = async (req, res) => {
    try {
        const {
            page = 1,
            limit = 15,
            status,
            specialtyId,
            search,
            sortBy = 'newest',
            clusterOnly = 'false'
        } = req.query;

        const offset = (parseInt(page, 10) - 1) * parseInt(limit, 10);
        const whereClause = {};

        if (status && status !== 'all') {
            whereClause.status = status;
        }

        if (specialtyId && specialtyId !== 'all') {
            whereClause.specialtyId = parseInt(specialtyId, 10);
        }

        const queryTerm = (search || '').trim();
        if (queryTerm) {
            whereClause[Op.or] = [
                { questionText: { [Op.like]: `%${queryTerm}%` } },
                { notes: { [Op.like]: `%${queryTerm}%` } }
            ];
        }

        if (clusterOnly === 'true') {
            whereClause.clusterId = { [Op.ne]: null };
        }

        // Sorting logic
        let orderClause = [['createdAt', 'DESC']];
        if (sortBy === 'exam_date') {
            orderClause = [['examDate', 'DESC'], ['createdAt', 'DESC']];
        } else if (sortBy === 'priority') {
            orderClause = [['priority', 'DESC'], ['createdAt', 'DESC']];
        }

        const { count, rows } = await QuestionContribution.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit, 10),
            offset,
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
                    model: User,
                    as: 'user',
                    attributes: ['id', 'fullName', ['fullName', 'name'], 'email']
                },
                {
                    model: ContributionCluster,
                    as: 'cluster',
                    attributes: ['id', 'title', 'totalReports', 'status']
                }
            ],
            order: orderClause
        });

        // If sorting by most_repeated, we can sort the rows based on cluster.totalReports
        if (sortBy === 'most_repeated') {
            rows.sort((a, b) => {
                const repA = a.cluster ? a.cluster.totalReports : 1;
                const repB = b.cluster ? b.cluster.totalReports : 1;
                return repB - repA;
            });
        }

        // KPI Summary Counters
        const [totalAll, pendingCount, reviewingCount, approvedCount, clustersCount] = await Promise.all([
            QuestionContribution.count(),
            QuestionContribution.count({ where: { status: 'pending' } }),
            QuestionContribution.count({ where: { status: 'reviewing' } }),
            QuestionContribution.count({ where: { status: 'approved' } }),
            ContributionCluster.count()
        ]);

        return res.json({
            success: true,
            count,
            totalPages: Math.ceil(count / parseInt(limit, 10)),
            currentPage: parseInt(page, 10),
            stats: {
                total: totalAll,
                pending: pendingCount,
                reviewing: reviewingCount,
                approved: approvedCount,
                clusters: clustersCount
            },
            data: rows
        });
    } catch (error) {
        console.error('Admin getAllContributions error:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve contributions',
            error: error.message
        });
    }
};

/**
 * Get single contribution with its cluster and sibling reports for side-by-side comparison
 */
exports.getContributionById = async (req, res) => {
    try {
        const { id } = req.params;

        const contribution = await QuestionContribution.findByPk(id, {
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
                    model: User,
                    as: 'user',
                    attributes: ['id', 'fullName', ['fullName', 'name'], 'email']
                },
                {
                    model: ContributionCluster,
                    as: 'cluster',
                    include: [
                        {
                            model: QuestionContribution,
                            as: 'contributions',
                            where: { id: { [Op.ne]: id } },
                            required: false,
                            include: [
                                {
                                    model: User,
                                    as: 'user',
                                    attributes: ['id', 'fullName', ['fullName', 'name']]
                                }
                            ]
                        }
                    ]
                }
            ]
        });

        if (!contribution) {
            return res.status(404).json({
                success: false,
                message: 'Contribution not found'
            });
        }

        return res.json({
            success: true,
            data: contribution
        });
    } catch (error) {
        console.error('Admin getContributionById error:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to retrieve contribution details',
            error: error.message
        });
    }
};

/**
 * Update contribution status and admin notes
 */
exports.updateContributionStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, adminNotes, priority } = req.body;

        const contribution = await QuestionContribution.findByPk(id);
        if (!contribution) {
            return res.status(404).json({
                success: false,
                message: 'Contribution not found'
            });
        }

        const validStatuses = ['pending', 'reviewing', 'needs_info', 'approved', 'rejected', 'duplicate'];
        if (status && !validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid status'
            });
        }

        await contribution.update({
            ...(status && { status }),
            ...(adminNotes !== undefined && { adminNotes }),
            ...(priority && { priority }),
            reviewedBy: req.user ? req.user.id : null
        });

        // Log admin activity
        if (req.user) {
            await AdminActivityLog.create({
                userId: req.user.id,
                action: 'UPDATE_CONTRIBUTION_STATUS',
                details: JSON.stringify({ contributionId: id, status, priority })
            }).catch(e => console.error('Admin log error:', e));
        }

        return res.json({
            success: true,
            message: 'Contribution updated successfully',
            data: contribution
        });
    } catch (error) {
        console.error('Update status error:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to update contribution status',
            error: error.message
        });
    }
};

/**
 * One-Click Convert Contribution into an Official Question in the Bank
 */
exports.convertToOfficialQuestion = async (req, res) => {
    const t = await sequelize.transaction();
    try {
        const { id } = req.params;
        const {
            text,
            specialtyId,
            topicId,
            subTopic,
            difficulty = 'medium',
            options,
            correctOptionOrder, // 'A', 'B', 'C', 'D'
            generateAiExplanation = true,
            approveClusterSiblings = true
        } = req.body;

        const contribution = await QuestionContribution.findByPk(id, { transaction: t });
        if (!contribution) {
            await t.rollback();
            return res.status(404).json({
                success: false,
                message: 'Contribution not found'
            });
        }

        const finalQuestionText = text || contribution.questionText;
        const finalSpecialtyId = specialtyId || contribution.specialtyId;
        const finalTopicId = topicId || contribution.topicId;

        // 1. Create Question
        const newQuestion = await Question.create({
            text: finalQuestionText,
            specialtyId: finalSpecialtyId,
            topicId: finalTopicId || null,
            subTopic: subTopic || 'Exam Recall',
            difficulty: difficulty || 'medium',
            source: 'SDLE Exam Recall Contribution',
            isActive: true,
            verifiedByAI: generateAiExplanation
        }, { transaction: t });

        // 2. Create Options
        let parsedOptions = options;
        if (!parsedOptions || !parsedOptions.length) {
            parsedOptions = contribution.options || [];
        }

        const formattedOptions = [];
        for (let i = 0; i < parsedOptions.length; i++) {
            const opt = parsedOptions[i];
            const key = opt.key || String.fromCharCode(65 + i); // 'A', 'B', 'C', 'D'
            const isCorrect = correctOptionOrder ? (key === correctOptionOrder) : (opt.isCorrect || key === contribution.userAnswer);

            const createdOpt = await Option.create({
                questionId: newQuestion.id,
                order: key,
                text: opt.text || '',
                isCorrect: Boolean(isCorrect)
            }, { transaction: t });

            formattedOptions.push({
                order: key,
                text: opt.text || '',
                isCorrect: Boolean(isCorrect)
            });
        }

        // 3. Generate AI Explanation if enabled
        if (generateAiExplanation) {
            try {
                // Fetch specialty and topic names for rich prompt
                const specialty = await Specialty.findByPk(finalSpecialtyId);
                const topic = finalTopicId ? await Topic.findByPk(finalTopicId) : null;

                const aiResult = await aiService.generateStructuredExplanation(
                    finalQuestionText,
                    formattedOptions,
                    specialty ? specialty.name : 'Medical Science',
                    topic ? topic.name : 'General'
                );

                if (aiResult && aiResult.data) {
                    await Explanation.create({
                        questionId: newQuestion.id,
                        text: aiResult.data.explanation || aiResult.data.summary || 'Official clinical reasoning.',
                        whyWrong: aiResult.data.whyWrong || {},
                        references: aiResult.data.references || 'Saudi Medical Licensing Examination (SMLE/SDLE) Blueprint Standards',
                        aiGenerated: true
                    }, { transaction: t });
                }
            } catch (aiErr) {
                console.error('AI explanation generation failed during conversion:', aiErr);
                // Fallback explanation
                await Explanation.create({
                    questionId: newQuestion.id,
                    text: contribution.notes || 'Verified exam recall question from real licensing examination.',
                    whyWrong: {},
                    references: 'Saudi Commission for Health Specialties (SCFHS)',
                    aiGenerated: false
                }, { transaction: t });
            }
        }

        // 4. Mark contribution as approved and link converted question
        await contribution.update({
            status: 'approved',
            convertedQuestionId: newQuestion.id,
            reviewedBy: req.user ? req.user.id : null
        }, { transaction: t });

        // 5. If part of a cluster and requested, mark siblings or update cluster status
        if (contribution.clusterId) {
            const cluster = await ContributionCluster.findByPk(contribution.clusterId, { transaction: t });
            if (cluster) {
                await cluster.update({
                    status: 'resolved',
                    createdQuestionId: newQuestion.id
                }, { transaction: t });

                if (approveClusterSiblings) {
                    await QuestionContribution.update({
                        status: 'approved',
                        convertedQuestionId: newQuestion.id
                    }, {
                        where: {
                            clusterId: contribution.clusterId,
                            id: { [Op.ne]: contribution.id }
                        },
                        transaction: t
                    });
                }
            }
        }

        await t.commit();

        return res.status(201).json({
            success: true,
            message: 'تم تحويل السؤال بنجاح إلى بنك الأسئلة المعتمد 🎉',
            data: {
                questionId: newQuestion.id,
                contributionId: contribution.id
            }
        });
    } catch (error) {
        await t.rollback();
        console.error('Convert to official question error:', error);
        return res.status(500).json({
            success: false,
            message: 'Failed to convert contribution to official question',
            error: error.message
        });
    }
};
