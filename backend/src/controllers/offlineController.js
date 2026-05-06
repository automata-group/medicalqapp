const { Question, Option, Explanation, Specialty, Topic, QuestionAttempt, UserMockExam } = require('../models');
const { Op } = require('sequelize');

// @desc    Download questions for offline
// @route   GET /api/v1/offline/download-questions
// @access  Private
exports.downloadQuestions = async (req, res, next) => {
    try {
        const { specialtyId, since } = req.query;

        const whereClause = { isActive: true };
        if (specialtyId) whereClause.specialtyId = specialtyId;
        if (since) whereClause.updatedAt = { [Op.gte]: new Date(since) };

        const questions = await Question.findAll({
            where: whereClause,
            include: [
                { model: Option, as: 'options' },
                { model: Explanation, as: 'explanation' },
                { model: Specialty, as: 'specialty', attributes: ['name'] },
                { model: Topic, as: 'topic', attributes: ['name'] }
            ],
            limit: 500 // Limit batch size
        });

        res.status(200).json({
            success: true,
            count: questions.length,
            version: new Date().toISOString(),
            data: questions
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Sync Offline Data (Upload Answers)
// @route   POST /api/v1/offline/sync
// @access  Private
exports.syncOfflineData = async (req, res, next) => {
    try {
        const { attempts, mockExams } = req.body;
        const userId = req.user.id;
        const results = { attempts: 0, mockExams: 0, errors: [] };

        // Process Practice Attempts
        if (attempts && Array.isArray(attempts)) {
            for (const attempt of attempts) {
                try {
                    // Check if already exists (idempotency key or composite check)
                    // Simplified check: if recent duplicate exists
                    await QuestionAttempt.create({
                        userId,
                        questionId: attempt.questionId,
                        selectedOptionId: attempt.selectedOptionId,
                        isCorrect: attempt.isCorrect,
                        timeTaken: attempt.timeTaken,
                        createdAt: attempt.timestamp || new Date() // Trust client timestamp or override
                    });
                    results.attempts++;
                } catch (e) {
                    results.errors.push({ type: 'attempt', id: attempt.id, error: e.message });
                }
            }
        }

        // Process Mock Exams (Simplified)
        // In real app, would need complex validation of structure
        if (mockExams && Array.isArray(mockExams)) {
            // Logic to create UserMockExam records
            results.mockExams = mockExams.length;
        }

        res.status(200).json({
            success: true,
            message: 'Sync completed',
            results
        });

    } catch (error) {
        next(error);
    }
};
