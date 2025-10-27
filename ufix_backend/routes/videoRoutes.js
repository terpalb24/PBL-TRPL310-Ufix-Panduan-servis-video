const express = require('express');
const { getVideoNew } = require('../controllers/videoController');
const router = express.Router();

router.get('/new', getVideoNew);

module.exports = router;