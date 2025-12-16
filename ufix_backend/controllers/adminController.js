const crypto = require("crypto");
const db = require("../config/database");

// Hash SHA256
function hashPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}

// Get all users (Admin only)
const getAllUsers = async (req, res) => {
  try {
    const [rows] = await db.promise().query("SELECT idPengguna, email, displayName, role FROM users");

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error("Error getAllUsers:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

// Get single user by ID
const getUserById = async (req, res) => {
  const id = req.params.id;

  try {
    const [rows] = await db.promise().query(
      "SELECT idPengguna, email, displayName, role FROM users WHERE idPengguna = ?",
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error("Error getUserById:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

// Admin create user
const createUserByAdmin = async (req, res) => {
  const { email, displayName, role, password } = req.body;

  if (!email || !displayName || !role || !password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  const hashed = hashPassword(password);

  try {
    const query = `
      INSERT INTO users (email, displayName, role, PASSWORD)
      VALUES (?, ?, ?, ?)
    `;

    await db.promise().query(query, [email, displayName, role, hashed]);

    res.json({
      success: true,
      message: "User created successfully"
    });
  } catch (error) {
    console.error("Error createUserByAdmin:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

// Update user
// Update user
const updateUser = async (req, res) => {
  const id = req.params.id;
  const { email, displayName, role, password } = req.body;

  try {
    let query = "UPDATE users SET email=?, displayName=?, role=? WHERE idPengguna=?";
    let params = [email, displayName, role, id];

    if (password) {
      const hashed = hashPassword(password);
      query = "UPDATE users SET email=?, displayName=?, role=?, PASSWORD=? WHERE idPengguna=?";
      params = [email, displayName, role, hashed, id];
    }

    await db.promise().query(query, params);

    res.json({
      success: true,
      message: "User updated successfully"
    });
  } catch (error) {
    console.error("Error updateUser:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};


// Delete user
const deleteUser = async (req, res) => {
  const id = req.params.id;

  try {
    await db.promise().query("DELETE FROM users WHERE idPengguna = ?", [id]);

    res.json({
      success: true,
      message: "User deleted successfully"
    });
  } catch (error) {
    console.error("Error deleteUser:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  createUserByAdmin,
  updateUser,
  deleteUser
};
