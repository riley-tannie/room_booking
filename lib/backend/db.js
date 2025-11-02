const mysql = require('mysql2');

const con = mysql.createConnection({
    host: 'localhost',
    user: 'root', 
    password: '',
    database: 'room_reservation'
});

con.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err.message);
        return;
    }
    console.log('Connected to MySQL database');
});

module.exports = con;