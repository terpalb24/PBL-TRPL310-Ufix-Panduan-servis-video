const express = require('express');
const { searchVideo } = require('../controllers/searchController');
const router = express.Router();

router.get('/', searchVideo);

module.exports = router;