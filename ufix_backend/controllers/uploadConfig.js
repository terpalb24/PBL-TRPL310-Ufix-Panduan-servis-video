const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directories exist
const videoUploadPath = 'uploads/videos';
const thumbnailUploadPath = 'uploads/thumbnails';

// Create directories if they don't exist
[videoUploadPath, thumbnailUploadPath].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Configure storage for videos
const videoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.fieldname === 'video') {
      cb(null, videoUploadPath);
    } else if (file.fieldname === 'thumbnail') {
      cb(null, thumbnailUploadPath);
    } else {
      cb(new Error('Invalid fieldname'), null);
    }
  },
  filename: (req, file, cb) => {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

// File filter to accept only video and image files
const fileFilter = (req, file, cb) => {
  if (file.fieldname === 'video') {
    // Accept video files
    if (file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only video files are allowed for the video field'), false);
    }
  } else if (file.fieldname === 'thumbnail') {
    // Accept image files for thumbnail
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed for the thumbnail field'), false);
    }
  } else {
    cb(new Error('Unexpected field'), false);
  }
};

const upload = multer({
  storage: videoStorage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 500 * 1024 * 1024, // 500MB limit for videos
  }
});

module.exports = { upload, videoUploadPath, thumbnailUploadPath };