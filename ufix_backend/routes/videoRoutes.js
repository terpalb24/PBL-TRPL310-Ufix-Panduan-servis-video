const express = require('express');
const { getVideoNew, getVideoUrl, watchVideo, addVideo, updateVideo, deleteVideo } = require('../controllers/videoController');
const router = express.Router();

router.get('/new', getVideoNew);
router.get('/url/:id', getVideoUrl);
router.get('/watch/:id', watchVideo);
router.post('/add', addVideo);
router.put('/update/:id', updateVideo);
router.delete('/delete/:id', deleteVideo);


module.exports = router;