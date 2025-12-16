const express = require("express");
const {
  signUp,
  loginMobile,
  loginWeb,
  getProfile,
} = require("../controllers/authController");
const { authenticateToken } = require("../middleware/authMiddleware");

const router = express.Router();

// PUBLIC ROUTES

// Signup (default appuser - mobile)
router.post("/signup", signUp);

// Login MOBILE (appuser only)
router.post("/login-mobile", loginMobile);

// Login WEB (admin & teknisi)
router.post("/login-web", loginWeb);

// PROTECTED ROUTES

// Semua role (berdasarkan token)
router.get("/profile", authenticateToken, getProfile);

module.exports = router;
