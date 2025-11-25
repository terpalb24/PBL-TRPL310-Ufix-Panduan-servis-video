const db = require("../config/database");
const fs = require("fs");
const path = require("path");
const { dbPromise } = require("../config/database");


const getVideoNew = async (req, res) => {
  try {
    const selectVideoQuery =
      "SELECT title, thumbnailPath, sentDate FROM video ORDER BY sentDate DESC";

    const [videos] = await dbPromise.execute(selectVideoQuery);

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

const watchVideo = async (req, res) => { // stream function - Jauharil
  try {
    const videoId = req.params.id;
    console.log('watchVideo called for video ID:', videoId);

    const query = 'SELECT videoPath, mime_type FROM video WHERE idVideo = ?';
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    const video = results[0];
    const videoPath = path.join(__dirname, '..', video.videoPath);

    // Check if it actually exists - Jauharil
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
  } catch (error) {
    console.error('Error in watchVideo:', error);
    res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};

const getVideoUrl = async (req, res) => { // url maker - Jauharil
  try {
    const videoId = req.params.id;
    console.log('getVideoUrl called for video ID:', videoId);

    const query = 'SELECT idVideo, title, videoPath FROM video WHERE idVideo = ?';
    const [results] = await dbPromise.execute(query, [videoId]);

    if (results.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    const video = results[0];
    console.log('Found video:', video);
    
    res.json({
      success: true,
      video: {
        id: video.idVideo,
        judul: video.title,
        videoUrl: `http://${req.get('host')}/api/video/watch/${video.idVideo}`,
      }
    });
  } catch (error) {
    console.error('Error in getVideoUrl:', error);
    res.status(500).json({
      success: false,
      message: 'Server error: ' + error.message
    });
  }
};
module.exports = { getVideoNew, watchVideo, getVideoUrl };
