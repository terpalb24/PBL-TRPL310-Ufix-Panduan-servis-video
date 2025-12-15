console.log("RUNNING FILE:", __filename);


const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const adminRoutes = require('./routes/adminRoutes');
const searchRoutes = require('./routes/searchRoutes');
const videoRoutes = require('./routes/videoRoutes');
const bookmarkRoutes = require('./routes/bookmarkRoutes');
const commentsRoutes = require('./routes/commentsRoutes');
const tagRoutes = require('./routes/tagRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: '*',  // izinkan akses dari semua origin (emulator, HP fisik, dll)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/video', videoRoutes);
app.use('/api/bookmark', bookmarkRoutes);
app.use('/api/comments', commentsRoutes);
app.use('/api/tag', tagRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Server is running!' });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log('✅ Database connected!');
});