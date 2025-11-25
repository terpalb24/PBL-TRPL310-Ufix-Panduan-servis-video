const express = require('express');
const { getVideoNew, getVideoUrl, watchVideo } = require('../controllers/videoController');
const router = express.Router();

router.get('/new', getVideoNew);
router.get('/url/:id', getVideoUrl);
router.get('/watch/:id', watchVideo);

module.exports = router;