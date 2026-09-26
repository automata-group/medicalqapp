const { Question, Option, Explanation, QuestionAttempt, Bookmark, Specialty, Topic, QuestionReport, QuestionStats, UserProgress } = require('../models');
const { Op, Sequelize } = require('sequelize');

// @desc    Get next practice question
// @route   GET /api/v1/questions/practice/next
// @access  Private
exports.getNextQuestion = async (req, res, next) => {
    try {
        const { specialtyId, topicId, mode, difficulty, subTopic, filter, id } = req.query;

        const whereClause = { isActive: true };

        let effectiveSpecialtyId = specialtyId ? parseInt(specialtyId) : null;

        if (specialtyId) {
            whereClause.specialtyId = specialtyId;
        }

        if (topicId) {
            const topic = await Topic.findByPk(topicId, { attributes: ['id', 'specialtyId', 'isPremium'] });
            // ─── Block free users from premium topics ───────────────
            if (!req.isPremium && req.user.role !== 'admin' && topic && topic.isPremium) {
                return res.status(403).json({
                    success: false,
                    message: 'هذا الموضوع مخصص لمشتركي PRO فقط.',
                    code: 'PREMIUM_TOPIC_LOCKED'
                });
            }
            if (!effectiveSpecialtyId && topic && topic.specialtyId) {
                effectiveSpecialtyId = topic.specialtyId;
            }
            whereClause.topicId = topicId;
        } else if (subTopic) {
            // Find topic by name first to support migrated relational models
            const topic = await Topic.findOne({ where: { name: subTopic }, attributes: ['id', 'specialtyId', 'isPremium'] });
            if (topic) {
                // ─── Block free users from premium topics by name ─────
                if (!req.isPremium && req.user.role !== 'admin' && topic.isPremium) {
                    return res.status(403).json({
                        success: false,
                        message: 'هذا الموضوع مخصص لمشتركي PRO فقط.',
                        code: 'PREMIUM_TOPIC_LOCKED'
                    });
                }
                if (!effectiveSpecialtyId && topic.specialtyId) {
                    effectiveSpecialtyId = topic.specialtyId;
                }
                whereClause[Op.or] = [
                    { subTopic: subTopic },
                    { topicId: topic.id }
                ];
            } else {
                whereClause.subTopic = subTopic;
            }
        } else if (id && !effectiveSpecialtyId) {
            const q = await Question.findByPk(id, { attributes: ['id', 'specialtyId'] });
            if (q && q.specialtyId) {
                effectiveSpecialtyId = q.specialtyId;
            }
        }

        if (difficulty) whereClause.difficulty = difficulty;

        const questionInclude = [
            { model: Option, as: 'options', attributes: ['id', 'text', 'order', 'isCorrect'] },
            { model: Explanation, as: 'explanation' },
            { model: Specialty, as: 'specialty', attributes: ['name'] },
            { model: Topic, as: 'topic', attributes: ['name'] }
        ];

        const optionOrder = [
            [{ model: Option, as: 'options' }, 'order', 'ASC'],
            [{ model: Option, as: 'options' }, 'id', 'ASC']
        ];

        // ─── Direct lookup if specific ID is requested (e.g. resume question #78) ───
        if (id) {
            const [question, isBookmarked] = await Promise.all([
                Question.findByPk(id, {
                    include: questionInclude,
                    order: optionOrder
                }),
                Bookmark.findOne({
                    where: { userId: req.user.id, questionId: id },
                    attributes: ['id'],
                    raw: true
                })
            ]);

            if (!question) {
                return res.status(200).json({ success: true, message: 'Question not found', data: null });
            }

            const questionData = question.toJSON();
            if (questionData.topic) questionData.subTopic = questionData.topic.name;

            return res.status(200).json({
                success: true,
                data: {
                    ...questionData,
                    isBookmarked: !!isBookmarked,
                    totalInCategory: 1
                }
            });
        }

        // ─── 1. Instant ID candidates query (ultra-fast indexed scan, ~2-4ms) ───
        const candidateQuestions = await Question.findAll({
            where: whereClause,
            attributes: ['id'],
            raw: true
        });

        if (!candidateQuestions || candidateQuestions.length === 0) {
            return res.status(200).json({ success: true, message: 'No more questions available matching criteria', data: null });
        }

        let candidateIds = candidateQuestions.map(q => q.id);
        const totalCount = candidateIds.length;

        // ─── 2. Free accounts quota check ───
        if (!req.isPremium && req.user.role !== 'admin') {
            if (effectiveSpecialtyId) {
                const attemptedCount = await QuestionAttempt.count({
                    where: {
                        userId: req.user.id,
                        questionId: { [Op.in]: candidateIds }
                    },
                    distinct: true,
                    col: 'questionId'
                });

                if (attemptedCount >= 15) {
                    return res.status(403).json({
                        success: false,
                        message: 'لقد استنفذت الـ 15 سؤالاً المجانية لهذا التخصص. يرجى الترقية إلى باقة PRO للمتابعة.',
                        code: 'QUOTA_EXCEEDED'
                    });
                }
            } else {
                const totalBankAttempts = await QuestionAttempt.count({
                    where: { userId: req.user.id },
                    distinct: true,
                    col: 'questionId'
                });

                if (totalBankAttempts >= 30) {
                    return res.status(403).json({
                        success: false,
                        message: 'لقد استنفذت الحد المجاني لبنك الأسئلة (30 سؤالاً). يرجى الترقية إلى باقة PRO للمتابعة.',
                        code: 'QUOTA_EXCEEDED'
                    });
                }
            }
        }

        // ─── 3. Apply mode / filters via in-memory Set lookup (0.05ms) ───
        if (mode === 'new' || filter === 'new') {
            const attempted = await QuestionAttempt.findAll({
                where: { userId: req.user.id },
                attributes: ['questionId'],
                raw: true
            });
            const attemptedSet = new Set(attempted.map(a => a.questionId));
            candidateIds = candidateIds.filter(qId => !attemptedSet.has(qId));
        } else if (filter === 'bookmarked') {
            const bookmarks = await Bookmark.findAll({
                where: { userId: req.user.id },
                attributes: ['questionId'],
                raw: true
            });
            const bookmarkSet = new Set(bookmarks.map(b => b.questionId));
            candidateIds = candidateIds.filter(qId => bookmarkSet.has(qId));
        } else if (filter === 'mastered') {
            const masteredAttempts = await QuestionAttempt.findAll({
                where: { userId: req.user.id, isCorrect: true, confidenceLevel: 'high' },
                attributes: ['questionId'],
                raw: true
            });
            const masteredSet = new Set(masteredAttempts.map(a => a.questionId));
            candidateIds = candidateIds.filter(qId => masteredSet.has(qId));
        } else if (mode === 'wrong') {
            const wrongAttempts = await QuestionAttempt.findAll({
                where: { userId: req.user.id, isCorrect: false },
                attributes: ['questionId'],
                raw: true
            });
            const wrongSet = new Set(wrongAttempts.map(a => a.questionId));
            candidateIds = candidateIds.filter(qId => wrongSet.has(qId));
        } else if (mode === 'review') {
            const dueProgress = await UserProgress.findAll({
                where: {
                    userId: req.user.id,
                    nextReviewDate: { [Op.lte]: new Date() }
                },
                attributes: ['questionId'],
                raw: true
            });
            const dueSet = new Set(dueProgress.map(p => p.questionId));
            candidateIds = candidateIds.filter(qId => dueSet.has(qId));
        }

        // ─── 4. Exclude questions already answered in this session ───
        if (req.query.exclude) {
            const excludeIds = req.query.exclude.split(',').map(id => parseInt(id, 10)).filter(id => !isNaN(id));
            if (excludeIds.length > 0) {
                const excludeSet = new Set(excludeIds);
                candidateIds = candidateIds.filter(qId => !excludeSet.has(qId));
            }
        }

        if (candidateIds.length === 0) {
            return res.status(200).json({ success: true, message: 'No more questions available matching criteria', data: null });
        }

        // ─── 5. Pick the target question ───
        const shouldShuffle = req.query.shuffle !== 'false';
        let targetQuestionId;
        if (shouldShuffle) {
            targetQuestionId = candidateIds[Math.floor(Math.random() * candidateIds.length)];
        } else {
            targetQuestionId = candidateIds[0];
        }

        // ─── 6. Direct single question fetch via Primary Key B-Tree lookup (1-2ms) ───
        const [question, isBookmarked] = await Promise.all([
            Question.findByPk(targetQuestionId, {
                include: questionInclude,
                order: optionOrder
            }),
            Bookmark.findOne({
                where: { userId: req.user.id, questionId: targetQuestionId },
                attributes: ['id'],
                raw: true
            })
        ]);

        if (!question) {
            return res.status(200).json({ success: true, message: 'No more questions available matching criteria', data: null });
        }

        const questionData = question.toJSON();
        if (questionData.topic) {
            questionData.subTopic = questionData.topic.name;
        }

        res.status(200).json({
            success: true,
            data: {
                ...questionData,
                isBookmarked: !!isBookmarked,
                totalInCategory: totalCount
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Submit answer
// @route   POST /api/v1/questions/:id/answer
// @access  Private
exports.submitAnswer = async (req, res, next) => {
    try {
        const questionId = req.params.id;
        const { selectedOptionId, timeTaken } = req.body;

        const question = await Question.findByPk(questionId, {
            include: [
                { model: Option, as: 'options' },
                { model: Explanation, as: 'explanation' },
                { model: Topic, as: 'topic', attributes: ['isPremium'] }
            ]
        });

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        // ─── Free accounts: block premium topics and enforce 15 questions per specialty ───
        if (!req.isPremium && (!req.user || req.user.role !== 'admin')) {
            if (question.topic && question.topic.isPremium) {
                return res.status(403).json({
                    success: false,
                    message: 'هذا السؤال مخصص لمشتركي PRO فقط.',
                    code: 'PREMIUM_TOPIC_LOCKED'
                });
            }

            const existingAttempt = await QuestionAttempt.findOne({
                where: { userId: req.user.id, questionId }
            });

            if (!existingAttempt) {
                const sessionType = req.body.sessionType;
                const isSpecialtyPractice = sessionType === 'specialty' || sessionType === 'topic' || (req.body.specialtyId && sessionType !== 'general');

                if (isSpecialtyPractice && question.specialtyId) {
                    // Check 1: 15 questions per specialty limit for specialty / topic practice
                    const specialtyQuestions = await Question.findAll({
                        where: { specialtyId: question.specialtyId },
                        attributes: ['id']
                    });
                    const sqIds = specialtyQuestions.map(q => q.id);

                    const attemptedCount = await QuestionAttempt.count({
                        where: {
                            userId: req.user.id,
                            questionId: { [Op.in]: sqIds }
                        },
                        distinct: true,
                        col: 'questionId'
                    });

                    if (attemptedCount >= 15) {
                        return res.status(403).json({
                            success: false,
                            message: 'لقد استنفذت الـ 15 سؤالاً المجانية لهذا التخصص. يرجى الترقية إلى باقة PRO للمتابعة.',
                            code: 'QUOTA_EXCEEDED'
                        });
                    }
                } else {
                    // Check 2: 30 questions limit for general Question Bank
                    const totalBankAttempts = await QuestionAttempt.count({
                        where: { userId: req.user.id },
                        distinct: true,
                        col: 'questionId'
                    });

                    if (totalBankAttempts >= 30) {
                        return res.status(403).json({
                            success: false,
                            message: 'لقد استنفذت الحد المجاني لبنك الأسئلة (30 سؤالاً). يرجى الترقية إلى باقة PRO للمتابعة.',
                            code: 'QUOTA_EXCEEDED'
                        });
                    }
                }
            }
        }

        // Check correctness
        const selectedOption = question.options.find(opt => opt.id == selectedOptionId);
        if (!selectedOption) {
            return res.status(400).json({ success: false, message: 'Invalid option selected' });
        }
        const isCorrect = selectedOption.isCorrect;

        // Record Attempt (upsert: update if exists, create if not)
        const confidenceLevel = req.body.confidenceLevel || 'medium';
        const existingAttempt = await QuestionAttempt.findOne({
            where: { userId: req.user.id, questionId }
        });

        if (existingAttempt) {
            await existingAttempt.update({
                selectedOptionId,
                isCorrect,
                confidenceLevel,
                timeTaken: timeTaken || 0
            });
        } else {
            await QuestionAttempt.create({
                userId: req.user.id,
                questionId,
                selectedOptionId,
                isCorrect,
                confidenceLevel,
                timeTaken: timeTaken || 0
            });
        }

        // SM-2 Spaced Repetition Logic
        let grade = 0;
        if (isCorrect) {
            if (confidenceLevel === 'high') grade = 5;
            else if (confidenceLevel === 'medium') grade = 4;
            else grade = 3;
        } else {
            grade = 2; // wrong
        }

        let userProgress = await UserProgress.findOne({
            where: { userId: req.user.id, questionId }
        });

        if (!userProgress) {
            userProgress = await UserProgress.create({
                userId: req.user.id,
                questionId,
                interval: 0,
                repetition: 0,
                easeFactor: 2.5,
                nextReviewDate: new Date()
            });
        }

        if (grade >= 3) {
            if (userProgress.repetition === 0) {
                userProgress.interval = 1;
            } else if (userProgress.repetition === 1) {
                userProgress.interval = 6;
            } else {
                userProgress.interval = Math.round(userProgress.interval * userProgress.easeFactor);
            }
            userProgress.repetition += 1;
        } else {
            userProgress.repetition = 0;
            userProgress.interval = 1; // Ensure review next day when failed
        }

        userProgress.easeFactor = userProgress.easeFactor + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02));
        if (userProgress.easeFactor < 1.3) userProgress.easeFactor = 1.3;

        const nextReview = new Date();
        nextReview.setDate(nextReview.getDate() + userProgress.interval);
        userProgress.nextReviewDate = nextReview;

        await userProgress.save();

        // Update QuestionStats
        const [stats, created] = await QuestionStats.findOrCreate({
            where: { questionId },
            defaults: {
                totalAttempts: 1,
                correctAttempts: isCorrect ? 1 : 0,
                totalTimeSeconds: timeTaken || 0
            }
        });

        if (!created) {
            stats.totalAttempts += 1;
            if (isCorrect) stats.correctAttempts += 1;
            stats.totalTimeSeconds += (timeTaken || 0);
            await stats.save();
        }

        const passRate = stats.totalAttempts > 0
            ? Math.round((stats.correctAttempts / stats.totalAttempts) * 100)
            : 0;
        const averageTime = stats.totalAttempts > 0
            ? Math.round(stats.totalTimeSeconds / stats.totalAttempts)
            : 0;

        // Return result + explanation + stats
        res.status(200).json({
            success: true,
            data: {
                isCorrect,
                correctOptionId: question.options.find(o => o.isCorrect).id,
                explanation: question.explanation,
                stats: {
                    passRate,
                    averageTimeSeconds: averageTime
                }
            }
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Toggle Bookmark question
// @route   POST /api/v1/questions/:id/bookmark
// @access  Private
exports.bookmarkQuestion = async (req, res, next) => {
    try {
        const questionId = req.params.id;

        const existingBookmark = await Bookmark.findOne({
            where: { userId: req.user.id, questionId }
        });

        if (existingBookmark) {
            await existingBookmark.destroy();
            return res.status(200).json({ success: true, bookmarked: false, message: 'Bookmark removed' });
        } else {
            const bookmark = await Bookmark.create({
                userId: req.user.id,
                questionId
            });
            return res.status(201).json({ success: true, bookmarked: true, data: bookmark });
        }
    } catch (error) {
        next(error);
    }
};

// @desc    Report question
// @route   POST /api/v1/questions/:id/report
// @access  Private
exports.reportQuestion = async (req, res, next) => {
    try {
        const questionId = parseInt(req.params.id, 10);
        let { reason, description, details } = req.body;
        const desc = (description || details || '').trim();

        // Valid reasons in our model
        const validReasons = ['wrong_answer', 'typo', 'confusing', 'scientific_error', 'other'];
        let dbReason = validReasons.includes(reason) ? reason : 'other';

        let report;
        try {
            report = await QuestionReport.create({
                userId: req.user.id,
                questionId,
                reason: dbReason,
                description: desc,
                status: 'pending'
            });
        } catch (createErr) {
            // If MySQL table enum on live server does not yet include scientific_error, fallback to 'other'
            report = await QuestionReport.create({
                userId: req.user.id,
                questionId,
                reason: 'other',
                description: reason && reason !== 'other' ? `[${reason}] ${desc}`.trim() : desc,
                status: 'pending'
            });
        }

        res.status(201).json({ success: true, message: 'Report submitted successfully', data: report });
    } catch (error) {
        next(error);
    }
};

// @desc    Get specialty sub-topics with mastery stats
// @route   GET /api/v1/questions/specialties/:id/topics
// @access  Private
exports.getSpecialtyTopics = async (req, res, next) => {
    try {
        const specialtyId = req.params.id;
        const userId = req.user.id;

        // 1. Get all questions for this specialty, including the new Topic join
        const questions = await Question.findAll({
            where: { specialtyId, isActive: true },
            attributes: ['id', 'subTopic', 'topicId'],
            include: [{ model: Topic, as: 'topic', attributes: ['name', 'isPremium'] }],
            raw: true,
            nest: true
        });

        if (questions.length === 0) {
            return res.status(200).json({ success: true, quotaExceeded: false, totalAttempted: 0, data: [] });
        }

        // 2. Get user attempts for these questions (latest attempt per question)
        const attempts = await QuestionAttempt.findAll({
            where: {
                userId,
                questionId: { [Op.in]: questions.map(q => q.id) }
            },
            attributes: ['questionId', 'isCorrect', 'confidenceLevel'],
            raw: true
        });

        const attemptMap = {};
        const uniqueAttemptedIds = new Set();
        attempts.forEach(a => {
            attemptMap[a.questionId] = {
                isCorrect: a.isCorrect,
                confidence: a.confidenceLevel
            };
            uniqueAttemptedIds.add(a.questionId);
        });

        const totalAttempted = uniqueAttemptedIds.size;
        const quotaExceeded = !req.isPremium && totalAttempted >= 15;

        // 3. Group by Topic (using Topic model if available, else subTopic string)
        const topics = {};

        questions.forEach(q => {
            let topicName = 'General';
            if (q.topic) {
                topicName = q.topic.name;
            } else if (q.subTopic) {
                topicName = q.subTopic;
            }

            if (!topics[topicName]) {
                const topicIsPremium = q.topic ? q.topic.isPremium : false;
                topics[topicName] = {
                    name: topicName,
                    totalQuestions: 0,
                    mastered: 0,
                    learning: 0,
                    new: 0,
                    isPremium: topicIsPremium,
                    isLocked: topicIsPremium && !req.isPremium // Locked for free users
                };
            }

            topics[topicName].totalQuestions++;

            const status = attemptMap[q.id];
            if (!status) {
                topics[topicName].new++;
            } else if (status.isCorrect) {
                topics[topicName].mastered++;
            } else {
                topics[topicName].learning++;
            }
        });

        res.status(200).json({
            success: true,
            quotaExceeded,
            totalAttempted,
            data: Object.values(topics)
        });

    } catch (error) {
        next(error);
    }
};

exports.getPracticeFilters = async (req, res, next) => {
    try {
        const specialties = await Specialty.findAll({
            where: { isActive: true },
            attributes: ['id', 'name'],
            order: [['name', 'ASC']]
        });

        const difficulties = ['easy', 'medium', 'hard'];
        const modes = [
            { id: 'new', name: 'New Questions' },
            { id: 'wrong', name: 'Wrong Answers' },
            { id: 'review', name: 'Due for Review' },
            { id: 'all', name: 'All Questions' }
        ];

        res.status(200).json({
            success: true,
            data: {
                specialties,
                difficulties,
                modes
            }
        });
    } catch (error) {
        next(error);
    }
};
