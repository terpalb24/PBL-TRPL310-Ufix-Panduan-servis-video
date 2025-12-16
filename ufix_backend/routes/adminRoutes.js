const express = require("express");
const router = express.Router();
const {
  getAllUsers,
  getUserById,
  createUserByAdmin,
  updateUser,
  deleteUser
} = require("../controllers/adminController");

const { authenticateToken } = require("../middleware/authMiddleware");
const { adminOnly } = require("../middleware/roleGuard");

// Semua route admin harus lewat middleware ini:
router.use(authenticateToken, adminOnly);

router.get("/users", getAllUsers);
router.get("/users/:id", getUserById);
router.post("/users", createUserByAdmin);
router.put("/users/:id", updateUser);
router.delete("/users/:id", deleteUser);

module.exports = router;
