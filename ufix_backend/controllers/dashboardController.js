const dashboard = async (req, res) => {
  res.json({
    success: true,
    message: "Dashboard overview",
    user: {
      id: req.userId,
      role: req.role,
    },
  });
};

module.exports = dashboard;
