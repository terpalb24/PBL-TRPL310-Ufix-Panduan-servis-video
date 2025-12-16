// routes/videoRoutes.js
const express = require('express');
const { getVideoNew, getVideoUrl, watchVideo, addVideo, updateVideo, deleteVideo } = require('../controllers/videoController');
const uploadConfig = require('../controllers/uploadConfig'); // This should be the multer instance
const router = express.Router();

router.get('/new', getVideoNew);
router.get('/url/:id', getVideoUrl);
router.get('/watch/:id', watchVideo);

// Use uploadConfig.upload.fields() - Note the .fields() method
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