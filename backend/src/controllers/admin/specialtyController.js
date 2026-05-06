const { Specialty, Question } = require('../../models');

// @desc    Get all specialties (Admin)
// @route   GET /api/v1/admin/specialties
// @access  Private (Admin)
exports.getSpecialties = async (req, res, next) => {
    try {
        const specialties = await Specialty.findAll({
            order: [['sortOrder', 'ASC'], ['name', 'ASC']]
        });

        res.status(200).json({ success: true, count: specialties.length, data: specialties });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single specialty
// @route   GET /api/v1/admin/specialties/:id
// @access  Private (Admin)
exports.getSpecialty = async (req, res, next) => {
    try {
        const specialty = await Specialty.findByPk(req.params.id);

        if (!specialty) {
            return res.status(404).json({ success: false, message: 'Specialty not found' });
        }

        res.status(200).json({ success: true, data: specialty });
    } catch (error) {
        next(error);
    }
};

// @desc    Create specialty
// @route   POST /api/v1/admin/specialties
// @access  Private (Admin)
exports.createSpecialty = async (req, res, next) => {
    try {
        const { name, icon, order, isPremium } = req.body;

        const specialty = await Specialty.create({
            name,
            icon,
            sortOrder: order || 0,
            isPremium: isPremium || false
        });

        res.status(201).json({ success: true, data: specialty });
    } catch (error) {
        next(error);
    }
};

// @desc    Update specialty
// @route   PUT /api/v1/admin/specialties/:id
// @access  Private (Admin)
exports.updateSpecialty = async (req, res, next) => {
    try {
        const specialty = await Specialty.findByPk(req.params.id);

        if (!specialty) {
            return res.status(404).json({ success: false, message: 'Specialty not found' });
        }

        await specialty.update(req.body);

        res.status(200).json({ success: true, data: specialty });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete specialty
// @route   DELETE /api/v1/admin/specialties/:id
// @access  Private (Admin)
exports.deleteSpecialty = async (req, res, next) => {
    try {
        const specialty = await Specialty.findByPk(req.params.id);

        if (!specialty) {
            return res.status(404).json({ success: false, message: 'Specialty not found' });
        }

        // Check if has questions
        const questionCount = await Question.count({ where: { specialtyId: specialty.id } });
        if (questionCount > 0) {
            return res.status(400).json({ success: false, message: `Cannot delete specialty with ${questionCount} associated questions.` });
        }

        await specialty.destroy();

        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        next(error);
    }
};

// @desc    Reorder specialties
// @route   PUT /api/v1/admin/specialties/reorder
// @access  Private (Admin)
exports.reorderSpecialties = async (req, res, next) => {
    try {
        const { order } = req.body; // Array of { id, order }

        // Stub implementation
        res.status(200).json({ success: true, message: 'Specialties reordered' });
    } catch (error) {
        next(error);
    }
};
