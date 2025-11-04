const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { dbPromise } = require('../config/database'); 


const signUp = async (req, res) => {
  try {
    const { email, displayName, password } = req.body;

    if (!email || !displayName || !password) {
      return res.status(400).json({
        success: false,
        message: 'Masukan Email, Display Name, Dan Password'
      });
    }

    // Check if user exists using promise
    const checkUserQuery = 'SELECT * FROM pengguna WHERE email = ?';
    const [users] = await dbPromise.query(checkUserQuery, [email]);
    
    if (users.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Telah ada pengguna dengan email yang sama'
      });
    }

    // Insert new user
    const insertQuery = 'INSERT INTO pengguna (email, displayName, password) VALUES (?, ?, ?)';
    const [result] = await dbPromise.query(insertQuery, [email, displayName, hashedPassword]);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: {
        id: result.insertId,
        displayName: displayName,
        email: email
      }
    });

  } catch (error) {
    console.error('Error in register:', error);
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

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Find user by email using promises
    const findUserQuery = 'SELECT * FROM users WHERE email = ?';
    const [results] = await dbPromise.execute(findUserQuery, [email]);

    if (results.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const user = results[0];

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};

// Get user profile (protected route)
const getProfile = (req, res) => {
  const userId = req.userId;

  const query = 'SELECT id, username, email, created_at FROM users WHERE id = ?';
  db.query(query, [userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
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