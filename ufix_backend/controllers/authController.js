const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register function
const signUp = async (req, res) => {
  try {
    const { email, displayName, password } = req.body;

    // Validate input
    if (!email || !displayName || !password) {
      return res.status(400).json({
        success: false,
        message: 'Masukan Email, Display Name, Dan Password'
      });
    }

    // Check if user already exists
    const checkUserQuery = 'SELECT * FROM pengguna WHERE email = ?';
    db.query(checkUserQuery, [email], async (err, results) => {
      if (err) {
        console.error('Database error in checkUserQuery:', err);
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      if (results.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Telah ada pengguna dengan email yang sama'
        });
      }

      // Hash password
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Insert new user
      const insertQuery = 'INSERT INTO pengguna (email, displayName, password) VALUES (?, ?, ?)';
      db.query(insertQuery, [email, displayName, hashedPassword], (err, results) => {
        if (err) {
          console.error('Database error in insertQuery:', err);
          return res.status(500).json({
            success: false,
            message: 'Error creating user: ' + err.message
          });
        }

        res.status(201).json({
          success: true,
          message: 'User registered successfully',
          user: {
            id: results.insertId,
            displayName: displayName,  // Fixed: use displayName, not username
            email: email
          }
        });
      });
    });

  } catch (error) {
    console.error('Unexpected error in register:', error);
    res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};
// Login function
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validasi input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Cari user berdasarkan email
    const findUserQuery = 'SELECT * FROM pengguna WHERE email = ?';
    db.query(findUserQuery, [email], async (err, results) => {
      if (err) {
        console.error('Database error in findUserQuery:', err);
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      if (results.length === 0) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password'
        });
      }

      const user = results[0];

      // Cek password
      const isPasswordValid = await bcrypt.compare(password, user.PASSWORD);
      if (!isPasswordValid) {
        return res.status(401).json({
          success: false,
          message: 'Invalid email or password'
        });
      }

      // Pastikan JWT_SECRET ada
      const secret = process.env.JWT_SECRET || 'default_secret';

      // Generate token JWT
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        secret,
        { expiresIn: '24h' }
      );

      // Kirim response sukses
      res.status(200).json({
        success: true,
        message: 'Login successful',
        token,
        user: {
          id: user.id,
          displayName: user.displayName, // sesuai kolom database
          email: user.email
        }
      });
    });

  } catch (error) {
    console.error('Unexpected error in login:', error);
    res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};

// Get user profile (protected route)
const getProfile = (req, res) => {
  const userId = req.userId;

  const query = 'SELECT id, displayName, email, created_at FROM pengguna WHERE id = ?';
  db.query(query, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna Tidak Terdaftar.'
      });
    }

    res.json({
      success: true,
      user: results[0]
    });
  });
};

module.exports = {
  signUp,
  login,
  getProfile
};