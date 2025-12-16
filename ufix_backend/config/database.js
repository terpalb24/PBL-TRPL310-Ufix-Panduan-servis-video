const mysql = require('mysql2');
require('dotenv').config();




//INGAT JANGAN DI COMMIT, NANTI MAU TEST UBAH DULU INI DAN ENV, TP JANGAN DI COMMIT

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',  //Lain kali file ini jangan di commit kecuali ada penggantian struktur
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
