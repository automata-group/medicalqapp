const { Question, Specialty } = require('../models');
const { Op } = require('sequelize');

// @desc    Search questions
// @route   GET /api/v1/search/questions
// @access  Private
exports.searchQuestions = async (req, res, next) => {
    try {
        const { q, specialtyId } = req.query;

        if (!q) {
            return res.status(400).json({ success: false, message: 'Query parameter q is required' });
        }

        const whereClause = {
            [Op.or]: [
                { text: { [Op.like]: `%${q}%` } }
                // Add more fields if needed e.g., explanation text search
            ],
            isActive: true
        };

        if (specialtyId) {
            whereClause.specialtyId = specialtyId;
        }

        const questions = await Question.findAll({
            where: whereClause,
            limit: 20,
            include: [{ model: Specialty, as: 'specialty', attributes: ['name'] }]
        });

        res.status(200).json({
            success: true,
            count: questions.length,
            data: questions
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Advanced Search
// @route   POST /api/v1/search/advanced
// @access  Private
exports.advancedSearch = async (req, res, next) => {
    try {
        const { keyword, specialtyId, difficulty, isAnswered, mode } = req.body;

        const whereClause = { isActive: true };

        if (keyword) {
            whereClause[Op.or] = [
                { text: { [Op.like]: `%${keyword}%` } }
            ];
        }

        if (specialtyId) whereClause.specialtyId = specialtyId;
        if (difficulty) whereClause.difficulty = difficulty;

        // "mode" could be used for further filtering logic if needed (e.g. only bookmarked)

        const questions = await Question.findAll({
            where: whereClause,
            limit: 50,
            include: [{ model: Specialty, as: 'specialty', attributes: ['name'] }]
        });

        res.status(200).json({
            success: true,
            count: questions.length,
            data: questions
        });
    } catch (error) {
        next(error);
    }
};
