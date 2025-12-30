const { dbPromise } = require("../config/database");

const getBookmark = async (req, res) => {
  try {
    const userId = req.user?.idPengguna || req.user?.userId || req.user?.idUser;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized",
      });
    }

    const query = `
      SELECT 
        b.idBookmark, 
        v.idVideo, 
        v.title, 
        v.sentDate, 
        v.videoPath, 
        v.thumbnailPath,
        v.durationSec,
        u.displayName as uploaderName
      FROM bookmark b
      JOIN video v ON b.idVideo = v.idVideo 
      JOIN users u ON v.uploader = u.idPengguna
      WHERE b.idPengguna = ?
    `;
    
    const [bookmarks] = await dbPromise.query(query, [userId]);

    res.json({
      success: true,
      count: bookmarks.length,
      bookmarks: bookmarks,
    });
    
  } catch (error) {
    console.error("Bookmark error:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

const addBookmark = async (req, res) => {
  try {
    const videoId = parseInt(req.params.id);
    const userId = req.user?.idPengguna || req.user?.userId || req.user?.idUser;

    if (!videoId || !userId) {
      return res.status(400).json({
        success: false,
        message: "Invalid request",
      });
    }

    // Check if video exists
    const [video] = await dbPromise.query(
      'SELECT idVideo FROM video WHERE idVideo = ?',
      [videoId]
    );
    
    if (!video.length) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    // Check if already bookmarked
    const [exists] = await dbPromise.query(
      'SELECT idBookmark FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
      [videoId, userId]
    );
    
    if (exists.length > 0) {
      return res.status(200).json({
        success: true,
        message: "Already bookmarked",
      });
    }

    // Add bookmark
    const [result] = await dbPromise.query(
      'INSERT INTO bookmark (idVideo, idPengguna) VALUES (?, ?)',
      [videoId, userId]
    );

    res.status(201).json({
      success: true,
      message: "Bookmark added",
      bookmarkId: result.insertId,
    });

  } catch (error) {
    console.error("Add bookmark error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to add bookmark",
    });
  }
};

const deleteBookmark = async (req, res) => {
  try {
    const videoId = parseInt(req.params.id);
    const userId = req.user?.idPengguna || req.user?.userId || req.user?.idUser;

    if (!videoId || !userId) {
      return res.status(400).json({
        success: false,
        message: "Invalid request",
      });
    }

    const [result] = await dbPromise.query(
      'DELETE FROM bookmark WHERE idVideo = ? AND idPengguna = ?',
      [videoId, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Bookmark not found",
      });
    }

    res.json({
      success: true,
      message: "Bookmark removed",
    });

  } catch (error) {
    console.error("Delete bookmark error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to remove bookmark",
    });
  }
};

module.exports = { getBookmark, addBookmark, deleteBookmark };