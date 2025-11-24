const db = require("../config/database");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { dbPromise } = require("../config/database");

//REGISTER 
const signUp = async (req, res) => {
  try {
    const { email, displayName, password } = req.body;

    if (!email || !displayName || !password) {
      return res.status(400).json({
        success: false,
        message: "Masukan Email, Nama Tampilan, Dan Kata Sandi",
      });
    }

    // Check email sudah ada atau belum
    const checkUserQuery = "SELECT * FROM users WHERE email = ?";
    const [users] = await dbPromise.query(checkUserQuery, [email]);

    if (users.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Telah ada pengguna dengan email yang sama.",
      });
    }

    // Hash password dengan SHA-256
    const hashedPassword = crypto
      .createHash("sha256")
      .update(password)
      .digest("hex");

    // Insert user baru
    const insertQuery =
      "INSERT INTO users (email, displayName, password) VALUES (?, ?, ?)";
    const [result] = await dbPromise.query(insertQuery, [
      email,
      displayName,
      hashedPassword,
    ]);

    res.status(201).json({
      success: true,
      message: "Pengguna Berhasil Terdaftar",
      user: {
        id: result.insertId,
        displayName,
        email,
      },
    });
  } catch (error) {
    console.error("Error in register:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

//LOGIN
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Silakan Masukkan Email dan Password Anda.",
      });
    }

    const findUserQuery = "SELECT * FROM users WHERE email = ?";
    const [results] = await dbPromise.query(findUserQuery, [email]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Email tidak ditemukan.",
      });
    }

    const user = results[0];

    // Hash password input
    const hashedInput = crypto
      .createHash("sha256")
      .update(password)
      .digest("hex");

    // Cocokkan
    if (hashedInput !== user.password) {
      return res.status(401).json({
        success: false,
        message: "Email atau Password Tidak Sesuai.",
      });
    }

    const secret = process.env.JWT_SECRET || "default_secret";

    const token = jwt.sign(
      { user_Id: user.id, email: user.email },
      secret,
      { expiresIn: "24h" }
    );

    res.status(200).json({
      success: true,
      message: "Berhasil Masuk",
      token,
      user: {
        id: user.id,
        displayName: user.displayName,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("Unexpected error in login:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

//GET PROFILE
const getProfile = (req, res) => {
  const userId = req.userId;

  const query =
    "SELECT id, displayName, email, created_at FROM users WHERE id = ?";
  db.query(query, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna Tidak Terdaftar.",
      });
    }

    res.json({
      success: true,
      user: results[0],
    });
  });
};

//LOGOUT
const logout = (req, res) => {
  try {
    // Kalau mau lebih aman, bisa blacklist token di sini
    res.status(200).json({
      success: true,
      message: "Logout berhasil.",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

module.exports = {
  signUp,
  login,
  getProfile,
  logout,
};
