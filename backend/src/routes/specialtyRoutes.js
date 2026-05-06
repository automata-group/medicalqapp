const express = require('express');
const {
    getAllSpecialties,
    getSpecialty,
    updateUserSpecialties,
    getUserSpecialties,
    updateStudySettings,
    getStudySettings,
    removeUserSpecialty
} = require('../controllers/specialtyController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Public routes
router.get('/specialties', getAllSpecialties);
router.get('/specialties/:id', getSpecialty);

// Private User Routes
router.post('/user/specialties', protect, updateUserSpecialties);
router.get('/user/specialties', protect, getUserSpecialties);
router.put('/user/study-settings', protect, updateStudySettings);
router.get('/user/study-settings', protect, getStudySettings);
router.delete('/user/specialties/:id', protect, removeUserSpecialty);

module.exports = router;
