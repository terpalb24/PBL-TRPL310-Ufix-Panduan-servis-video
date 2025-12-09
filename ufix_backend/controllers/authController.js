// lib/controllers/authController.js
const db = require("../config/database");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const { dbPromise } = require("../config/database");

// SIGNUP
const signUp = async (req, res) => {
  try {
    const { email, displayName, password } = req.body;

    // validasi input
    if (!email || !displayName || !password) {
      return res.status(400).json({
        success: false,
        message: "Masukkan Email, Display Name, dan Password",
      });
    }

    // cek apakah user sudah ada
    const checkUserQuery = "SELECT * FROM users WHERE email = ?";
    const [users] = await dbPromise.query(checkUserQuery, [email]);

    if (users.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Email sudah terdaftar",
      });
    }

    // insert user baru
    const insertQuery =
      "INSERT INTO users (email, displayName, password) VALUES (?, ?, ?)";
    const [result] = await dbPromise.query(insertQuery, [
      email,
      displayName,
      password,
    ]);

    res.status(201).json({
      success: true,
      message: "User berhasil didaftarkan",
      user: {
        id: result.insertId,
        displayName,
        email,
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
    const { email, password } = req.body;
    console.log("REQ LOGIN:", req.body);


    // validasi input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Masukkan email dan password",
      });
    }

    const LoginQuery = 'SELECT idPengguna, email, PASSWORD from users where email = ? AND PASSWORD = SHA2(?, 256)';
    const [LoginData] = await dbPromise.execute(LoginQuery, [email, password]);

    if (LoginData.length > 0) {
      const user = LoginData[0];

      // generate JWT (include a standard claim `userId`)
      const token = jwt.sign(
        { userId: user.idPengguna, email: user.email },
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
        },
      });
    } else {
      return res.status(401).json({
        success: false,
        message: "Email atau password salah",
      });
    }

  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

// GET PROFILE
const getProfile = async (req, res) => {
  try {
    const userId = req.userId; // pastikan middleware auth sudah men-set req.userId

    // ambil data user
    const [results] = await dbPromise.query(
      "SELECT id, displayName, email, created_at FROM users WHERE id = ?",
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
  getProfile,
};
