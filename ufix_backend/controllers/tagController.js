const { dbPromise } = require("../config/database");

const getAllTags = async (req, res) => {
  try {
    const getAllTagsQuery = "SELECT * FROM tag";
    const [tags] = await dbPromise.query(getAllTagsQuery); // Fixed: added 'const'

    if (!tags || tags.length === 0) { // Better null/undefined check
      return res.status(404).json({ // Changed to 404 (Not Found), not 500
        success: false,
        message: "Belum ada Tag untuk ditampilkan",
      });
    }

    return res.json({ // Added return for consistency
      success: true,
      count: tags.length,
      tags: tags, // Fixed variable name consistency
    });
  } catch (error) {
    console.error("Error in getAllTags:", error);
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const addTagToVideo = async (req, res) => {
  try {
    const { idTag, idVideo } = req.body; // Fixed: use object destructuring

    if (!idVideo || !idTag) { // Fixed: use || not | (bitwise OR)
      return res.status(400).json({
        success: false,
        message: "Masukan Tag dan video",
      });
    }

    // Check if video exists
    const [videoCheck] = await dbPromise.query(
      "SELECT idVideo FROM video WHERE idVideo = ?",
      [idVideo]
    );

    if (videoCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video tidak ditemukan",
      });
    }

    // Check if tag exists
    const [tagCheck] = await dbPromise.query(
      "SELECT idTag FROM tag WHERE idTag = ?",
      [idTag]
    );

    if (tagCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Tag tidak ditemukan",
      });
    }

    // Check if tag already assigned to video (prevent duplicates)
    const [existingRelation] = await dbPromise.query(
      "SELECT * FROM tagVideo WHERE idVideo = ? AND idTag = ?",
      [idVideo, idTag]
    );

    if (existingRelation.length > 0) {
      return res.status(409).json({ // 409 Conflict
        success: false,
        message: "Tag sudah ditambahkan ke video ini sebelumnya",
      });
    }

    const addTagToVideoQuery =
      "INSERT INTO tagVideo (idVideo, idTag) VALUES (?, ?)";
    await dbPromise.query(addTagToVideoQuery, [idVideo, idTag]); // Fixed parameter order

    return res.status(201).json({ // 201 Created
      success: true,
      message: "Tag berhasil ditambahkan kedalam video",
      data: {
        idVideo,
        idTag
      }
    });
  } catch (error) {
    console.error("Error in addTagToVideo:", error);
    
    // Handle duplicate entry error (if you have unique constraint)
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: "Tag sudah ditambahkan ke video ini",
      });
    }
    
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const newTag = async (req, res) => {
  try {
    const pembuat = req.params.pembuat;
    const { tag } = req.body; // Fixed: use object destructuring

    if (!pembuat || pembuat.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Anda Belum Login",
      });
    }

    if (!tag || tag.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Masukan Tag",
      });
    }

    // Check if tag already exists
    const [existingTag] = await dbPromise.query(
      "SELECT idTag FROM tag WHERE tag = ?",
      [tag]
    );

    if (existingTag.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Tag sudah ada",
      });
    }

    const newTagQuery = "INSERT INTO tag (tag, pembuat) VALUES (?, ?)";
    const [result] = await dbPromise.query(newTagQuery, [tag, pembuat]);

    return res.status(201).json({
      success: true,
      message: "Tag Berhasil Dibuat",
      data: {
        idTag: result.insertId,
        tag,
        pembuat
      }
    });
  } catch (error) {
    console.error("Error in newTag:", error);
    
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: "Tag sudah ada",
      });
    }
    
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const updateTag = async (req, res) => {
  try {
    const { idTag } = req.params; // Get from params
    const { pembuat, tag } = req.body; // Get pembuat from body, not params

    if (!idTag) {
      return res.status(400).json({
        success: false,
        message: "Tag Belum Dipilih",
      });
    }

    if (!pembuat || pembuat.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Anda Belum Login",
      });
    }

    if (!tag || tag.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Masukan Tag baru",
      });
    }

    // Check if tag exists
    const [existingTag] = await dbPromise.query(
      "SELECT * FROM tag WHERE idTag = ?",
      [idTag]
    );

    if (existingTag.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Tag tidak ditemukan",
      });
    }

    // Check if user is authorized to update (optional security)
    // If pembuat should match the creator of the tag
    if (existingTag[0].pembuat !== pembuat) {
      return res.status(403).json({
        success: false,
        message: "Anda tidak memiliki izin untuk mengubah tag ini",
      });
    }

    // Check if new tag name already exists (excluding current tag)
    const [duplicateTag] = await dbPromise.query(
      "SELECT idTag FROM tag WHERE tag = ? AND idTag != ?",
      [tag, idTag]
    );

    if (duplicateTag.length > 0) {
      return res.status(409).json({
        success: false,
        message: "Tag dengan nama tersebut sudah ada",
      });
    }

    const updateTagQuery = "UPDATE tag SET tag = ? WHERE idTag = ?";
    await dbPromise.query(updateTagQuery, [tag, idTag]);

    return res.json({
      success: true,
      message: "Tag Berhasil Diupdate",
      data: {
        idTag,
        tag,
        pembuat
      }
    });
  } catch (error) {
    console.error("Error in updateTag:", error);
    
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        success: false,
        message: "Tag dengan nama tersebut sudah ada",
      });
    }
    
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const deleteTag = async (req, res) => {
  try {
    const { idTag } = req.params; // Use params for consistency

    if (!idTag) {
      return res.status(400).json({
        success: false,
        message: "Tag Belum Dipilih",
      });
    }

    // Check if tag exists
    const [existingTag] = await dbPromise.query(
      "SELECT * FROM tag WHERE idTag = ?",
      [idTag]
    );

    if (existingTag.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Tag tidak ditemukan",
      });
    }

    // Optional: Check if tag is being used in videos
    const [tagUsage] = await dbPromise.query(
      "SELECT * FROM tagVideo WHERE idTag = ?",
      [idTag]
    );

    if (tagUsage.length > 0) {
      // Option 1: Return error if tag is in use
      return res.status(400).json({
        success: false,
        message: "Tag sedang digunakan dalam video. Hapus relasi terlebih dahulu.",
        usedInVideos: tagUsage.length
      });
      
      // Option 2: Delete cascade (if foreign key constraints allow)
      // Uncomment if you want to delete all relationships first
      // await dbPromise.query("DELETE FROM tagVideo WHERE idTag = ?", [idTag]);
    }

    const deleteTagQuery = "DELETE FROM tag WHERE idTag = ?";
    await dbPromise.query(deleteTagQuery, [idTag]);

    return res.json({
      success: true,
      message: "Tag Berhasil Dihapus",
      data: {
        idTag,
        tagName: existingTag[0].tag,
        wasUsed: tagUsage.length > 0
      }
    });
  } catch (error) {
    console.error("Error in deleteTag:", error);
    
    // Handle foreign key constraint error
    if (error.code === 'ER_ROW_IS_REFERENCED_2' || error.code === 'ER_ROW_IS_REFERENCED') {
      return res.status(400).json({
        success: false,
        message: "Tag tidak dapat dihapus karena masih digunakan dalam video",
      });
    }
    
    return res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

module.exports = { getAllTags, addTagToVideo, newTag, updateTag, deleteTag };