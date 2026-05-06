const { MockExam, MockExamSection, UserMockExam, MockQuestion, MockOption, UserMockExamAnswer, SectionQuestion, MockExplanation } = require('../models');

// @desc    Start a mock exam
// @route   POST /api/v1/mock-exams/start
// @access  Private
exports.startMockExam = async (req, res, next) => {
    try {
        const { mockExamId } = req.body;

        const mockExam = await MockExam.findByPk(mockExamId, {
            include: [{ model: MockExamSection, as: 'sections' }]
        });

        if (!mockExam) {
            return res.status(404).json({ success: false, message: 'Mock Exam not found' });
        }

        if (mockExam.isPremium && !req.isPremium) {
            return res.status(403).json({
                success: false,
                message: 'هذا الامتحان مخصص لمشتركي PRO فقط.',
                code: 'PREMIUM_REQUIRED'
            });
        }

        // Check for existing in-progress attempt
        let userMockExam = await UserMockExam.findOne({
            where: {
                userId: req.user.id,
                mockExamId,
                status: 'in-progress'
            }
        });

        if (!userMockExam) {
            // Create New Attempt
            userMockExam = await UserMockExam.create({
                userId: req.user.id,
                mockExamId,
                startTime: new Date(),
                status: 'in-progress',
                totalQuestions: mockExam.totalQuestions
            });
        }

        res.status(201).json({
            success: true,
            data: {
                attemptId: userMockExam.id,
                examTitle: mockExam.title,
                sections: mockExam.sections,
                startTime: userMockExam.startTime,
                lastActiveSectionId: userMockExam.lastActiveSectionId
            }
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Get all active mock exams
// @route   GET /api/v1/mock-exams
// @access  Private
exports.getMockExams = async (req, res, next) => {
    try {
        const mockExams = await MockExam.findAll({
            where: { isActive: true },
            attributes: ['id', 'title', 'description', 'duration', 'totalQuestions', 'price', 'isPremium']
        });

        res.status(200).json({
            success: true,
            count: mockExams.length,
            data: mockExams
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get mock exam details
// @route   GET /api/v1/mock-exams/:id
// @access  Private
exports.getMockExam = async (req, res, next) => {
    try {
        const mockExam = await MockExam.findByPk(req.params.id, {
            attributes: ['id', 'title', 'description', 'duration', 'totalQuestions'],
            include: [{ model: MockExamSection, as: 'sections', attributes: ['id', 'title', 'questionCount'] }]
        });

        if (!mockExam) {
            return res.status(404).json({ success: false, message: 'Mock Exam not found' });
        }

        res.status(200).json({ success: true, data: mockExam });
    } catch (error) {
        next(error);
    }
};

// @desc    Get questions for a section
// @route   GET /api/v1/mock-exams/:attemptId/sections/:sectionId
// @access  Private
exports.getSectionQuestions = async (req, res, next) => {
    try {
        const { attemptId, sectionId } = req.params;

        // Verify Attempt belongs to user
        const attempt = await UserMockExam.findOne({ where: { id: attemptId, userId: req.user.id } });
        if (!attempt) return res.status(404).json({ success: false, message: 'Attemp not found or unauthorized' });

        // Fetch Section with Questions
        const section = await MockExamSection.findByPk(sectionId, {
            include: [
                {
                    model: MockQuestion,
                    as: 'questions',
                    through: { attributes: ['sortOrder'] }, // From SectionQuestion
                    include: [
                        {
                            model: MockOption,
                            as: 'options',
                            attributes: ['id', 'text', 'order'] // Exclude isCorrect for security
                        }
                    ]
                }
            ],
            order: [[{ model: MockQuestion, as: 'questions' }, SectionQuestion, 'sortOrder', 'ASC']]
        });

        if (!section) return res.status(404).json({ success: false, message: 'Section not found' });

        res.status(200).json({
            success: true,
            data: section.questions
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Submit Answer (Single or Batch)
// @route   POST /api/v1/mock-exams/:attemptId/answer
// @access  Private
exports.submitAnswer = async (req, res, next) => {
    try {
        const { attemptId } = req.params;
        const { questionId, selectedOptionId, timeSpentSeconds } = req.body;

        const attempt = await UserMockExam.findOne({ where: { id: attemptId, userId: req.user.id } });
        if (!attempt) return res.status(404).json({ success: false, message: 'Attempt not found' });

        if (attempt.status === 'completed') {
            return res.status(400).json({ success: false, message: 'Exam already completed' });
        }

        // Check if correct
        const question = await MockQuestion.findByPk(questionId, { 
            include: [
                { model: MockOption, as: 'options' },
                { model: MockExplanation, as: 'explanation' }
            ] 
        });

        let isCorrect = false;
        let correctOptionId = null;

        if (question) {
            const correctOpt = question.options.find(o => o.isCorrect);
            if (correctOpt) correctOptionId = correctOpt.id;
            
            const selectedOpt = question.options.find(o => o.id == selectedOptionId);
            if (selectedOpt && selectedOpt.isCorrect) isCorrect = true;
        }

        // Upsert Answer
        const [answer, created] = await UserMockExamAnswer.findOrCreate({
            where: { userMockExamId: attemptId, mockQuestionId: questionId },
            defaults: {
                selectedOptionId,
                isCorrect,
                timeSpentSeconds
            }
        });

        if (!created) {
            await answer.update({ selectedOptionId, isCorrect, timeSpentSeconds });
        }

        // Update attempt last section if provided
        if (question && question.mockExamSections && question.mockExamSections.length > 0) {
             await attempt.update({ lastActiveSectionId: question.mockExamSections[0].id });
        }

        res.status(200).json({ 
            success: true,
            data: {
                isCorrect,
                correctOptionId,
                explanation: question?.explanation?.text || "No explanation available."
            }
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Complete Mock Exam
// @route   POST /api/v1/mock-exams/:attemptId/complete
// @access  Private
exports.completeMockExam = async (req, res, next) => {
    try {
        const { attemptId } = req.params;

        const attempt = await UserMockExam.findOne({ where: { id: attemptId, userId: req.user.id } });
        if (!attempt) return res.status(404).json({ success: false, message: 'Attempt not found' });

        // Calculate Score from UserMockExamAnswer table
        const answers = await UserMockExamAnswer.findAll({ where: { userMockExamId: attemptId } });

        let correctCount = 0;
        let wrongCount = 0;

        answers.forEach(ans => {
            if (ans.isCorrect) correctCount++;
            else wrongCount++;
        });

        const totalQuestions = attempt.totalQuestions || answers.length; // Fallback
        const percentage = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

        await attempt.update({
            endTime: new Date(),
            status: 'completed',
            score: correctCount,
            correctAnswers: correctCount,
            wrongAnswers: wrongCount,
            percentage,
            timeSpentSeconds: (new Date() - new Date(attempt.startTime)) / 1000
        });

        // Check for linked achievement and grant it
        const mockExam = await MockExam.findByPk(attempt.mockExamId);
        if (mockExam && mockExam.achievementId && percentage >= 50) {
            const { UserAchievement } = require('../models');
            await UserAchievement.findOrCreate({
                where: {
                    userId: req.user.id,
                    achievementId: mockExam.achievementId
                }
            });
        }

        // Calculate Percentile Rank
        const mockExamId = attempt.mockExamId;
        const allAttempts = await UserMockExam.findAll({
            where: { mockExamId, status: 'completed' },
            attributes: ['score']
        });

        const totalUsersTookExam = allAttempts.length;
        let percentileRank = 100;
        if (totalUsersTookExam > 0) {
            const lowerOrEqualScoreCount = allAttempts.filter(a => a.score <= correctCount).length;
            percentileRank = Math.round((lowerOrEqualScoreCount / totalUsersTookExam) * 100);
        }

        res.status(200).json({
            success: true,
            data: {
                score: correctCount,
                percentage,
                percentileRank,
                totalQuestions,
                status: 'completed'
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get mock exam history
// @route   GET /api/v1/mock-exams/history
// @access  Private
exports.getMockExamHistory = async (req, res, next) => {
    try {
        const history = await UserMockExam.findAll({
            where: { userId: req.user.id },
            include: [{ model: MockExam, as: 'mockExam', attributes: ['title'] }],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({ success: true, count: history.length, data: history });
    } catch (error) {
        next(error);
    }
};

// @desc    Review mock exam
// @route   GET /api/v1/mock-exams/:attemptId/review
// @access  Private
exports.reviewMockExam = async (req, res, next) => {
    try {
        const { attemptId } = req.params;

        const userExam = await UserMockExam.findOne({
            where: {
                id: attemptId,
                userId: req.user.id
            },
            include: [
                { model: MockExam, as: 'mockExam', attributes: ['title'] }
            ]
        });

        if (!userExam) {
            return res.status(404).json({ success: false, message: 'Exam attempt not found' });
        }

        // Fetch answers with question details
        const answers = await UserMockExamAnswer.findAll({
            where: { userMockExamId: userExam.id },
            include: [
                {
                    model: MockQuestion,
                    as: 'question',
                    attributes: ['text'],
                    include: [{ model: MockOption, as: 'options' }, { model: MockExplanation, as: 'explanation' }]
                }
            ]
        });

        res.status(200).json({
            success: true,
            data: {
                exam: userExam,
                answers
            }
        });
    } catch (error) {
        next(error);
    }
};
