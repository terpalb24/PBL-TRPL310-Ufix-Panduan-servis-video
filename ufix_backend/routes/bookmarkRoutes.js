// routes/bookmarkRoutes.js - FIXED
const express = require('express');
const { getBookmark, addBookmark, deleteBookmark } = require('../controllers/bookmarkController');
const { authenticateToken } = require('../middleware/authMiddleware'); // 👈 Destructure the function
const router = express.Router();

router.get('/get', authenticateToken, getBookmark); // 👈 Use authenticateToken instead of authMiddleware
router.post('/:id', authenticateToken, addBookmark);
router.delete('/:id', authenticateToken, deleteBookmark);

module.exports = router;