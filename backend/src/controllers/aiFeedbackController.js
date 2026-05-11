const { AIFeedback, QuestionAttempt, Question, Topic, Specialty } = require('../models');
const aiService = require('../utils/aiService');
const { Op } = require('sequelize');

// @desc    Generate Mistake Analysis
// @route   POST /api/v1/ai-feedback/generate
// @access  Private
exports.generateFeedback = async (req, res, next) => {
    try {
        // 1. Premium Check
        if (!req.user.isPremium) {
            return res.status(403).json({
                success: false,
                message: 'AI Coach is a premium feature. Please upgrade your plan to access it.',
                message_ar: 'مدرب الذكاء الاصطناعي ميزة للمشتركين فقط. يرجى ترقية خطتك للوصول إليها.'
            });
        }

        // 2. Weekly Limit Check (2 times per 7 days)
        const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        const weeklyUsage = await AIFeedback.count({
            where: {
                userId: req.user.id,
                createdAt: { [Op.gte]: sevenDaysAgo }
            }
        });

        if (weeklyUsage >= 2) {
            return res.status(429).json({
                success: false,
                message: 'You have reached your weekly limit for AI Coach (2 reports per week).',
                message_ar: 'لقد وصلت إلى الحد الأسبوعي لمدرب الذكاء الاصطناعي (تقريرين فقط في الأسبوع).'
            });
        }

        // 3. Get last 15 incorrect attempts
        const attempts = await QuestionAttempt.findAll({
            where: {
                userId: req.user.id,
                isCorrect: false
            },
            limit: 15,
            order: [['createdAt', 'DESC']],
            include: [{
                model: Question,
                as: 'question',
                attributes: ['id', 'text', 'specialtyId'],
                include: [
                    { model: Topic, as: 'topic', attributes: ['name'], required: false },
                    { model: Specialty, as: 'specialty', attributes: ['name'], required: false }
                ]
            }]
        });

        if (attempts.length < 1) {
            return res.status(400).json({
                success: false,
                message: 'You need at least one mistake to generate an analysis.',
                message_ar: 'تحتاج إلى خطأ واحد على الأقل لإنشاء تحليل.'
            });
        }

        // 4. Format content for AI
        const mistakeList = attempts.map(a => {
            const topicName = a.question?.topic?.name || a.question?.specialty?.name || 'عام';
            const questionText = a.question?.text ? a.question.text.substring(0, 100) : 'سؤال غير معروف';
            return `- Question: ${questionText}\n  Topic: ${topicName}`;
        }).join('\n');
        
        const prompt = `Analyze my recent medical study mistakes:\n${mistakeList}\nPlease provide a summary table and advice for improvement in English.`;

        // 5. Call AI
        const analysis = await aiService.generateAnalysis(prompt);

        // 6. Save to DB
        const feedback = await AIFeedback.create({
            userId: req.user.id,
            content: analysis,
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
        });

        res.status(201).json({
            success: true,
            data: feedback
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get Latest Feedback
// @route   GET /api/v1/ai-feedback/latest
// @access  Private
exports.getLatestFeedback = async (req, res, next) => {
    try {
        const feedback = await AIFeedback.findOne({
            where: {
                userId: req.user.id,
                expiresAt: { [Op.gt]: new Date() }
            },
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            data: feedback
        });
    } catch (error) {
        next(error);
    }
};
