const mysql = require('mysql2');
require('dotenv').config();

// Create connection pool
const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'ufix',
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