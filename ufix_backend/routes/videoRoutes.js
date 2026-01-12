// routes/videoRoutes.js
const express = require('express');
const { 
  getVideoNew, 
  getVideoUrl, 
  streamVideo,    
  watchVideo,
  getVideodeskripsi, // Add this import
  addVideo, 
  updateVideo, 
  deleteVideo,
  checkVideoEncoding // NEW: Check encoding status
} = require('../controllers/videoController');
const { authenticateToken } = require('../middleware/authMiddleware');
const uploadConfig = require('../controllers/uploadConfig');
const router = express.Router();

// Log all video API requests (for debugging)
router.use((req, res, next) => {
  console.log(`[VIDEO API] ${req.method} ${req.originalUrl}`);
  next();
});

router.get('/new', getVideoNew);
router.get('/url/:id', authenticateToken, getVideoUrl);
router.get('/stream/:id', streamVideo);
router.get('/watch/:id', authenticateToken, watchVideo);

// NEW: Add route for getting video deskripsi
router.get('/deskripsi/:id', authenticateToken, getVideodeskripsi);

// Serve video dan thumbnail files - PENTING untuk load files
router.get('/file/:type/:filename', (req, res) => {
  const { type, filename } = req.params;
  const path = require('path');
  
  // Security: hanya allow 'videos' atau 'thumbnails'
  if (!['videos', 'thumbnails'].includes(type)) {
    return res.status(400).json({ message: 'Invalid file type' });
  }
  
  const filePath = path.join(__dirname, '..', 'uploads', type, filename);
  
  console.log(`[FILE SERVE] Requested: ${type}/${filename}`);
  console.log(`[FILE SERVE] Full path: ${filePath}`);
  
  res.sendFile(filePath, (err) => {
    if (err) {
      console.error(`[FILE ERROR] File not found: ${filePath}`);
      res.status(404).json({ message: 'File not found' });
    }
  });
});

// Alternative route untuk serve uploads dari path langsung
router.get('/uploads/:folder/:filename', (req, res) => {
  const { folder, filename } = req.params;
  const path = require('path');
  const fs = require('fs');
  
  // Security check
  if (!['videos', 'thumbnails'].includes(folder)) {
    return res.status(400).json({ message: 'Invalid folder' });
  }
  
  const filePath = path.join(__dirname, '..', 'uploads', folder, filename);
  
  console.log(`[UPLOADS ROUTE] Path: ${filePath}`);
  
  // Check if file exists
  if (!fs.existsSync(filePath)) {
    console.error(`[UPLOADS ERROR] File not found: ${filePath}`);
    return res.status(404).json({ message: 'File not found' });
  }
  
  res.sendFile(filePath);
});

router.post('/video', uploadConfig.upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), addVideo);

router.put('/video/:id', uploadConfig.upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), updateVideo);

router.delete('/video/:id', deleteVideo);

module.exports = router;