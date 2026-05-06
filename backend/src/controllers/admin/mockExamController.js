const { MockExam, MockExamSection, Specialty, Achievement, Topic, SectionQuestion, MockQuestion, MockOption, MockExplanation } = require('../../models');
const aiService = require('../../services/aiService');

// @desc    Get all mock exams
// @route   GET /api/v1/admin/mock-exams
// @access  Private/Admin
exports.getMockExams = async (req, res, next) => {
    try {
        const exams = await MockExam.findAll({
            include: [
                { model: Specialty, as: 'specialty', attributes: ['name'] },
                { model: Achievement, as: 'achievement', attributes: ['name'] }
            ]
        });
        res.status(200).json({ success: true, data: exams });
    } catch (error) {
        next(error);
    }
};

// @desc    Create mock exam
// @route   POST /api/v1/admin/mock-exams
// @access  Private/Admin
exports.createMockExam = async (req, res, next) => {
    try {
        const exam = await MockExam.create(req.body);
        res.status(201).json({ success: true, data: exam });
    } catch (error) {
        next(error);
    }
};

// @desc    Update mock exam
// @route   PUT /api/v1/admin/mock-exams/:id
// @access  Private/Admin
exports.updateMockExam = async (req, res, next) => {
    try {
        let exam = await MockExam.findByPk(req.params.id);
        if (!exam) return res.status(404).json({ success: false, message: 'Not found' });

        exam = await exam.update(req.body);
        res.status(200).json({ success: true, data: exam });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete mock exam
// @route   DELETE /api/v1/admin/mock-exams/:id
// @access  Private/Admin
exports.deleteMockExam = async (req, res, next) => {
    try {
        const exam = await MockExam.findByPk(req.params.id);
        if (!exam) return res.status(404).json({ success: false, message: 'Not found' });

        await exam.destroy();
        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        next(error);
    }
};

// @desc    Generate questions for mock exam using AI
// @route   POST /api/v1/admin/mock-exams/:id/ai-generate
// @access  Private/Admin
exports.aiGenerateMockQuestions = async (req, res, next) => {
    try {
        const exam = await MockExam.findByPk(req.params.id, {
            include: [{ model: Specialty, as: 'specialty' }]
        });

        if (!exam) return res.status(404).json({ success: false, message: 'Exam not found' });
        if (!exam.specialty) return res.status(400).json({ success: false, message: 'Exam must have a specialty assigned for AI generation' });

        const count = parseInt(req.body.count) || exam.totalQuestions || 10;
        const topicName = req.body.topic || exam.specialty.name;

        // Ensure a topic exists for these AI questions
        let topic = await Topic.findOne({ where: { specialtyId: exam.specialtyId, name: topicName } });
        if (!topic) {
            topic = await Topic.create({ specialtyId: exam.specialtyId, name: topicName });
        }

        // Ensure a section exists for the exam
        let section = await MockExamSection.findOne({ where: { mockExamId: exam.id } });
        if (!section) {
            section = await MockExamSection.create({
                mockExamId: exam.id,
                title: 'General Section',
                duration: exam.duration,
                questionCount: exam.totalQuestions
            });
        }

        console.log(`[AI] Generating ${count} questions for Exam: ${exam.title} (Topic: ${topicName})...`);

        const generatedQuestions = [];
        for (let i = 0; i < count; i++) {
            const result = await aiService.generateFullQuestion(exam.specialty.name, topicName);
            if (result.success) {
                const qData = result.data;
                
                // Create Mock Question
                const question = await MockQuestion.create({
                    text: qData.questionText,
                    specialtyId: exam.specialtyId,
                    topicId: topic.id,
                    difficulty: qData.difficulty || 'medium',
                    isPremium: exam.isPremium
                });

                // Create Mock Options
                if (qData.options) {
                    await Promise.all(qData.options.map((opt, index) => {
                        // Ensure order is an integer. If AI returns 'A', 'B', etc., map to 1, 2, 3...
                        let orderValue = parseInt(opt.order);
                        if (isNaN(orderValue)) {
                            // Map A=1, B=2, C=3, D=4
                            const orderMap = { 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5 };
                            orderValue = orderMap[String(opt.order).toUpperCase()] || (index + 1);
                        }

                        return MockOption.create({
                            mockQuestionId: question.id,
                            text: opt.text,
                            isCorrect: opt.isCorrect,
                            order: orderValue
                        });
                    }));
                }

                // Create Mock Explanation
                await MockExplanation.create({
                    mockQuestionId: question.id,
                    text: qData.explanation,
                    references: qData.references
                });

                // Link to Exam Section
                await SectionQuestion.create({
                    sectionId: section.id,
                    mockQuestionId: question.id,
                    sortOrder: i + 1
                });

                generatedQuestions.push(question.id);
                console.log(`[AI] Question ${i + 1}/${count} created.`);
            }
        }
        res.status(200).json({
            success: true,
            message: `Successfully generated ${generatedQuestions.length} questions for the exam.`,
            count: generatedQuestions.length
        });

    } catch (error) {
        console.error('[AI Mock Gen Error]', error);
        next(error);
    }
};
