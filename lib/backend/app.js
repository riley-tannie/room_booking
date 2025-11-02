const express = require('express');
const cors = require('cors');
const con = require('./db');

const app = express();

app.use(cors());
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: "Server is running" });
});

// Login
app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    
    const sql = "SELECT id, full_name, role FROM users WHERE email = ? AND password = ?";
    
    con.query(sql, [email, password], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        if (results.length === 0) return res.status(401).json({ error: 'Invalid login' });
        
        const user = results[0];
        res.json({
            uid: user.id,
            fullName: user.full_name,
            email: email,
            role: user.role
        });
    });
});

// Register
app.post('/api/register', (req, res) => {
    const { fullName, idNumber, email, password } = req.body;

    let role = 'student';
    if (email.endsWith('@mfu.ac.th')) role = 'lecturer';
    if (email.endsWith('@mfu.th')) role = 'staff';

    const sql = "INSERT INTO users (id, full_name, email, password, role) VALUES (?, ?, ?, ?, ?)";
    
    con.query(sql, [idNumber, fullName, email, password, role], (err, result) => {
        if (err) return res.status(500).json({ error: 'Registration failed' });
        
        res.json({
            success: true,
            message: 'Registration successful'
        });
    });
});

// Get rooms
app.get('/api/rooms', (req, res) => {
    const sql = "SELECT * FROM rooms";
    con.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

// Get time slots
app.get('/api/rooms/:roomId/time-slots', (req, res) => {
    const timeSlots = [
        { id: 1, time: '09:00 - 10:00', status: 'free', displayStatus: 'Available' },
        { id: 2, time: '10:00 - 11:00', status: 'free', displayStatus: 'Available' },
        { id: 3, time: '11:00 - 12:00', status: 'pending', displayStatus: 'Pending' },
    ];
    res.json(timeSlots);
});

// Create booking
app.post('/api/bookings', (req, res) => {
    const { studentId, roomId, timeSlot } = req.body;
    
    const sql = "INSERT INTO bookings (student_id, room_id, time_slot, status) VALUES (?, ?, ?, 'Pending')";
    
    con.query(sql, [studentId, roomId, timeSlot], (err, result) => {
        if (err) return res.status(500).json({ error: 'Booking failed' });
        res.json({ success: true, message: 'Booking created' });
    });
});

// Get user bookings
app.get('/api/bookings/student/:studentId', (req, res) => {
    const studentId = req.params.studentId;
    
    const sql = `
        SELECT b.*, r.name as room_name, r.location 
        FROM bookings b 
        JOIN rooms r ON b.room_id = r.id 
        WHERE b.student_id = ?
    `;
    
    con.query(sql, [studentId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});