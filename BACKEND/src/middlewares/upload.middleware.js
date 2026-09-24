const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

// Ensure uploads/videos directory exists
const uploadDir = path.join(__dirname, '../../uploads/videos');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Storage Configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase() || '.mp4';
    const randomName = `video-${Date.now()}-${crypto.randomBytes(4).toString('hex')}${ext}`;
    cb(null, randomName);
  },
});

// File Filter (MIME Type & Extension Check)
const fileFilter = (req, file, cb) => {
  const allowedExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
  const ext = path.extname(file.originalname).toLowerCase();

  const allowedMimeTypes = [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-matroska',
    'video/webm',
    'application/octet-stream',
  ];

  if (allowedExtensions.includes(ext) || allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    const error = new Error('Invalid video format. Supported formats: .mp4, .mov, .avi, .mkv');
    error.statusCode = 400;
    cb(error, false);
  }
};

// Multer Upload Instance (50MB file size limit)
const uploadVideo = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50 MB
  },
});

module.exports = uploadVideo;
