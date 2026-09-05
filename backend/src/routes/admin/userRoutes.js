const express = require('express');
const { 
    getUsers, 
    getUser, 
    updateUser, 
    updateUserStatus, 
    manageUserSubscription, 
    getUserActivity, 
    getUserStatistics,
    deleteUser,
    bulkDeleteUsers
} = require('../../controllers/admin/userController');
const { protect, admin } = require('../../middleware/auth');

const router = express.Router();

router.use(protect);
router.use(admin); // All routes require admin

router.get('/', getUsers);
router.get('/statistics', getUserStatistics);
router.get('/:id', getUser);
router.put('/:id', updateUser);
router.put('/:id/status', updateUserStatus);
router.put('/:id/subscription', manageUserSubscription);
router.delete('/:id', deleteUser);
router.post('/bulk-delete', bulkDeleteUsers);
router.get('/:id/activity', getUserActivity);

module.exports = router;

