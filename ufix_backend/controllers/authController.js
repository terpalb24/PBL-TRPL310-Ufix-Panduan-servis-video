const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const { dbPromise } = require("../config/database");

// Sign Up (appuser - mobile)
const signUp = async (req, res) => {
  try {

    console.log("REQ BODY SIGNUP:", req.body);
    const { email, displayName, password } = req.body;
    console.log("ROWS LOGIN WEB:", rows);

    
    if (!email || !displayName || !password) {
      return res.status(400).json({
        success: false,
        message: "Email, display name, dan password wajib diisi",
      });
    }

    // Cek email
    const [exists] = await dbPromise.query(
      "SELECT idPengguna FROM users WHERE email = ?",
      [email]
    );

    if (exists.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Email sudah terdaftar",
      });
    }

    const hashedPassword = crypto
      .createHash("sha256")
      .update(password.trim())
      .digest("hex");

    const [result] = await dbPromise.query(
      "INSERT INTO users (email, displayName, PASSWORD, role) VALUES (?, ?, ?, 'appuser')",
      [email, displayName, hashedPassword]
    );

    res.status(201).json({
      success: true,
      message: "Registrasi berhasil",
      user: {
        id: result.insertId,
        email,
        displayName,
        role: "appuser",
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Login (appuser - mobile)
const loginMobile = async (req, res) => {
  try {

    console.log("REQ BODY LOGIN MOBILE:", req.body);
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email dan password wajib diisi",
      });
    }

    const hashed = crypto
      .createHash("sha256")
      .update(password.trim())
      .digest("hex");

    const [rows] = await dbPromise.query(
      `
      SELECT idPengguna, email, displayName, role
      FROM users
      WHERE email = ?
        AND PASSWORD = ?
        AND role = 'appuser'
      `,
      [email, hashed]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Akun mobile tidak ditemukan",
      });
    }

    const user = rows[0];

    const token = jwt.sign(
      {
        userId: user.idPengguna,
        role: user.role,
        platform: "mobile",
      },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "24h" }
    );

    res.json({
      success: true,
      message: "Login mobile berhasil",
      token,
      user,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// Login (admin - Web) 
const loginWeb = async (req, res) => {
  try {
    console.log("REQ BODY LOGIN WEB:", req.body);

    const { email, password } = req.body;

    if (!email || !password) {
      console.log("LOGIN WEB ERROR: Email atau password kosong");
      return res.status(400).json({
        success: false,
        message: "Email dan password wajib diisi",
      });
    }

    const trimmedPassword = password.trim();
    const hashed = crypto.createHash("sha256").update(trimmedPassword).digest("hex");
    console.log("HASHPASSWORD LOGIN WEB:", hashed);

    const query = `
      SELECT idPengguna, email, displayName, role
      FROM users
      WHERE email = ? AND PASSWORD = ? AND role IN ('superadmin', 'admin', 'teknisi')
    `;

    const [rows] = await dbPromise.query(query, [email, hashed]);
    console.log("ROWS LOGIN WEB:", rows);

    if (rows.length === 0) {
      console.log("LOGIN WEB FAILED: User tidak ditemukan atau role salah");
      return res.status(401).json({
        success: false,
        message: "Akun tidak memiliki akses",
      });
    }
  

    const user = rows[0];

    // generate token
    const token = jwt.sign(
      {
        userId: user.idPengguna,
        role: user.role,
        platform: "web",
      },
      process.env.JWT_SECRET || "default_secret",
      { expiresIn: "24h" }
    );

    console.log("LOGIN WEB SUCCESS: User", user.email, "Role:", user.role);

    res.json({
      success: true,
      message: "Login web berhasil",
      token,
      user,
    });
  } catch (err) {
    console.error("LOGIN WEB SERVER ERROR:", err);
    res.status(500).json({
      success: false,
      message: "Terjadi kesalahan server",
      error: err.message,
    });
  }
};


// Get Profile
const getProfile = async (req, res) => {
  try {
    const userId = req.userId;

    const [rows] = await dbPromise.query(
      "SELECT idPengguna, email, displayName, role FROM users WHERE idPengguna = ?",
      [userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User tidak ditemukan",
      });
    }

    res.json({
      success: true,
      user: rows[0],
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = {
  signUp,
  loginMobile,
  loginWeb,
  getProfile,
};
