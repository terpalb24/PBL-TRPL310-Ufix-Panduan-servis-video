const db = require("../config/database");
const fs = require("fs");
const path = require("path");


const getVideoNew = async (req, res) => {
  try {
    const selectVideoQuery =
      "SELECT title, thumbnailPath, sentDate FROM video ORDER BY sentDate DESC";

    const [videos] = await db.execute(selectVideoQuery);

    res.json({
      success: true,
      count: videos.length,
      videos: videos,
    });
  } catch (error) {
    console.error("Error fetching newest videos:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

const watchVideo = (req, res) => {
  const videoId = req.params.id;

  // Get video info from database
  const query = 'SELECT video_path, mime_type FROM video WHERE id = ?';
  db.query(query, [videoId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    const video = results[0];
    const videoPath = path.join(__dirname, '..', video.video_path);

    // Check if file exists
    if (!fs.existsSync(videoPath)) {
      return res.status(404).json({
        success: false,
        message: 'Video file not found'
      });
    }

    const stat = fs.statSync(videoPath);
    const fileSize = stat.size;
    const range = req.headers.range;

    if (range) {
      // Handle range requests for seeking
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunksize = (end - start) + 1;

      const file = fs.createReadStream(videoPath, { start, end });
      const head = {
        'Content-Range': `bytes ${start}-${end}/${fileSize}`,
        'Accept-Ranges': 'bytes',
        'Content-Length': chunksize,
        'Content-Type': video.mime_type,
      };

      res.writeHead(206, head);
      file.pipe(res);
    } else {
      // Full video request
      const head = {
        'Content-Length': fileSize,
        'Content-Type': video.mime_type,
      };

      res.writeHead(200, head);
      fs.createReadStream(videoPath).pipe(res);
    }
  });
};

const getVideoUrl = (req, res) => {
  const videoId = req.params.id;

  const query = 'SELECT id, judul, video_path FROM video WHERE id = ?';
  db.query(query, [videoId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    const video = results[0];
    
    // Return the streaming URL
    res.json({
      success: true,
      video: {
        id: video.id,
        title: video.title,
        videoUrl: `http://${req.get('host')}/api/stream/video/${video.id}`,
      }
    });
  });
};

module.exports = { getVideoNew, watchVideo, getVideoUrl };
