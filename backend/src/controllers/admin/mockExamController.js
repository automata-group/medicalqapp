const { 
    MockExam, 
    MockExamSection, 
    Specialty, 
    Achievement, 
    Topic, 
    SectionQuestion, 
    MockQuestion, 
    MockOption, 
    MockExplanation,
    Question,
    Option,
    Explanation
} = require('../../models');
const { Op } = require('sequelize');
const aiService = require('../../services/aiService');

// Helper to ensure an exam has a section
const getOrCreateDefaultSection = async (exam) => {
    let section = await MockExamSection.findOne({ where: { mockExamId: exam.id } });
    if (!section) {
        section = await MockExamSection.create({
            mockExamId: exam.id,
            title: 'General Section',
            duration: exam.duration || 60,
            questionCount: 0
        });
    }
    return section;
};

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
        // Create initial section
        await getOrCreateDefaultSection(exam);
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
        let section = await getOrCreateDefaultSection(exam);

        console.log(`[AI] Generating ${count} questions for Exam: ${exam.title} (Topic: ${topicName})...`);

        let currentSortOrder = await SectionQuestion.count({ where: { sectionId: section.id } });
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
                        let orderValue = parseInt(opt.order);
                        if (isNaN(orderValue)) {
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
                currentSortOrder += 1;
                await SectionQuestion.create({
                    sectionId: section.id,
                    mockQuestionId: question.id,
                    sortOrder: currentSortOrder
                });

                generatedQuestions.push(question.id);
                console.log(`[AI] Question ${i + 1}/${count} created.`);
            }
        }

        // Update counts
        const totalCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        await section.update({ questionCount: totalCount });
        await exam.update({ totalQuestions: totalCount });

        res.status(200).json({
            success: true,
            message: `Successfully generated ${generatedQuestions.length} questions for the exam.`,
            count: generatedQuestions.length,
            totalQuestions: totalCount
        });

    } catch (error) {
        console.error('[AI Mock Gen Error]', error);
        next(error);
    }
};

// @desc    Get all questions attached to a mock exam
// @route   GET /api/v1/admin/mock-exams/:id/questions
// @access  Private/Admin
exports.getMockExamQuestions = async (req, res, next) => {
    try {
        const exam = await MockExam.findByPk(req.params.id);
        if (!exam) return res.status(404).json({ success: false, message: 'Mock Exam not found' });

        const section = await getOrCreateDefaultSection(exam);

        const sectionQuestions = await SectionQuestion.findAll({
            where: { sectionId: section.id },
            order: [['sortOrder', 'ASC']]
        });

        const questionIds = sectionQuestions.map(sq => sq.mockQuestionId);

        const questions = await MockQuestion.findAll({
            where: { id: { [Op.in]: questionIds } },
            include: [
                { model: MockOption, as: 'options' },
                { model: MockExplanation, as: 'explanation' },
                { model: Specialty, as: 'specialty', attributes: ['name'] }
            ]
        });

        // Maintain sortOrder from SectionQuestion
        const qMap = new Map(questions.map(q => [q.id, q]));
        const ordered = [];
        for (const sq of sectionQuestions) {
            const q = qMap.get(sq.mockQuestionId);
            if (q) {
                const item = q.toJSON();
                item.sortOrder = sq.sortOrder;
                if (item.options) {
                    item.options.sort((a, b) => a.order - b.order);
                }
                ordered.push(item);
            }
        }

        res.status(200).json({
            success: true,
            count: ordered.length,
            data: ordered
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Add existing questions from Question Bank into mock exam
// @route   POST /api/v1/admin/mock-exams/:id/add-from-bank
// @access  Private/Admin
exports.addQuestionsFromBank = async (req, res, next) => {
    try {
        const exam = await MockExam.findByPk(req.params.id);
        if (!exam) return res.status(404).json({ success: false, message: 'Exam not found' });

        const { questionIds } = req.body;
        if (!questionIds || !Array.isArray(questionIds) || questionIds.length === 0) {
            return res.status(400).json({ success: false, message: 'Please provide an array of question IDs' });
        }

        const section = await getOrCreateDefaultSection(exam);

        const bankQuestions = await Question.findAll({
            where: { id: { [Op.in]: questionIds } },
            include: [
                { model: Option, as: 'options' },
                { model: Explanation, as: 'explanation' }
            ]
        });

        if (bankQuestions.length === 0) {
            return res.status(404).json({ success: false, message: 'No questions found from the provided IDs' });
        }

        let currentCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        const added = [];
        const orderMap = { 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5 };

        for (const bq of bankQuestions) {
            // Create MockQuestion
            const mockQuestion = await MockQuestion.create({
                text: bq.text,
                specialtyId: bq.specialtyId || exam.specialtyId,
                topicId: bq.topicId || null,
                image: bq.image || null,
                difficulty: bq.difficulty || 'medium',
                isPremium: exam.isPremium,
                isActive: true,
                source: `Bank Question #${bq.id}`
            });

            // Create MockOptions
            if (bq.options && bq.options.length > 0) {
                for (let i = 0; i < bq.options.length; i++) {
                    const opt = bq.options[i];
                    let orderVal = parseInt(opt.order);
                    if (isNaN(orderVal)) {
                        orderVal = orderMap[String(opt.order).toUpperCase()] || (i + 1);
                    }
                    await MockOption.create({
                        mockQuestionId: mockQuestion.id,
                        text: opt.text,
                        isCorrect: !!opt.isCorrect,
                        order: orderVal
                    });
                }
            }

            // Create MockExplanation
            if (bq.explanation) {
                await MockExplanation.create({
                    mockQuestionId: mockQuestion.id,
                    text: bq.explanation.text,
                    references: bq.explanation.references || null
                });
            }

            // Link to section
            currentCount += 1;
            await SectionQuestion.create({
                sectionId: section.id,
                mockQuestionId: mockQuestion.id,
                sortOrder: currentCount
            });

            added.push(mockQuestion.id);
        }

        // Update counts
        const totalCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        await section.update({ questionCount: totalCount });
        await exam.update({ totalQuestions: totalCount });

        res.status(200).json({
            success: true,
            message: `Successfully imported ${added.length} questions to exam.`,
            count: added.length,
            totalQuestions: totalCount
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Add a custom question to mock exam
// @route   POST /api/v1/admin/mock-exams/:id/add-custom-question
// @access  Private/Admin
exports.addCustomMockQuestion = async (req, res, next) => {
    try {
        const exam = await MockExam.findByPk(req.params.id);
        if (!exam) return res.status(404).json({ success: false, message: 'Exam not found' });

        const { text, difficulty, specialtyId, topicId, options, explanation } = req.body;

        if (!text || !text.trim()) {
            return res.status(400).json({ success: false, message: 'Question text is required' });
        }

        if (!options || !Array.isArray(options) || options.length < 2) {
            return res.status(400).json({ success: false, message: 'At least 2 options are required' });
        }

        const hasCorrect = options.some(o => o.isCorrect);
        if (!hasCorrect) {
            return res.status(400).json({ success: false, message: 'At least one option must be marked as correct' });
        }

        const section = await getOrCreateDefaultSection(exam);

        const mockQuestion = await MockQuestion.create({
            text: text.trim(),
            specialtyId: specialtyId || exam.specialtyId,
            topicId: topicId || null,
            difficulty: difficulty || 'medium',
            isPremium: exam.isPremium,
            isActive: true,
            source: 'Manual / Custom'
        });

        for (let i = 0; i < options.length; i++) {
            const opt = options[i];
            await MockOption.create({
                mockQuestionId: mockQuestion.id,
                text: opt.text || '',
                isCorrect: !!opt.isCorrect,
                order: i + 1
            });
        }

        if (explanation && explanation.text && explanation.text.trim()) {
            await MockExplanation.create({
                mockQuestionId: mockQuestion.id,
                text: explanation.text.trim(),
                references: explanation.references ? explanation.references.trim() : null
            });
        }

        const currentCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        await SectionQuestion.create({
            sectionId: section.id,
            mockQuestionId: mockQuestion.id,
            sortOrder: currentCount + 1
        });

        const totalCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        await section.update({ questionCount: totalCount });
        await exam.update({ totalQuestions: totalCount });

        const fullQuestion = await MockQuestion.findByPk(mockQuestion.id, {
            include: [
                { model: MockOption, as: 'options' },
                { model: MockExplanation, as: 'explanation' }
            ]
        });

        res.status(201).json({
            success: true,
            message: 'Question added successfully',
            data: fullQuestion,
            totalQuestions: totalCount
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete a question from mock exam
// @route   DELETE /api/v1/admin/mock-exams/:id/questions/:questionId
// @access  Private/Admin
exports.deleteMockQuestion = async (req, res, next) => {
    try {
        const { id, questionId } = req.params;
        const exam = await MockExam.findByPk(id);
        if (!exam) return res.status(404).json({ success: false, message: 'Exam not found' });

        const section = await getOrCreateDefaultSection(exam);

        const link = await SectionQuestion.findOne({
            where: { sectionId: section.id, mockQuestionId: questionId }
        });

        if (!link) {
            return res.status(404).json({ success: false, message: 'Question not associated with this exam' });
        }

        await link.destroy();

        // Also destroy mock question (options and explanation cascade)
        await MockQuestion.destroy({ where: { id: questionId } });

        const totalCount = await SectionQuestion.count({ where: { sectionId: section.id } });
        await section.update({ questionCount: totalCount });
        await exam.update({ totalQuestions: totalCount });

        res.status(200).json({
            success: true,
            message: 'Question removed from mock exam',
            totalQuestions: totalCount
        });
    } catch (error) {
        next(error);
    }
};
