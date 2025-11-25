const express = require('express');
const { getBookmark } = require('../controllers/bookmarkController');
const router = express.Router();

router.get('/get', getBookmark);

module.exports = router;