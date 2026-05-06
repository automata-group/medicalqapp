const express = require('express');
const router = express.Router();
const { protect, admin } = require('../middleware/auth');
const adminController = require('../controllers/adminController');

// All admin routes must be protected and restricted to admin role
router.use(protect);
router.use(admin);

// 1. Content Management
router.post('/questions/bulk', adminController.bulkUploadQuestions);
router.put('/questions/reorder', adminController.reorderQuestions);

// 2. Users & Revenue
router.get('/users', adminController.getUsers);
router.post('/users/:id/override-pro', adminController.overrideProStatus);
router.get('/revenue', adminController.getRevenueStats);

// 3. Promos
router.route('/promos')
    .get(adminController.getPromos)
    .post(adminController.createPromoCode);

// 4. Moderation
router.get('/reports', adminController.getReports);
router.post('/notifications/broadcast', adminController.sendBroadcast);

module.exports = router;
