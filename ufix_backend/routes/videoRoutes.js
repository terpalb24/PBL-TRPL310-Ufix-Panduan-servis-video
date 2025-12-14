const express = require('express');
const { getVideoNew, getVideoUrl, watchVideo, addVideo, updateVideo, deleteVideo } = require('../controllers/videoController');
const router = express.Router();

router.get('/new', getVideoNew);
router.get('/url/:id', getVideoUrl);
router.get('/watch/:id', watchVideo);
// For adding new video with file upload
router.post('/video', upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), addVideo);

// For updating video with optional file upload
router.put('/video/:id', upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), updateVideo);

// Other routes remain the same
router.delete('/video/:id', deleteVideo);


module.exports = router;