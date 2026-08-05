const { Topic, Specialty, Question } = require('../../models');
const sequelize = require('../../config/database');

// @desc    Get all topics (Admin)
// @route   GET /api/v1/admin/topics
// @access  Private (Admin)
exports.getTopics = async (req, res, next) => {
    try {
        const { specialtyId } = req.query;
        const whereClause = {};
        if (specialtyId) {
            whereClause.specialtyId = specialtyId;
        }

        const topics = await Topic.findAll({
            where: whereClause,
            attributes: {
                include: [
                    [
                        sequelize.literal(`(
                            SELECT COUNT(*)
                            FROM Questions AS question
                            WHERE question.topicId = Topic.id
                        )`),
                        'questionCount'
                    ]
                ]
            },
            include: [{ model: Specialty, as: 'specialty', attributes: ['name'] }],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({ success: true, count: topics.length, data: topics });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single topic
// @route   GET /api/v1/admin/topics/:id
// @access  Private (Admin)
exports.getTopic = async (req, res, next) => {
    try {
        const topic = await Topic.findByPk(req.params.id, {
            include: [{ model: Specialty, as: 'specialty', attributes: ['name'] }]
        });

        if (!topic) {
            return res.status(404).json({ success: false, message: 'Topic not found' });
        }

        res.status(200).json({ success: true, data: topic });
    } catch (error) {
        next(error);
    }
};

// @desc    Create topic
// @route   POST /api/v1/admin/topics
// @access  Private (Admin)
exports.createTopic = async (req, res, next) => {
    try {
        const { name, specialtyId, isPremium } = req.body;

        if (!name || !specialtyId) {
            return res.status(400).json({ success: false, message: 'Please provide name and specialtyId' });
        }

        const topic = await Topic.create({
            name,
            specialtyId,
            isPremium: isPremium || false,
            isActive: true
        });

        res.status(201).json({ success: true, data: topic });
    } catch (error) {
        next(error);
    }
};

// @desc    Update topic
// @route   PUT /api/v1/admin/topics/:id
// @access  Private (Admin)
exports.updateTopic = async (req, res, next) => {
    try {
        const topic = await Topic.findByPk(req.params.id);

        if (!topic) {
            return res.status(404).json({ success: false, message: 'Topic not found' });
        }

        await topic.update(req.body);

        res.status(200).json({ success: true, data: topic });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete topic
// @route   DELETE /api/v1/admin/topics/:id
// @access  Private (Admin)
exports.deleteTopic = async (req, res, next) => {
    try {
        const topic = await Topic.findByPk(req.params.id);

        if (!topic) {
            return res.status(404).json({ success: false, message: 'Topic not found' });
        }

        // Check if has questions
        const questionCount = await Question.count({ where: { topicId: topic.id } });
        if (questionCount > 0) {
            return res.status(400).json({ success: false, message: `Cannot delete topic with ${questionCount} associated questions.` });
        }

        await topic.destroy();

        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        next(error);
    }
};
