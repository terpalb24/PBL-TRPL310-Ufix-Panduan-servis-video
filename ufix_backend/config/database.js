const mysql = require('mysql2');
require('dotenv').config();

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',  // kosong sesuai default Laragon
  database: process.env.DB_NAME || 'ufix',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Create promise wrapper
const dbPromise = db.promise();

// Test connection
db.getConnection((err, connection) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('✅ Database connected!');
    connection.release();
  }
});

module.exports = { db, dbPromise };
