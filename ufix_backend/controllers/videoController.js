const db = require('../config/database');

const getVideoNew = async (req,res) => {
    try {
        const selectVideoQuery = 'SELECT title, thumbnailPath, sentDate FROM video ORDER BY sentDate DESC';

        const [videos] = await db.execute(selectVideoQuery);

        res.json({
        success: true,
        count: videos.length,
        videos: videos
        })



    } catch (error) {
        console.error('Error fetching newest videos:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
    });
}
}

module.exports = {getVideoNew};