const express = require('express');
const { signUp, login, getProfile, loginAdmin} = require('../controllers/authController');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Public routes
router.post('/signUp', signUp);
router.post('/login', login);

// Admin on Web
router.post('/admin/login', loginAdmin);


// Protected routes
router.get('/profile', authenticateToken, getProfile);

module.exports = router;