const { dbPromise } = require('../config/database'); 

const searchVideo = async (req, res) => { //Mencari Video dengan Tag
    try {
        const { tag } = req.query; //Tag Video Berupa String

        if (!tag) {
            return res.status(400).json({
                success: false,
                message: 'Masukan Tag video'
            });
        }

        const splitTags = tag.split(' ').filter(tag => tag.trim() !== ''); //Split Tag Per Space

        const placeholderTag = splitTags.map(() => '?').join(', '); //Turn Tags into a usable array in the query

        const selectQuery = `SELECT DISTINCT v.* FROM video v JOIN tagVideo tV ON tV.idVideo = v.idVideo JOIN tag t ON t.idTag = tV.idTag WHERE t.tag IN (${placeholderTag})`;
        
        const [rows] = await dbPromise.execute(selectQuery, splitTags); //Run query with the variables

        res.json({ 
            success: true,
            count: rows.length, //ouput via json
            videos: rows 
        });

    } catch (error) {
        console.error('Unexpected error in search:', error);
        res.status(500).json({
            success: false,
            message: 'Server error: ' + error.message
        });
    }
}

module.exports = { searchVideo }; //exporting