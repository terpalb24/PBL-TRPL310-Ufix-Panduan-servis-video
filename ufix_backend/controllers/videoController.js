// Add this import at the top of videoController.js
const jwt = require("jsonwebtoken");
const fs = require("fs");
const path = require("path");
const { dbPromise } = require("../config/database");

// Helper function to get correct MIME type for video files
function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const mimeTypes = {
    '.mp4': 'video/mp4',
    '.avi': 'video/avi',
    '.mov': 'video/quicktime',
    '.mkv': 'video/x-matroska',
    '.webm': 'video/webm',
    '.flv': 'video/x-flv',
    '.wmv': 'video/x-ms-wmv',
  };
  return mimeTypes[ext] || 'video/mp4'; // Default to video/mp4
}

// Helper function to fix MIME type if it's stored incorrectly
function fixMimeType(mimeType) {
  if (!mimeType || !mimeType.startsWith('video/')) {
    return 'video/mp4'; // Default fallback
  }
  return mimeType;
}

const getVideoNew = async (req, res) => {
  console.log("=== getVideoNew called ===");

  try {
    // Get the base URL for constructing full thumbnail URLs
    const baseUrl = `http://${req.get("host")}`;
    
    // Updated: Include thumbnailPath in the query
    const [videos] = await dbPromise.execute(`
      SELECT 
        idVideo, 
        title, 
        deskripsi,
        thumbnailPath,
        sentDate,
        mime_type
      FROM video 
      ORDER BY sentDate DESC
      LIMIT 20
    `);

    console.log(`Found ${videos.length} videos`);

    // Transform the data to include full thumbnail URLs
    const videosWithThumbnails = videos.map(video => {
      let thumbnailUrl = null;
      
      // Construct full thumbnail URL if thumbnailPath exists
      if (video.thumbnailPath) {
        // Check if it's already a full URL
        if (video.thumbnailPath.startsWith('http')) {
          thumbnailUrl = video.thumbnailPath;
        } else {
          // Remove leading slash if present and construct URL
          const cleanPath = video.thumbnailPath.startsWith('/') 
            ? video.thumbnailPath.substring(1) 
            : video.thumbnailPath;
          thumbnailUrl = `${baseUrl}/${cleanPath}`;
        }
      }
      
      return {
        idVideo: video.idVideo,
        title: video.title,
        deskripsi: video.deskripsi || "",
        thumbnailPath: thumbnailUrl, // Return full URL
        sentDate: video.sentDate,
        mime_type: video.mime_type
      };
    });

    console.log("Processed videos with thumbnails:", videosWithThumbnails.length);

    res.json({
      success: true,
      count: videosWithThumbnails.length,
      videos: videosWithThumbnails,
    });
  } catch (error) {
    console.error("Error in getVideoNew:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const streamVideo = async (req, res) => {
  try {
    const videoId = req.params.id;
    const token = req.query.token;

    console.log("streamVideo called for video ID:", videoId);
    console.log("Token present:", !!token);

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Stream token required",
      });
    }

    let decoded;
    try {
      // Verify the token
      decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Check if token is for video streaming
      if (decoded.type !== "video_stream") {
        throw new Error("Invalid token type");
      }

      // Check if token is for this video
      if (decoded.videoId != videoId) {
        throw new Error("Token video ID mismatch");
      }

      console.log("Token verified for user:", decoded.userId);
    } catch (tokenError) {
      console.error("Token verification failed:", tokenError.message);
      return res.status(403).json({
        success: false,
        message: "Invalid or expired stream token",
      });
    }

    // Get video details from database
    const query = "SELECT videoPath, mime_type FROM video WHERE idVideo = ?";
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    // Add to history if user is authenticated (userId from token)
    if (decoded.userId) {
      try {
        const checkHistoryQuery =
          "SELECT * FROM menonton WHERE idVideo = ? AND idPengguna = ?";
        const [existing] = await dbPromise.execute(checkHistoryQuery, [
          videoId,
          decoded.userId,
        ]);

        if (existing.length === 0) {
          const addIntoHistory =
            "INSERT INTO menonton (idVideo, idPengguna, watchedAt) VALUES (?, ?, NOW())";
          await dbPromise.execute(addIntoHistory, [videoId, decoded.userId]);
          console.log("Added to history for user:", decoded.userId);
        } else {
          const updateHistory =
            "UPDATE menonton SET watchedAt = NOW() WHERE idVideo = ? AND idPengguna = ?";
          await dbPromise.execute(updateHistory, [videoId, decoded.userId]);
          console.log("Updated history timestamp for user:", decoded.userId);
        }
      } catch (historyError) {
        console.error("Error adding to history:", historyError);
        // Don't fail video streaming if history fails
      }
    }

    // Stream the video (same logic as watchVideo)
    const video = results[0];
    // videoPath is already relative from database, use it directly
    const videoPath = path.join(process.cwd(), video.videoPath);
    
    console.log("[streamVideo] Database path:", video.videoPath);
    console.log("[streamVideo] Full path:", videoPath);
    console.log("[streamVideo] File exists:", fs.existsSync(videoPath));

    if (!fs.existsSync(videoPath)) {
      return res.status(404).json({
        success: false,
        message: "Video file not found at: " + videoPath,
      });
    }

    const stat = fs.statSync(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;

    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = end - start + 1;

      const file = fs.createReadStream(videoPath, { start, end });
      const head = {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        "Content-Type": video.mime_type,
      };

      res.writeHead(206, head);
      file.pipe(res);
    } else {
      const head = {
        "Content-Length": fileSize,
        "Content-Type": video.mime_type,
      };

      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }

    console.log("Video streaming started for ID:", videoId);
  } catch (error) {
    console.error("Error in streamVideo:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const watchVideo = async (req, res) => {
  try {
    const videoId = req.params.id;
    const userId = req.user?.userId || req.user?.idUser;

    console.log("watchVideo called for video ID:", videoId, "User ID:", userId);

    // First, check if video exists
    const query =
      "SELECT videoPath, mime_type, deskripsi FROM video WHERE idVideo = ?";
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    // Add to history if user is authenticated
    if (userId) {
      try {
        // Check if already in history (avoid duplicates or update timestamp)
        const checkHistoryQuery =
          "SELECT idMenonton FROM menonton WHERE idVideo = ? AND idPengguna = ?";
        const [existing] = await dbPromise.execute(checkHistoryQuery, [
          videoId,
          userId,
        ]);

        if (existing.length === 0) {
          // Insert new history record
          const addIntoHistory =
            "INSERT INTO menonton (idVideo, idPengguna, watchedAt) VALUES (?, ?, NOW())";
          await dbPromise.execute(addIntoHistory, [videoId, userId]);
        } else {
          // Update timestamp of existing record
          const updateHistory =
            "UPDATE menonton SET watchedAt = NOW() WHERE idVideo = ? AND idPengguna = ?";
          await dbPromise.execute(updateHistory, [videoId, userId]);
        }
      } catch (historyError) {
        console.error("Error adding to history:", historyError);
        // Don't fail the video streaming if history recording fails
      }
    }

    const video = results[0];
    // videoPath is already relative from database, use it directly
    const videoPath = path.join(process.cwd(), video.videoPath);
    
    console.log("[watchVideo] Database path:", video.videoPath);
    console.log("[watchVideo] Full path:", videoPath);
    console.log("[watchVideo] File exists:", fs.existsSync(videoPath));

    // Check if file exists
    if (!fs.existsSync(videoPath)) {
      return res.status(404).json({
        success: false,
        message: "Video file not found at: " + videoPath,
      });
    }

    const stat = fs.statSync(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;
    
    // Fix MIME type - use correct type based on file extension
    const correctMimeType = getMimeType(videoPath);
    const mimeTypeToUse = fixMimeType(video.mime_type) || correctMimeType;
    
    console.log("[streamVideo] Using MIME type:", mimeTypeToUse);

    if (range) {
      // Handle range requests for seeking
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = end - start + 1;

      const file = fs.createReadStream(videoPath, { start, end });
      const head = {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunksize,
        "Content-Type": mimeTypeToUse,
      };

      res.writeHead(206, head);
      file.pipe(res);
    } else {
      // Full video request
      const head = {
        "Content-Length": fileSize,
        "Content-Type": mimeTypeToUse,
      };

      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  } catch (error) {
    console.error("Error in watchVideo:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const getVideoUrl = async (req, res) => {
  try {
    const videoId = req.params.id;
    const userId = req.user?.userId || req.user?.idUser;
    const baseUrl = `http://${req.get("host")}`;

    console.log("getVideoUrl called for video ID:", videoId, "User ID:", userId);

    // Updated: Include thumbnailPath in the query
    const query = "SELECT idVideo, title, videoPath, deskripsi, thumbnailPath FROM video WHERE idVideo = ?";
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    const video = results[0];
    
    // Construct thumbnail URL
    let thumbnailUrl = null;
    if (video.thumbnailPath) {
      if (video.thumbnailPath.startsWith('http')) {
        thumbnailUrl = video.thumbnailPath;
      } else {
        const cleanPath = video.thumbnailPath.startsWith('/') 
          ? video.thumbnailPath.substring(1) 
          : video.thumbnailPath;
        thumbnailUrl = `${baseUrl}/${cleanPath}`;
      }
    }

    // Generate a short-lived token for video streaming
    const streamToken = jwt.sign(
      {
        videoId: video.idVideo,
        userId: userId || null,
        type: "video_stream",
        timestamp: Date.now(),
      },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    // Create the pre-signed URL
    const streamUrl = `http://${req.get("host")}/api/video/stream/${video.idVideo}?token=${streamToken}`;

    console.log("Generated stream URL for video:", video.idVideo);

    res.json({
      success: true,
      video: {
        id: video.idVideo,
        judul: video.title,
        deskripsi: video.deskripsi || "",
        thumbnailPath: thumbnailUrl, // Include thumbnail URL
        videoUrl: streamUrl,
        requiresAuth: false,
      },
    });
  } catch (error) {
    console.error("Error in getVideoUrl:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

// NEW: Get video deskripsi by ID
const getVideodeskripsi = async (req, res) => {
  try {
    const videoId = req.params.id;
    console.log("getVideodeskripsi called for video ID:", videoId);

    // Get video deskripsi
    const query =
      "SELECT idVideo, title, deskripsi FROM video WHERE idVideo = ?";
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    const video = results[0];

    res.json({
      success: true,
      video: {
        id: video.idVideo,
        title: video.title,
        deskripsi: video.deskripsi || "No deskripsi available",
      },
    });
  } catch (error) {
    console.error("Error in getVideodeskripsi:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const addVideo = async (req, res) => {
  try {
    // Debug: Log ALL received data
    console.log("=== addVideo FULL DEBUG ===");
    console.log("req.body:", JSON.stringify(req.body, null, 2));
    console.log("req.fields:", req.fields);
    console.log("All req keys:", Object.keys(req));
    console.log("req.file:", req.file);
    console.log("req.files:", Object.keys(req.files || {}));
    console.log("============================");

    const { title, deskripsi, idPengguna, durationSec } = req.body;
    const videoFile = req.files["video"] ? req.files["video"][0] : null;
    const thumbnailFile = req.files["thumbnail"]
      ? req.files["thumbnail"][0]
      : null;

    // Debug: Log extracted values
    console.log("Extracted from req.body:");
    console.log("  title:", title);
    console.log("  deskripsi:", deskripsi);
    console.log("  idPengguna:", idPengguna, "(type:", typeof idPengguna, ")");
    console.log("  durationSec:", durationSec, "(type:", typeof durationSec, ")");
    console.log("Video file:", videoFile ? videoFile.filename : "null");
    console.log("Thumbnail file:", thumbnailFile ? thumbnailFile.filename : "null");
    console.log("============================");

    // Check if required files are present
    if (!videoFile) {
      return res.status(400).json({
        success: false,
        message: "Video file is required",
      });
    }

    // Check if title is provided
    if (!title || title.trim() === "") {
      // Delete uploaded files if title is missing
      if (videoFile) fs.unlinkSync(videoFile.path);
      if (thumbnailFile) fs.unlinkSync(thumbnailFile.path);
      return res.status(400).json({
        success: false,
        message: "Title is required",
      });
    }

    // Create relative paths for database storage
    // IMPORTANT: Convert Windows backslashes to forward slashes for browser compatibility
    // Use path.posix.relative which always uses forward slashes regardless of OS
    const relativeVideoPath = path.relative(process.cwd(), videoFile.path);
    const videoPath = relativeVideoPath.split(path.sep).join('/'); // Replace ALL separators with /
    
    let thumbnailPath = null;
    if (thumbnailFile) {
      const relativeThumbnailPath = path.relative(process.cwd(), thumbnailFile.path);
      thumbnailPath = relativeThumbnailPath.split(path.sep).join('/');
    }
    
    const mime_type = videoFile.mimetype;
    
    console.log(`[addVideo] Original path separator: "${path.sep}"`);
    console.log(`[addVideo] Raw video path: ${relativeVideoPath}`);
    console.log(`[addVideo] Final video path: ${videoPath}`);
    console.log(`[addVideo] Contains backslash: ${videoPath.includes('\\')}`);
    console.log(`[addVideo] Raw thumbnail path: ${thumbnailFile ? path.relative(process.cwd(), thumbnailFile.path) : 'null'}`);
    console.log(`[addVideo] Final thumbnail path: ${thumbnailPath}`);
    console.log(`[addVideo] Original MIME type from multer: ${mime_type}`);
    console.log(`[addVideo] Fixed MIME type: ${fixMimeType(mime_type)}`);

    // Convert string values to appropriate types
    const parsedIdPengguna = idPengguna ? parseInt(idPengguna) : null;
    const parsedDurationSec = durationSec ? parseInt(durationSec) : 0;

    console.log("Parsed values for INSERT:");
    console.log("  parsedIdPengguna:", parsedIdPengguna);
    console.log("  parsedDurationSec:", parsedDurationSec);

    // UPDATED: Include deskripsi, uploader, and durationSec in the INSERT query
    // Use fixMimeType to ensure correct MIME type is stored
    const finalMimeType = fixMimeType(mime_type);
    const query = `
      INSERT INTO video (title, deskripsi, thumbnailPath, videoPath, mime_type, sentDate, uploader, durationSec)
      VALUES (?, ?, ?, ?, ?, NOW(), ?, ?)
    `;

    await dbPromise.execute(query, [
      title,
      deskripsi || null,
      thumbnailPath,
      videoPath,
      finalMimeType,
      parsedIdPengguna,
      parsedDurationSec,
    ]);

    // Get the inserted video ID
    const [result] = await dbPromise.execute("SELECT LAST_INSERT_ID() as id");

    const videoId = result && result.length > 0 ? result[0].id : null;


    res.json({
      success: true,
      message: "Video berhasil ditambahkan",
      videoId: videoId,
      videoUrl: `http://${req.get("host")}/api/video/watch/${videoId}`,
    });
  } catch (error) {
    console.error("Error adding video:", error);

    // Clean up uploaded files on error
    if (req.files) {
      for (const field in req.files) {
        for (const file of req.files[field]) {
          try {
            if (fs.existsSync(file.path)) {
              fs.unlinkSync(file.path);
            }
          } catch (unlinkError) {
            console.error("Error deleting file:", unlinkError);
          }
        }
      }
    }

    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const updateVideo = async (req, res) => {
  try {
    const id = req.params.id;
    const { title, deskripsi, durationSec, idPengguna } = req.body;
    const videoFile = req.files["video"] ? req.files["video"][0] : null;
    const thumbnailFile = req.files["thumbnail"]
      ? req.files["thumbnail"][0]
      : null;

    console.log("[updateVideo] Request body:", { title, deskripsi, durationSec, idPengguna });

    // Check if video exists
    const [existingVideo] = await dbPromise.execute(
      "SELECT videoPath, thumbnailPath FROM video WHERE idVideo = ?",
      [id]
    );

    if (existingVideo.length === 0) {
      // Clean up uploaded files if video doesn't exist
      if (videoFile && fs.existsSync(videoFile.path))
        fs.unlinkSync(videoFile.path);
      if (thumbnailFile && fs.existsSync(thumbnailFile.path))
        fs.unlinkSync(thumbnailFile.path);
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    const currentVideo = existingVideo[0];
    let videoPath = currentVideo.videoPath;
    let thumbnailPath = currentVideo.thumbnailPath;
    let mime_type = null;

    // Handle video file update
    if (videoFile) {
      // Delete old video file if exists
      if (
        currentVideo.videoPath &&
        fs.existsSync(path.join(process.cwd(), currentVideo.videoPath))
      ) {
        fs.unlinkSync(path.join(process.cwd(), currentVideo.videoPath));
      }
      const relativePath = path.relative(process.cwd(), videoFile.path);
      videoPath = relativePath.split(path.sep).join('/');
      mime_type = videoFile.mimetype;
      console.log(`[updateVideo] New video path: ${videoPath}`);
    }

    // Handle thumbnail file update
    if (thumbnailFile) {
      // Delete old thumbnail file if exists
      if (
        currentVideo.thumbnailPath &&
        fs.existsSync(path.join(process.cwd(), currentVideo.thumbnailPath))
      ) {
        fs.unlinkSync(path.join(process.cwd(), currentVideo.thumbnailPath));
      }
      const relativeThumbPath = path.relative(process.cwd(), thumbnailFile.path);
      thumbnailPath = relativeThumbPath.split(path.sep).join('/');
      console.log(`[updateVideo] New thumbnail path: ${thumbnailPath}`);
    }

    // Prepare update query based on what's being updated
    let query = "UPDATE video SET title = ?, deskripsi = ?";
    const params = [title, deskripsi || null];

    if (videoFile) {
      query += ", videoPath = ?, mime_type = ?";
      params.push(videoPath, mime_type);
    }

    if (durationSec) {
      const parsedDurationSec = parseInt(durationSec);
      query += ", durationSec = ?";
      params.push(parsedDurationSec);
    }

    // Tambah uploader jika ada
    if (idPengguna !== undefined && idPengguna !== null && idPengguna !== '') {
      const parsedIdPengguna = parseInt(idPengguna);
      query += ", uploader = ?";
      params.push(parsedIdPengguna);
    }

    if (thumbnailFile) {
      query += ", thumbnailPath = ?";
      params.push(thumbnailPath);
    }

    query += " WHERE idVideo = ?";
    params.push(id);

    await dbPromise.execute(query, params);

    res.json({
      success: true,
      message: "Video berhasil diperbarui",
      videoId: id,
      videoUrl: `http://${req.get("host")}/api/video/watch/${id}`,
    });
  } catch (error) {
    console.error("Error updating video:", error);

    // Clean up uploaded files on error
    if (req.files) {
      for (const field in req.files) {
        for (const file of req.files[field]) {
          try {
            if (fs.existsSync(file.path)) {
              fs.unlinkSync(file.path);
            }
          } catch (unlinkError) {
            console.error("Error deleting file:", unlinkError);
          }
        }
      }
    }

    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

const deleteVideo = async (req, res) => {
  try {
    const id = req.params.id;

    // Get video details before deleting from database
    const [videoResults] = await dbPromise.execute(
      "SELECT videoPath, thumbnailPath FROM video WHERE idVideo = ?",
      [id]
    );

    if (videoResults.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found",
      });
    }

    const video = videoResults[0];

    // Delete the video from database first
    const query = "DELETE FROM video WHERE idVideo = ?";
    await dbPromise.execute(query, [id]);

    // Delete the physical files
    const filesToDelete = [];

    if (
      video.videoPath &&
      fs.existsSync(path.join(process.cwd(), video.videoPath))
    ) {
      filesToDelete.push(
        fs.promises.unlink(path.join(process.cwd(), video.videoPath))
      );
    }

    if (
      video.thumbnailPath &&
      fs.existsSync(path.join(process.cwd(), video.thumbnailPath))
    ) {
      filesToDelete.push(
        fs.promises.unlink(path.join(process.cwd(), video.thumbnailPath))
      );
    }

    // Wait for all file deletions to complete
    await Promise.allSettled(filesToDelete);

    res.json({
      success: true,
      message: "Video berhasil dihapus",
    });
  } catch (error) {
    console.error("Error deleting video:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

// Helper function to get all videos (optional)
const getAllVideos = async (req, res) => {
  try {
    // UPDATED: Include deskripsi in the SELECT query
    const query =
      "SELECT idVideo, title, deskripsi, thumbnailPath, videoPath, mime_type, sentDate FROM video ORDER BY sentDate DESC";
    const [videos] = await dbPromise.execute(query);

    const videosWithUrls = videos.map((video) => ({
      id: video.idVideo,
      title: video.title,
      deskripsi: video.deskripsi || "", // Include deskripsi
      thumbnailUrl: video.thumbnailPath
        ? `http://${req.get("host")}/${video.thumbnailPath}`
        : null,
      videoUrl: `http://${req.get("host")}/api/video/watch/${video.idVideo}`,
      mime_type: video.mime_type,
      sentDate: video.sentDate,
    }));

    res.json({
      success: true,
      videos: videosWithUrls,
    });
  } catch (error) {
    console.error("Error getting videos:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message,
    });
  }
};

module.exports = {
  getVideoNew,
  getVideoUrl,
  streamVideo,
  watchVideo,
  getVideodeskripsi, // NEW: Export the new function
  addVideo,
  updateVideo,
  deleteVideo,
  getAllVideos,
};
