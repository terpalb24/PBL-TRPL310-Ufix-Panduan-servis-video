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

    req.userId = decoded.userId;
    req.role = decoded.role;
    req.platform = decoded.platform;

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
