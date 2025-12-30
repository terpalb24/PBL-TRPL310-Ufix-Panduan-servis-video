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
  deleteVideo 
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