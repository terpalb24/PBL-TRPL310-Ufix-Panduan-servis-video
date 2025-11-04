const { dbPromise } = require("../config/database");

const showBookmarks = async (req, res) => {
  try {

    const idUser = parseInt(req.query.idUser);

    
    if (!idUser || isNaN(idUser)) {
      return res.status(400).json({
        success: false,
        message: "ID user tidak valid",
      });
    }

    const showBookmarkQuery =
      "SELECT b.idBookmark, v.idVideo, v.title, v.sentDate, v.thumbnailPath  FROM bookmark b, JOIN video v ON b.idVideo = v.idVideo WHERE b.idUser = ?";
    const [videoBookmark] = await dbPromise.query(showBookmarkQuery, [idUser]);

    if (videoBookmark.length == 0) {
      return (
        res.status(404),
        json({
          success: false,
          message: "Belum ada bookmark untuk user ini",
        })
      );
    }

    res.json({
      success: true,
      count: videoBookmark.length,
      bookmark: videoBookmark,
    });
  } catch (error) {
    console.error("Error fetching newest videos:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

module.exports = { showBookmarks };
