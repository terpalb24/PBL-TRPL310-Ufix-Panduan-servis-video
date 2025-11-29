const express = require('express');
const {
  getCommentsByVideo,
  getComment,
  addComment,
  updateComment,
  deleteComment,
  getRepliesByComment,
  addReply,
  updateReply,
  deleteReply,
} = require('../controllers/commentsController');

const router = express.Router();

// Get all comments for a video
router.get('/video/:id', getCommentsByVideo);

// Get single comment
router.get('/:id', getComment);

// Create
router.post('/', addComment);

// Update
router.put('/:id', updateComment);

// Delete
router.delete('/:id', deleteComment);

// Replies
router.get('/:id/replies', getRepliesByComment);
router.post('/:id/replies', addReply);
router.put('/reply/:id', updateReply);
router.delete('/reply/:id', deleteReply);

module.exports = router;
