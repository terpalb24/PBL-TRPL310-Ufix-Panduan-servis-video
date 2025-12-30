const express = require('express');
const { getAllHistory, getHistorySingleUser, deleteHistoryForSingleUser } = require('../controllers/historyController');
const { authenticateToken } = require('../middleware/authMiddleware');
const router = express.Router();

// Admin route - No auth for now (add admin middleware later)
router.get('/admin/all', getAllHistory);

// User routes - Require authentication
router.get('/', authenticateToken, getHistorySingleUser);
router.delete('/', authenticateToken, deleteHistoryForSingleUser);

module.exports = router;