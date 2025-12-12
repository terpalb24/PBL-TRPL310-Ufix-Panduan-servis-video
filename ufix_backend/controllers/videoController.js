const fs = require("fs"); // removed db import because it was unused
const path = require("path");
const { dbPromise } = require("../config/database");
const { videoUploadPath, thumbnailUploadPath } = require('./uploadConfig');


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
    const { title } = req.body;
    const videoFile = req.files['video'] ? req.files['video'][0] : null;
    const thumbnailFile = req.files['thumbnail'] ? req.files['thumbnail'][0] : null;

    // Check if required files are present
    if (!videoFile) {
      return res.status(400).json({ 
        success: false, 
        message: "Video file is required" 
      });
    }

    // Check if title is provided
    if (!title || title.trim() === '') {
      // Delete uploaded files if title is missing
      if (videoFile) await fs.unlink(videoFile.path);
      if (thumbnailFile) await fs.unlink(thumbnailFile.path);
      return res.status(400).json({ 
        success: false, 
        message: "Title is required" 
      });
    }

    // Create relative paths for database storage
    const videoPath = path.relative(process.cwd(), videoFile.path);
    const thumbnailPath = thumbnailFile ? path.relative(process.cwd(), thumbnailFile.path) : null;
    const mime_type = videoFile.mimetype;

    const query = `
      INSERT INTO video (title, thumbnailPath, videoPath, mime_type, sentDate)
      VALUES (?, ?, ?, ?, NOW())
    `;

    await dbPromise.execute(query, [title, thumbnailPath, videoPath, mime_type]);

    // Get the inserted video ID
    const [result] = await dbPromise.execute('SELECT LAST_INSERT_ID() as id');
    const videoId = result[0].id;

    res.json({
      success: true,
      message: "Video berhasil ditambahkan",
      videoId: videoId,
      videoUrl: `http://${req.get('host')}/api/video/watch/${videoId}`
    });
  } catch (error) {
    console.error("Error adding video:", error);
    
    // Clean up uploaded files on error
    if (req.files) {
      for (const field in req.files) {
        for (const file of req.files[field]) {
          try {
            await fs.unlink(file.path);
          } catch (unlinkError) {
            console.error("Error deleting file:", unlinkError);
          }
        }
      }
    }
    
    res.status(500).json({ 
      success: false, 
      message: "Server error: " + error.message 
    });
  }
};

const updateVideo = async (req, res) => {
  try {
    const id = req.params.id;
    const { title } = req.body;
    const videoFile = req.files['video'] ? req.files['video'][0] : null;
    const thumbnailFile = req.files['thumbnail'] ? req.files['thumbnail'][0] : null;

    // Check if video exists
    const [existingVideo] = await dbPromise.execute(
      'SELECT videoPath, thumbnailPath FROM video WHERE idVideo = ?',
      [id]
    );

    if (existingVideo.length === 0) {
      // Clean up uploaded files if video doesn't exist
      if (videoFile) await fs.unlink(videoFile.path);
      if (thumbnailFile) await fs.unlink(thumbnailFile.path);
      return res.status(404).json({ 
        success: false, 
        message: "Video not found" 
      });
    }

    const currentVideo = existingVideo[0];
    let videoPath = currentVideo.videoPath;
    let thumbnailPath = currentVideo.thumbnailPath;
    let mime_type = null;

    // Handle video file update
    if (videoFile) {
      // Delete old video file if exists
      if (currentVideo.videoPath && fsSync.existsSync(currentVideo.videoPath)) {
        await fs.unlink(currentVideo.videoPath);
      }
      videoPath = path.relative(process.cwd(), videoFile.path);
      mime_type = videoFile.mimetype;
    }

    // Handle thumbnail file update
    if (thumbnailFile) {
      // Delete old thumbnail file if exists
      if (currentVideo.thumbnailPath && fsSync.existsSync(currentVideo.thumbnailPath)) {
        await fs.unlink(currentVideo.thumbnailPath);
      }
      thumbnailPath = path.relative(process.cwd(), thumbnailFile.path);
    }

    // Prepare update query based on what's being updated
    let query = 'UPDATE video SET title = ?';
    const params = [title];

    if (videoFile) {
      query += ', videoPath = ?, mime_type = ?';
      params.push(videoPath, mime_type);
    }

    if (thumbnailFile) {
      query += ', thumbnailPath = ?';
      params.push(thumbnailPath);
    }

    query += ' WHERE idVideo = ?';
    params.push(id);

    await dbPromise.execute(query, params);

    res.json({
      success: true,
      message: "Video berhasil diperbarui",
      videoId: id,
      videoUrl: `http://${req.get('host')}/api/video/watch/${id}`
    });
  } catch (error) {
    console.error("Error updating video:", error);
    
    // Clean up uploaded files on error
    if (req.files) {
      for (const field in req.files) {
        for (const file of req.files[field]) {
          try {
            await fs.unlink(file.path);
          } catch (unlinkError) {
            console.error("Error deleting file:", unlinkError);
          }
        }
      }
    }
    
    res.status(500).json({ 
      success: false, 
      message: "Server error: " + error.message 
    });
  }
};

const deleteVideo = async (req, res) => {
  try {
    const id = req.params.id;

    // Get video details before deleting from database
    const [videoResults] = await dbPromise.execute(
      'SELECT videoPath, thumbnailPath FROM video WHERE idVideo = ?',
      [id]
    );

    if (videoResults.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Video not found"
      });
    }

    const video = videoResults[0];

    // Delete the video from database first
    const query = "DELETE FROM video WHERE idVideo = ?";
    await dbPromise.execute(query, [id]);

    // Delete the physical files
    const filesToDelete = [];
    
    if (video.videoPath && fsSync.existsSync(video.videoPath)) {
      filesToDelete.push(fs.unlink(video.videoPath));
    }
    
    if (video.thumbnailPath && fsSync.existsSync(video.thumbnailPath)) {
      filesToDelete.push(fs.unlink(video.thumbnailPath));
    }

    // Wait for all file deletions to complete
    await Promise.allSettled(filesToDelete);

    res.json({
      success: true,
      message: "Video berhasil dihapus"
    });
  } catch (error) {
    console.error("Error deleting video:", error);
    res.status(500).json({ 
      success: false, 
      message: "Server error: " + error.message 
    });
  }
};

// Helper function to get all videos (optional)
const getAllVideos = async (req, res) => {
  try {
    const query = 'SELECT idVideo, title, thumbnailPath, videoPath, mime_type, sentDate FROM video ORDER BY sentDate DESC';
    const [videos] = await dbPromise.execute(query);

    const videosWithUrls = videos.map(video => ({
      id: video.idVideo,
      title: video.title,
      thumbnailUrl: video.thumbnailPath ? `http://${req.get('host')}/${video.thumbnailPath}` : null,
      videoUrl: `http://${req.get('host')}/api/video/watch/${video.idVideo}`,
      mime_type: video.mime_type,
      sentDate: video.sentDate
    }));

    res.json({
      success: true,
      videos: videosWithUrls
    });
  } catch (error) {
    console.error("Error getting videos:", error);
    res.status(500).json({ 
      success: false, 
      message: "Server error: " + error.message 
    });
  }
};

 
module.exports = { getVideoNew, watchVideo, getVideoUrl, addVideo, updateVideo, deleteVideo, getAllVideos};
