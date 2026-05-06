const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.post('/save', sessionController.saveSession);
router.get('/active', sessionController.getActiveSession);
router.delete('/clear', sessionController.deleteSession);

module.exports = router;
