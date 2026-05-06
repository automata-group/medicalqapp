const { Bookmark, Question, Specialty, Option } = require('../models');

// @desc    Get user bookmarks
// @route   GET /api/v1/bookmarks
// @access  Private
exports.getBookmarks = async (req, res, next) => {
    try {
        const bookmarks = await Bookmark.findAll({
            where: { userId: req.user.id },
            include: [
                {
                    model: Question,
                    as: 'question',
                    include: [
                        { model: Specialty, as: 'specialty', attributes: ['name'] },
                        { model: Option, as: 'options', attributes: ['id', 'text', 'order'] }
                    ]
                }
            ],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count: bookmarks.length,
            data: bookmarks
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete bookmark
// @route   DELETE /api/v1/bookmarks/:id
// @access  Private
exports.deleteBookmark = async (req, res, next) => {
    try {
        const bookmark = await Bookmark.findByPk(req.params.id);

        if (!bookmark) {
            return res.status(404).json({ success: false, message: 'Bookmark not found' });
        }

        if (bookmark.userId !== req.user.id) {
            return res.status(401).json({ success: false, message: 'Not authorized' });
        }

        await bookmark.destroy();

        res.status(200).json({ success: true, message: 'Bookmark removed' });
    } catch (error) {
        next(error);
    }
};

// @desc    Update bookmark note
// @route   PUT /api/v1/bookmarks/:id/notes
// @access  Private
exports.updateNote = async (req, res, next) => {
    try {
        const { note } = req.body;
        const bookmark = await Bookmark.findByPk(req.params.id);

        if (!bookmark) {
            return res.status(404).json({ success: false, message: 'Bookmark not found' });
        }

        if (bookmark.userId !== req.user.id) {
            return res.status(401).json({ success: false, message: 'Not authorized' });
        }

        bookmark.note = note;
        await bookmark.save();

        res.status(200).json({ success: true, data: bookmark });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single bookmark
// @route   GET /api/v1/bookmarks/:id
// @access  Private
exports.getBookmark = async (req, res, next) => {
    try {
        const bookmark = await Bookmark.findByPk(req.params.id, {
            include: [
                {
                    model: Question,
                    as: 'question',
                    include: [{ model: Specialty, as: 'specialty', attributes: ['name'] }]
                }
            ]
        });

        if (!bookmark) {
            return res.status(404).json({ success: false, message: 'Bookmark not found' });
        }

        if (bookmark.userId !== req.user.id) {
            return res.status(401).json({ success: false, message: 'Not authorized' });
        }

        res.status(200).json({ success: true, data: bookmark });
    } catch (error) {
        next(error);
    }
};
