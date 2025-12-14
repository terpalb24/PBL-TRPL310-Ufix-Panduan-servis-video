// lib/controllers/authController.js
const db = require("../config/database");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const { dbPromise } = require("../config/database");

// SIGNUP
const signUp = async (req, res) => {
  try {
    const { email, displayName, PASSWORD, role } = req.body;

    // validasi input
    if (!email || !displayName || !PASSWORD) {
      return res.status(400).json({
        success: false,
        message: "Masukkan Email, Display Name, dan Password",
      });
    }

    // cek apakah user sudah ada
    const [users] = await dbPromise.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (users.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Email sudah terdaftar",
      });
    }

    // HASH SEKALI (single SHA256)
    const hashedPassword = crypto
      .createHash("sha256")
      .update(PASSWORD)
      .digest("hex");

    // insert user baru
    const insertQuery =
      "INSERT INTO users (email, displayName, PASSWORD, role) VALUES (?, ?, ?, ?)";

    const [result] = await dbPromise.query(insertQuery, [
      email,
      displayName,
      hashedPassword,
      role || "appuser", // default role
    ]);

    res.status(201).json({
      success: true,
      message: "User berhasil didaftarkan",
      user: {
        id: result.insertId,
        displayName,
        email,
        role: role || "appuser",
      },
    });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

// LOGIN
const login = async (req, res) => {
  try {
    console.log("REQ BODY:", req.body);

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Masukkan email dan password",
      });
    }

    const hashed = crypto
      .createHash("sha256")
      .update(password)
      .digest("hex");

    const LoginQuery = `
      SELECT idPengguna, email, displayName, role, PASSWORD 
      FROM users 
      WHERE email = ? AND PASSWORD = ?
    `;
    const [LoginData] = await dbPromise.execute(LoginQuery, [email, hashed]);

    if (LoginData.length > 0) {
      const user = LoginData[0];

      const token = jwt.sign(
        {
          userId: user.idPengguna,
          email: user.email,
          role: user.role,
        },
        process.env.JWT_SECRET || "default_secret",
        { expiresIn: "24h" }
      );

      return res.status(200).json({
        success: true,
        message: "Login berhasil",
        token,
        user: {
          id: user.idPengguna,
          email: user.email,
          role: user.role
        },
      });
    }

    return res.status(401).json({
      success: false,
      message: "Email atau password salah",
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};


// LOGIN ADMIN (WEB)
const loginAdmin = async (req, res) => {
  try {
    console.log("REQ ADMIN LOGIN:", req.body);

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Masukkan email dan password",
      });
    }

    // Hash password
    const hashed = crypto
      .createHash("sha256")
      .update(password)
      .digest("hex");

    // Ambil user role admin
    const query = `
      SELECT idPengguna, email, displayName, role, PASSWORD
      FROM users
      WHERE email = ? AND role = 'admin'
    `;
    const [rows] = await dbPromise.query(query, [email]);

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Admin tidak ditemukan atau email tidak terdaftar sebagai admin",
      });
    }

    const admin = rows[0];

    // Cocokkan password
    if (admin.PASSWORD !== hashed) {
      return res.status(401).json({
        success: false,
        message: "Password salah",
      });
    }

    // Generate token
    const token = jwt.sign(
      {
        userId: admin.idPengguna,
        email: admin.email,
        role: admin.role,
      },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "24h" }
    );

    return res.status(200).json({
      success: true,
      message: "Login admin berhasil",
      token,
      user: {
        id: admin.idPengguna,
        email: admin.email,
        role: admin.role,
        displayName: admin.displayName,
      },
    });
  } catch (error) {
    console.error("Login admin error:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};


// GET PROFILE
const getProfile = async (req, res) => {
  try {
    const userId = req.userId;

    const [results] = await dbPromise.query(
      "SELECT idPengguna, displayName, email, role FROM users WHERE idPengguna = ?",
      [userId]
    );

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Pengguna tidak terdaftar",
      });
    }

    res.json({
      success: true,
      user: results[0],
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

module.exports = {
  signUp,
  login,
  loginAdmin,
  getProfile,
};
