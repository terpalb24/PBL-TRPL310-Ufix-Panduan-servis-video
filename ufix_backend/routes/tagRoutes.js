const express = require('express');
const router = express.Router();
const tagController = require('../controllers/tagController');

// Apply middleware if needed (e.g., authentication)
// const { authenticate, authorize } = require('../middlewares/auth');

/**
 * @route   GET /api/tags
 * @desc    Get all tags
 * @access  Public
 */
router.get('/get', tagController.getAllTags);

/**
 * @route   POST /api/tags
 * @desc    Create a new tag
 * @access  Private (if needed)
 */
router.post('/create', tagController.newTag); // Note: pembuat should come from auth token, not params

/**
 * @route   POST /api/tags/video
 * @desc    Add tag to video
 * @access  Private (if needed)
 */
router.post('/video', tagController.addTagToVideo);

/**
 * @route   PUT /api/tags/:idTag
 * @desc    Update a tag
 * @access  Private (creator only)
 */
router.put('/update/:idTag', tagController.updateTag);

/**
 * @route   DELETE /api/tags/:idTag
 * @desc    Delete a tag
 * @access  Private (creator/admin only)
 */
router.delete('/delete/:idTag', tagController.deleteTag);

module.exports = router;