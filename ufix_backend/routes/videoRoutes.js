const express = require('express');
const { 
  getVideoNew, 
  getVideoUrl, 
  streamVideo,    // Add this import
  watchVideo, 
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

// This endpoint requires auth and returns a pre-signed URL
router.get('/url/:id', authenticateToken, getVideoUrl);

// New endpoint for pre-signed URL streaming (no auth middleware required)
router.get('/stream/:id', streamVideo);

// Keep the old watch endpoint for backward compatibility
router.get('/watch/:id', authenticateToken, watchVideo);

// Use uploadConfig.fields()
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