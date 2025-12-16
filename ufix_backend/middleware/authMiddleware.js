const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }

    // ✅ FIX: Create req.user object with the properties your controller expects
    req.user = {
      idUser: decoded.userId,    // Controller looks for idUser
      userId: decoded.userId,
      idPengguna: decoded.idPengguna,    // Controller also looks for userId
      email: decoded.email,
      role: decoded.role
    };

    // Keep these for compatibility if other code uses them
    req.idPengguna = decoded.idPengguna,
    req.userId = decoded.userId;
    req.userEmail = decoded.email;
    req.userRole = decoded.role;

    console.log('✅ [AUTH] User authenticated:', req.user);
    
    next();
  });
};

module.exports = { authenticateToken };