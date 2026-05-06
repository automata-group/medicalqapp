const express = require('express');
const { getSpecialties, getSpecialty, createSpecialty, updateSpecialty, deleteSpecialty, reorderSpecialties } = require('../../controllers/admin/specialtyController');
const { protect, admin } = require('../../middleware/auth');

const upload = require('../../middleware/upload');

const router = express.Router();

router.use(protect);
router.use(admin);

router.post('/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ success: false, message: 'Please upload a file' });
    }
    const imageUrl = `/uploads/${req.file.filename}`;
    res.status(200).json({ success: true, data: imageUrl });
});

router.route('/')
    .get(getSpecialties)
    .post(createSpecialty);

router.put('/reorder', reorderSpecialties);

router.route('/:id')
    .get(getSpecialty)
    .put(updateSpecialty)
    .delete(deleteSpecialty);

module.exports = router;
