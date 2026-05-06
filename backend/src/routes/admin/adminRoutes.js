const express = require('express');
const { getAdmins, createAdmin, updateAdmin, deleteAdmin, getActivityLog } = require('../../controllers/admin/adminController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin);

router.get('/activity-log', getActivityLog);

router.route('/')
    .get(getAdmins)
    .post(createAdmin);

router.route('/:id')
    .put(updateAdmin)
    .delete(deleteAdmin);

module.exports = router;
