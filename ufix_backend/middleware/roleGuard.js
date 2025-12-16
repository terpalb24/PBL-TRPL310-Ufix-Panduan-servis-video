// lib/middleware/roleGuard.js

// Khusus MOBILE → appuser
const mobileOnly = (req, res, next) => {
  if (req.user.role !== "appuser") {
    return res.status(403).json({
      success: false,
      message: "Akses ditolak: hanya untuk pengguna mobile",
    });
  }
  next();
};

// Khusus WEB > admin
const adminOnly = (req, res, next) => {
  if (req.user.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "Akses khusus admin",
    });
  }
  next();
};



module.exports = {
  mobileOnly,
  adminOnly,
};
