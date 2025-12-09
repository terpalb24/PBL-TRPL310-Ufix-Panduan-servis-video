const { dbPromise } = require('../config/database');

// helper: find primary key column for a table
async function findPrimaryKey(tableName) {
  const [rows] = await dbPromise.execute(
    `SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_KEY = 'PRI' LIMIT 1`,
    [tableName]
  );
  return rows.length ? rows[0] : null;
}

// Get all comments for a video
const getCommentsByVideo = async (req, res) => {
  try {
    const videoId = req.params.id;

    if (!videoId) {
      return res.status(400).json({ success: false, message: 'idVideo is required' });
    }

    // detect users primary key and join accordingly
    const usersPk = await findPrimaryKey('users');
    let rows;
    if (usersPk) {
      const pk = usersPk.COLUMN_NAME;
      const query = `
        SELECT k.idKomentar, k.sentDate, k.isi, k.idPengomentar, k.idVideo,
               u.${pk} AS pengomentarId, u.displayName AS pengomentarName
        FROM komentar k
        LEFT JOIN users u ON k.idPengomentar = u.${pk}
        WHERE k.idVideo = ?
        ORDER BY k.sentDate DESC
      `;
      [rows] = await dbPromise.execute(query, [videoId]);
    } else {
      // fallback: no users PK found, select without join
      const query = `
        SELECT k.idKomentar, k.sentDate, k.isi, k.idPengomentar, k.idVideo,
               NULL AS pengomentarId, NULL AS pengomentarName
        FROM komentar k
        WHERE k.idVideo = ?
        ORDER BY k.sentDate DESC
      `;
      [rows] = await dbPromise.execute(query, [videoId]);
    }

    res.json({ success: true, count: rows.length, comments: rows });
  } catch (error) {
    console.error('Error in getCommentsByVideo:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Get single comment by id
const getComment = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).json({ success: false, message: 'idKomentar is required' });

    // detect users PK
    const usersPk = await findPrimaryKey('users');
    let rows;
    if (usersPk) {
      const pk = usersPk.COLUMN_NAME;
      [rows] = await dbPromise.execute(
        `SELECT k.idKomentar, k.sentDate, k.isi, k.idPengomentar, k.idVideo, u.${pk} AS pengomentarId, u.displayName AS pengomentarName
         FROM komentar k
         LEFT JOIN users u ON k.idPengomentar = u.${pk}
         WHERE k.idKomentar = ?`,
        [id]
      );
    } else {
      [rows] = await dbPromise.execute(
        `SELECT k.idKomentar, k.sentDate, k.isi, k.idPengomentar, k.idVideo, NULL AS pengomentarId, NULL AS pengomentarName
         FROM komentar k
         WHERE k.idKomentar = ?`,
        [id]
      );
    }
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Comment not found' });

    res.json({ success: true, comment: rows[0] });
  } catch (error) {
    console.error('Error in getComment:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Create a new comment
const addComment = async (req, res) => {
  try {
    const { isi, idPengomentar, idVideo } = req.body;
    console.log('addComment payload:', req.body);

    if (!isi || !idVideo) {
      return res.status(400).json({ success: false, message: 'Fields "isi" and "idVideo" are required' });
    }

    // coerce idPengomentar to number or null
    const pid = idPengomentar !== undefined && idPengomentar !== null ? Number(idPengomentar) : null;
    const insertQuery = 'INSERT INTO komentar (sentDate, isi, idPengomentar, idVideo) VALUES (NOW(), ?, ?, ?)';
    const [result] = await dbPromise.execute(insertQuery, [isi, pid, idVideo]);

    console.log('addComment insertedId:', result.insertId, 'idPengomentar used:', pid);

    // return the created comment (best-effort) to help the client verify
    const [rows] = await dbPromise.execute('SELECT * FROM komentar WHERE idKomentar = ?', [result.insertId]);
    res.status(201).json({ success: true, message: 'Komentar berhasil ditambahkan', idKomentar: result.insertId, comment: rows[0] || null });
  } catch (error) {
    console.error('Error in addComment:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Update a comment's isi
const updateComment = async (req, res) => {
  try {
    const id = req.params.id;
    const { isi } = req.body;

    if (!id || !isi) {
      return res.status(400).json({ success: false, message: 'idKomentar and isi are required' });
    }

    const updateQuery = 'UPDATE komentar SET isi = ? WHERE idKomentar = ?';
    const [result] = await dbPromise.execute(updateQuery, [isi, id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Comment not found' });
    }

    res.json({ success: true, message: 'Komentar berhasil diperbarui' });
  } catch (error) {
    console.error('Error in updateComment:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Delete a comment
const deleteComment = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).json({ success: false, message: 'idKomentar is required' });

    const deleteQuery = 'DELETE FROM komentar WHERE idKomentar = ?';
    const [result] = await dbPromise.execute(deleteQuery, [id]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Comment not found' });
    }

    res.json({ success: true, message: 'Komentar berhasil dihapus' });
  } catch (error) {
    console.error('Error in deleteComment:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Replies: get replies for a comment
const getRepliesByComment = async (req, res) => {
  try {
    const idKomentar = req.params.id;
    if (!idKomentar) return res.status(400).json({ success: false, message: 'idKomentar is required' });

    // detect users PK
    const usersPk = await findPrimaryKey('users');
    let rows;
    if (usersPk) {
      const pk = usersPk.COLUMN_NAME;
      // include parentReplyId and reply-to author's name (if any)
      const query = `
        SELECT r.idReply, r.sentDate, r.isi, r.idPengirim, r.idKomentar, r.parentReplyId,
               u.${pk} AS pengirimId, u.displayName AS pengirimName,
               upr.${pk} AS replyToId, upr.displayName AS replyToName
        FROM reply r
        LEFT JOIN users u ON r.idPengirim = u.${pk}
        LEFT JOIN reply rp ON r.parentReplyId = rp.idReply
        LEFT JOIN users upr ON rp.idPengirim = upr.${pk}
        WHERE r.idKomentar = ?
        ORDER BY r.sentDate ASC
      `;
      [rows] = await dbPromise.execute(query, [idKomentar]);
    } else {
      const query = `
        SELECT r.idReply, r.sentDate, r.isi, r.idPengirim, r.idKomentar, r.parentReplyId,
               NULL AS pengirimId, NULL AS pengirimName, NULL AS replyToId, NULL AS replyToName
        FROM reply r
        WHERE r.idKomentar = ?
        ORDER BY r.sentDate ASC
      `;
      [rows] = await dbPromise.execute(query, [idKomentar]);
    }

    res.json({ success: true, count: rows.length, replies: rows });
  } catch (error) {
    console.error('Error in getRepliesByComment:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Add a reply to a comment
const addReply = async (req, res) => {
  try {
    const idKomentar = req.params.id;
    const { isi, idPengirim, parentReplyId } = req.body;
    console.log('addReply payload:', req.params.id, req.body);

    if (!idKomentar || !isi) return res.status(400).json({ success: false, message: 'idKomentar and isi are required' });

    const rid = idPengirim !== undefined && idPengirim !== null ? Number(idPengirim) : null;
    const prid = parentReplyId !== undefined && parentReplyId !== null ? Number(parentReplyId) : null;

    // ensure reply table has parentReplyId column (best-effort)
    try {
      const [cols] = await dbPromise.execute(
        `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'reply' AND COLUMN_NAME = 'parentReplyId'`
      );
      if (!cols.length) {
        console.log('Migration helper: adding parentReplyId column to reply table');
        await dbPromise.execute('ALTER TABLE reply ADD COLUMN parentReplyId INT NULL AFTER idKomentar');
      }
    } catch (e) {
      console.warn('Could not ensure parentReplyId column exists:', e.message || e);
    }

    const insertQuery = 'INSERT INTO reply (sentDate, isi, idPengirim, idKomentar, parentReplyId) VALUES (NOW(), ?, ?, ?, ?)';
    const [result] = await dbPromise.execute(insertQuery, [isi, rid, idKomentar, prid]);

    console.log('addReply insertedId:', result.insertId, 'idPengirim used:', rid, 'parentReplyId used:', prid);
    const [rows] = await dbPromise.execute('SELECT * FROM reply WHERE idReply = ?', [result.insertId]);
    res.status(201).json({ success: true, message: 'Reply added', idReply: result.insertId, reply: rows[0] || null });
  } catch (error) {
    console.error('Error in addReply:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Update reply
const updateReply = async (req, res) => {
  try {
    const id = req.params.id;
    const { isi } = req.body;
    if (!id || !isi) return res.status(400).json({ success: false, message: 'idReply and isi are required' });

    const updateQuery = 'UPDATE reply SET isi = ? WHERE idReply = ?';
    const [result] = await dbPromise.execute(updateQuery, [isi, id]);

    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Reply not found' });
    res.json({ success: true, message: 'Reply updated' });
  } catch (error) {
    console.error('Error in updateReply:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// Delete reply
const deleteReply = async (req, res) => {
  try {
    const id = req.params.id;
    if (!id) return res.status(400).json({ success: false, message: 'idReply is required' });

    const deleteQuery = 'DELETE FROM reply WHERE idReply = ?';
    const [result] = await dbPromise.execute(deleteQuery, [id]);

    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Reply not found' });
    res.json({ success: true, message: 'Reply deleted' });
  } catch (error) {
    console.error('Error in deleteReply:', error);
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

module.exports = {
  getCommentsByVideo,
  getComment,
  addComment,
  updateComment,
  deleteComment,
  getRepliesByComment,
  addReply,
  updateReply,
  deleteReply,
};
