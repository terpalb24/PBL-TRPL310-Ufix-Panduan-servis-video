const express = require("express");
const router = express.Router();

const dashboardController = require("../controllers/dashboardController");

const { authenticateToken } = require("../middleware/authMiddleware");
const { adminOnly } = require("../middleware/roleGuard");

// KHUSUS WEB
router.get(
  "/dashboard",
  authenticateToken,
  adminOnly,
  dashboardController
);

module.exports = router;
