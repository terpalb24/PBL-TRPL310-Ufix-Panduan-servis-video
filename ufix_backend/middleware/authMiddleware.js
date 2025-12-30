const jwt = require("jsonwebtoken");

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "Token tidak ditemukan",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || "default_secret"
    );

    // ✅ FIX: Create req.user object with the properties your controller expects
    req.user = {
      idUser: decoded.userId,    // Controller looks for idUser
      userId: decoded.userId,    // Controller also looks for userId
      email: decoded.email,
      role: decoded.role
    };

    // Keep these for compatibility if other code uses them
    req.userId = decoded.userId;
    req.role = decoded.role;
    req.platform = decoded.platform;

    console.log('✅ [AUTH] User authenticated:', req.user);
    
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "Token tidak valid",
    });
  }
};


module.exports = {
  authenticateToken,
};
