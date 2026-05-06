const { AIFeedback, QuestionAttempt, Question, Topic, Specialty } = require('../models');
const aiService = require('../utils/aiService');
const { Op } = require('sequelize');

// @desc    Generate Mistake Analysis
// @route   POST /api/v1/ai-feedback/generate
// @access  Private
exports.generateFeedback = async (req, res, next) => {
    try {
        // 1. Get last 15 incorrect attempts
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
                message: 'تحتاج إلى خطأ واحد على الأقل لإنشاء تحليل.'
            });
        }

        // 2. Format content for AI
        const mistakeList = attempts.map(a => {
            const topicName = a.question?.topic?.name || a.question?.specialty?.name || 'عام';
            const questionText = a.question?.text ? a.question.text.substring(0, 100) : 'سؤال غير معروف';
            return `- السؤال: ${questionText}\n  الموضوع: ${topicName}`;
        }).join('\n');
        const prompt = `هيا حلل أخطائي الأخيرة في المذاكرة الطبية:\n${mistakeList}\nيرجى تزويدي بجدول ملخص ونصيحة للتحسين.`;

        // 3. Call AI
        const analysis = await aiService.generateAnalysis(prompt);

        // 4. Save to DB
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
