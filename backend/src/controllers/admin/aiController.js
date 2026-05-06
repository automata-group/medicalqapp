const aiService = require('../../services/aiService');
const { Question, AdminActivityLog } = require('../../models');

// @desc    Verify question with AI
// @route   POST /api/v1/admin/ai/verify-question
// @access  Private (Admin)
exports.verifyQuestion = async (req, res, next) => {
    try {
        const { text, options } = req.body;

        if (!text || !options) {
            return res.status(400).json({ success: false, message: 'Please provide text and options' });
        }

        const verificationResult = await aiService.verifyQuestion(text, options);

        // Log usage? Optional.

        res.status(200).json({ success: true, data: verificationResult });
    } catch (error) {
        next(error);
    }
};

// @desc    Generate explanation
// @route   POST /api/v1/admin/ai/generate-explanation
// @access  Private (Admin)
exports.generateExplanation = async (req, res, next) => {
    try {
        const { text, correctOption } = req.body;

        if (!text || !correctOption) {
            return res.status(400).json({ success: false, message: 'Please provide text and correctOption' });
        }

        const explanation = await aiService.generateExplanation(text, correctOption);

        res.status(200).json({ success: true, data: { explanation } });

    } catch (error) {
        next(error);
    }
};
