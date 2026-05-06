const { Specialty, User, UserSpecialty, StudyPlan, Question } = require('../models');
const sequelize = require('../config/database');

// @desc    Get all available specialties
// @route   GET /api/v1/specialties
// @access  Public
exports.getAllSpecialties = async (req, res, next) => {
    try {
        const specialties = await Specialty.findAll({
            where: { isActive: true },
            attributes: {
                include: [
                    [
                        sequelize.fn('COUNT', sequelize.col('questions.id')),
                        'totalQuestions'
                    ]
                ]
            },
            include: [{
                model: Question,
                as: 'questions',
                attributes: []
            }],
            group: ['Specialty.id'],
            order: [['sortOrder', 'ASC'], ['name', 'ASC']]
        });

        res.status(200).json({
            success: true,
            count: specialties.length,
            data: specialties
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get specialty details
// @route   GET /api/v1/specialties/:id
// @access  Public
exports.getSpecialty = async (req, res, next) => {
    try {
        const specialty = await Specialty.findByPk(req.params.id);

        if (!specialty) {
            return res.status(404).json({ success: false, message: 'Specialty not found' });
        }

        res.status(200).json({
            success: true,
            data: specialty
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user's selected specialties
// @route   POST /api/v1/user/specialties
// @access  Private
exports.updateUserSpecialties = async (req, res, next) => {
    try {
        const { specialtyIds } = req.body; // Array of IDs

        if (!Array.isArray(specialtyIds)) {
            return res.status(400).json({ success: false, message: 'specialtyIds must be an array' });
        }

        const user = await User.findByPk(req.user.id);

        // Validate IDs exist
        const specialties = await Specialty.findAll({
            where: { id: specialtyIds }
        });

        if (specialties.length !== specialtyIds.length) {
            return res.status(400).json({ success: false, message: 'One or more specialty IDs are invalid' });
        }

        // Update associations
        await user.setSpecialties(specialties);

        res.status(200).json({
            success: true,
            message: 'Specialties updated successfully',
            data: specialties
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user's selected specialties
// @route   GET /api/v1/user/specialties
// @access  Private
exports.getUserSpecialties = async (req, res, next) => {
    try {
        const specialties = await Specialty.findAll({
            include: [
                {
                    model: User,
                    as: 'users',
                    where: { id: req.user.id },
                    attributes: [],
                    through: { attributes: [] }
                },
                {
                    model: Question,
                    as: 'questions',
                    attributes: []
                }
            ],
            attributes: {
                include: [
                    [
                        sequelize.fn('COUNT', sequelize.col('questions.id')),
                        'totalQuestions'
                    ]
                ]
            },
            group: ['Specialty.id'],
            order: [['name', 'ASC']]
        });

        res.status(200).json({
            success: true,
            count: specialties.length,
            data: specialties
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Update user study settings (Study Plan)
// @route   PUT /api/v1/user/study-settings
// @access  Private
exports.updateStudySettings = async (req, res, next) => {
    try {
        const { examDate, dailyHours, targetScore, notificationEnabled, notificationTime, studyDays } = req.body;

        let studyPlan = await StudyPlan.findOne({ where: { userId: req.user.id } });

        if (!studyPlan) {
            // Create if not exists
            studyPlan = await StudyPlan.create({
                userId: req.user.id,
                examDate,
                dailyHours,
                targetScore,
                notificationEnabled,
                notificationTime,
                studyDays
            });
        } else {
            // Update
            await studyPlan.update({
                examDate,
                dailyHours,
                targetScore,
                notificationEnabled,
                notificationTime,
                studyDays
            });
        }

        res.status(200).json({
            success: true,
            message: 'Study settings updated',
            data: studyPlan
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get user study settings
// @route   GET /api/v1/user/study-settings
// @access  Private
exports.getStudySettings = async (req, res, next) => {
    try {
        const studyPlan = await StudyPlan.findOne({ where: { userId: req.user.id } });

        res.status(200).json({
            success: true,
            data: studyPlan || {} // Return empty object if no plan set yet
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Remove a specialty from user's list
// @route   DELETE /api/v1/user/specialties/:id
// @access  Private
exports.removeUserSpecialty = async (req, res, next) => {
    try {
        const specialtyId = req.params.id;
        const user = await User.findByPk(req.user.id);

        const specialty = await Specialty.findByPk(specialtyId);
        if (!specialty) {
            return res.status(404).json({ success: false, message: 'Specialty not found' });
        }

        await user.removeSpecialty(specialty);

        res.status(200).json({ success: true, message: 'Specialty removed' });
    } catch (error) {
        next(error);
    }
};
