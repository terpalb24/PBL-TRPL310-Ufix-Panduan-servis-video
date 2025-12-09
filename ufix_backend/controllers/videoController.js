const fs = require("fs"); // removed db import because it was unused
const path = require("path");
const { dbPromise } = require("../config/database");


const getVideoNew = async (req, res) => {
  console.log('=== getVideoNew called ===');
  
  try {
    console.log('Testing with simple count query...');
    
    // First, try a super simple query
    const [countResult] = await dbPromise.execute('SELECT COUNT(*) as count FROM video');
    console.log('Count result:', countResult[0].count);
    
    // If that works, try with just 1 field
    console.log('Testing with single field...');
    const [simpleVideos] = await dbPromise.execute('SELECT idVideo FROM video LIMIT 5');
    console.log('Simple query result:', simpleVideos);
    
    // If that works, try the full query
    console.log('Testing full query...');
    const [videos] = await dbPromise.execute(`
      SELECT idVideo, title 
      FROM video 
      LIMIT 5
    `);
    
    console.log('Full query successful, found:', videos.length, 'videos');
    
    res.json({
      success: true,
      count: videos.length,
      videos: videos,
    });
    
  } catch (error) {
    console.error("Error in getVideoNew:", error);
    res.status(500).json({
      success: false,
      message: "Server error: " + error.message
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


const addVideo = async (req, res) => {
  try {
    const { title, thumbnailPath, videoPath, mime_type } = req.body;

    const query = `
      INSERT INTO video (title, thumbnailPath, videoPath, mime_type, sentDate)
      VALUES (?, ?, ?, ?, NOW())
    `;

    await dbPromise.execute(query, [title, thumbnailPath, videoPath, mime_type]);

    res.json({
      success: true,
      message: "Video berhasil ditambahkan"
    });
  } catch (error) {
    console.error("Error adding video:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};


const updateVideo = async (req, res) => {
  try {
    const id = req.params.id;
    const { title, thumbnailPath, videoPath, mime_type } = req.body;

    const query = `
      UPDATE video
      SET title = ?, thumbnailPath = ?, videoPath = ?, mime_type = ?
      WHERE idVideo = ?
    `;

    await dbPromise.execute(query, [
      title,
      thumbnailPath,
      videoPath,
      mime_type,
      id
    ]);

    res.json({
      success: true,
      message: "Video berhasil diperbarui"
    });
  } catch (error) {
    console.error("Error updating video:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};


const deleteVideo = async (req, res) => {
  try {
    const id = req.params.id;

    const query = "DELETE FROM video WHERE idVideo = ?";
    await dbPromise.execute(query, [id]);

    res.json({
      success: true,
      message: "Video berhasil dihapus"
    });
  } catch (error) {
    console.error("Error deleting video:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
};

 
module.exports = { getVideoNew, watchVideo, getVideoUrl, addVideo, updateVideo, deleteVideo};
