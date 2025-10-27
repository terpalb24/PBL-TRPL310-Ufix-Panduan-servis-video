const db = require('../config/database');

const searchVideo = async (req, res) => {
    try {
        const { tag } = req.query;

        if (!tag) {
            return res.status(400).json({
                success: false,
                message: 'Masukan Tag video'
            });
        }

        const splitTags = tag.split(' ').filter(tag => tag.trim() !== '');

        const placeholders = splitTags.map(() => '?').join(', ');

        const selectQuery = `SELECT DISTINCT v.* FROM video v JOIN tagVideo tV ON tV.idVideo = v.idVideo JOIN tag t ON t.idTag = tV.idTag WHERE t.tag IN (${placeholders})`;
        
        const [videos] = await db.execute(selectQuery, splitTags);

        res.json({ 
            success: true,
            count: videos.length,
            videos: videos 
        });

    } catch (error) {
        console.error('Unexpected error in search:', error);
        res.status(500).json({
            success: false,
            message: 'Server error: ' + error.message
        });
    }
}

module.exports = { searchVideo };