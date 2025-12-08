const express = require('express');
const { searchVideo } = require('../controllers/searchController');
const router = express.Router();

router.post('/', searchVideo);

module.exports = router;