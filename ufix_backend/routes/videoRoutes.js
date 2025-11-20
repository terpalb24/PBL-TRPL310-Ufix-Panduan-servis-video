const express = require('express');
const { getVideoNew, getVideoUrl, watchVideo } = require('../controllers/videoController');
const router = express.Router();

router.get('/new', getVideoNew);
router.get('/url', getVideoUrl);
router.get('/watch', watchVideo)

module.exports = router;