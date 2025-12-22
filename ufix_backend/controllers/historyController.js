const { dbPromise } = require("../config/database");

// ADMIN ONLY: Get ALL history for ALL users
const getAllHistory = async (req, res) => {
  try {
    const historyQuery = 'SELECT m.idPengguna, v.* FROM menonton m JOIN video v ON m.idVideo = v.idVideo ORDER BY m.watchedAt DESC';
    const [allVideosInHistory] = await dbPromise.query(historyQuery);

    if (allVideosInHistory.length === 0) {
      return res.status(404).json({
        success: true,
        message: "No videos in the menonton table in the database"
      });
    }

    return res.status(200).json({
      success: true,
      message: "Videos Found!",
      videos: allVideosInHistory
    });
  } catch (error) {
    console.error("Get all history error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error"
    });
  }
};

// Get history for logged-in user
const getHistorySingleUser = async (req, res) => {
  try {
    const userId = req.user?.userId || req.user?.idUser || req.user?.idPengguna;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized",
      });
    }

    const historyQuery = 'SELECT v.*, m.watchedAt FROM menonton m JOIN video v ON m.idVideo = v.idVideo WHERE m.idPengguna = ? ORDER BY m.watchedAt DESC';
    const [videosInHistory] = await dbPromise.query(historyQuery, [userId]);

    if (videosInHistory.length === 0) {
      return res.status(200).json({
        success: true,
        message: "No videos in history for this user",
        videos: []
      });
    }

    return res.status(200).json({
      success: true,
      message: "Videos found for this user",
      videos: videosInHistory
    });
  } catch (error) {
    console.error("Get user history error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error"
    });
  }
};

const deleteHistoryForSingleUser = async (req, res) => {
  try {
    const userId = req.user?.idPengguna || req.user?.userId || req.user?.idUser;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized",
      });
    }

    const deleteHistoryQuery = 'DELETE FROM menonton WHERE idPengguna = ?';
    await dbPromise.query(deleteHistoryQuery, [userId]);

    return res.status(200).json({
      success: true,
      message: "History successfully deleted for this user"
    });
  } catch (error) {
    console.error("Delete history error:", error);
    return res.status(500).json({
      success: false,
      message: "Server error"
    });
  }
};

module.exports = { getAllHistory, getHistorySingleUser, deleteHistoryForSingleUser };