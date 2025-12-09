const { dbPromise } = require("../config/database");
const jwt = require("jsonwebtoken");

const getBookmark = async (req, res) => {
  try {
    // Pastikan Anda mendapatkan user ID dengan cara yang benar
    // Biasanya dari req.user (setelah authentication middleware)
    const idUser = req.user?.idUser || req.user?.userId;
    
    if (!idUser) {
      return res.status(401).json({
        success: false,
        message: "User tidak terautentikasi",
      });
    }

    // Konversi ke integer jika perlu
    const userId = parseInt(idUser);
    
    if (isNaN(userId)) {
      return res.status(400).json({
        success: false,
        message: "ID user tidak valid",
      });
    }

    // Perbaikan query: Hapus koma tambahan setelah "b,"
    const showBookmarkQuery = `
      SELECT 
        b.idBookmark, 
        v.idVideo, 
        v.title, 
        v.sentDate, 
        v.videoPath, 
        v.thumbnailPath,
        v.description,
        v.duration,
        v.viewCount
      FROM bookmark b
      JOIN video v ON b.idVideo = v.idVideo 
      WHERE b.idUser = ?
      ORDER BY b.createdAt DESC
    `;
    
    const [videoBookmark] = await dbPromise.query(showBookmarkQuery, [userId]);

    // Jika tidak ada bookmark, tetap return success dengan array kosong
    // (bukan error 404, karena ini kondisi normal)
    if (videoBookmark.length === 0) {
      return res.json({
        success: true,
        message: "Belum ada bookmark",
        count: 0,
        bookmark: [],
      });
    }

    res.json({
      success: true,
      count: videoBookmark.length,
      message: "Bookmark berhasil diambil",
      bookmark: videoBookmark,
    });
    
  } catch (error) {
    console.error("Error fetching bookmarks:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const addBookmark = async (req, res) => {
  try {
    // 1. Validasi input
    const idVideo = parseInt(req.params.id);
    const idUser = req.user?.idUser || req.user?.userId;

    // Validasi idVideo
    if (!idVideo || isNaN(idVideo) || idVideo <= 0) {
      return res.status(400).json({ // 400 bukan 402
        success: false,
        message: "ID video tidak valid",
      });
    }

    // Validasi user
    if (!idUser) {
      return res.status(401).json({
        success: false,
        message: "User tidak terautentikasi",
      });
    }

    const userId = parseInt(idUser);
    if (isNaN(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: "ID user tidak valid",
      });
    }

    // 2. Cek apakah video ada
    const checkVideoQuery = 'SELECT idVideo FROM video WHERE idVideo = ?';
    const [videoExists] = await dbPromise.query(checkVideoQuery, [idVideo]);
    
    if (videoExists.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video tidak ditemukan",
      });
    }

    // 3. Cek apakah bookmark sudah ada (prevent duplicate)
    const checkBookmarkQuery = 'SELECT idBookmark FROM bookmark WHERE idVideo = ? AND idUser = ?';
    const [existingBookmark] = await dbPromise.query(checkBookmarkQuery, [idVideo, userId]);
    
    if (existingBookmark.length > 0) {
      return res.status(409).json({ // 409 Conflict
        success: false,
        message: "Video sudah ada di bookmark",
      });
    }

    // 4. Tambahkan bookmark
    const addBookmarkQuery = 'INSERT INTO bookmark (idVideo, idUser) VALUES (?, ?)';
    const [result] = await dbPromise.query(addBookmarkQuery, [idVideo, userId]);

    // 5. Response dengan data yang lebih informatif
    res.status(201).json({ // 201 Created
      success: true,
      message: "Bookmark berhasil ditambahkan",
      data: {
        bookmarkId: result.insertId,
        idVideo: idVideo,
        idUser: userId
      }
    });

  } catch (error) {
    console.error("Error adding bookmark:", error);
    
    // Handle specific database errors
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: "Bookmark sudah ada",
      });
    }
    
    if (error.code === 'ER_NO_REFERENCED_ROW_2') {
      return res.status(404).json({
        success: false,
        message: "Video atau user tidak ditemukan",
      });
    }
    
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};


const deleteBookmark = async (req, res) => {
  try {
    // 1. Validasi input
    const idVideo = parseInt(req.params.id);
    const idUser = req.user?.idUser || req.user?.userId;

    // Validasi idVideo
    if (!idVideo || isNaN(idVideo) || idVideo <= 0) {
      return res.status(400).json({
        success: false,
        message: "ID video tidak valid",
      });
    }

    // Validasi user
    if (!idUser) {
      return res.status(401).json({
        success: false,
        message: "User tidak terautentikasi",
      });
    }

    const userId = parseInt(idUser);
    if (isNaN(userId) || userId <= 0) {
      return res.status(400).json({
        success: false,
        message: "ID user tidak valid",
      });
    }

    // 2. Cek apakah bookmark ada
    const checkBookmarkQuery = 'SELECT b.idBookmark, v.title FROM bookmark b JOIN video v ON b.idVideo = v.idVideo WHERE b.idVideo = ? AND b.idUser = ?';
    const [existingBookmark] = await dbPromise.query(checkBookmarkQuery, [idVideo, userId]);
    
    if (existingBookmark.length === 0) {
      return res.status(404).json({ // 404 Not Found (bukan 409 Conflict)
        success: false,
        message: "Video tidak ada di bookmark Anda",
      });
    }

    // 3. Hapus bookmark
    const deleteBookmarkQuery = 'DELETE FROM bookmark WHERE idVideo = ? AND idUser = ?'; // Hapus "*"
    const [result] = await dbPromise.query(deleteBookmarkQuery, [idVideo, userId]);

    // 4. Cek apakah berhasil dihapus
    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Gagal menghapus bookmark",
      });
    }

    // 5. Response sukses
    res.json({
      success: true,
      message: `"${existingBookmark[0].title}" berhasil dihapus dari bookmark`,
      data: {
        deletedRows: result.affectedRows,
        videoId: idVideo,
        videoTitle: existingBookmark[0].title
      }
    });

  } catch (error) {
    console.error("Error deleting bookmark:", error);
    
    // Handle specific database errors
    if (error.code === 'ER_NO_REFERENCED_ROW') {
      return res.status(400).json({
        success: false,
        message: "Data referensi tidak valid",
      });
    }
    
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};
module.exports = { getBookmark, addBookmark, deleteBookmark };
