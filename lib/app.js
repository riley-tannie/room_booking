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

// Get all rooms
app.get('/api/rooms', (req, res) => {
    const sql = "SELECT * FROM rooms";
    con.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

// Get room time slots for today
app.get('/api/rooms/:roomId/time-slots', (req, res) => {
    const roomId = req.params.roomId;
    const today = new Date().toISOString().split('T')[0];
    
    const sql = `
        SELECT ra.* 
        FROM room_availability ra 
        WHERE ra.room_id = ? AND ra.availability_date = ?
        ORDER BY ra.time_slot
    `;
    
    con.query(sql, [roomId, today], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        
        if (results.length === 0) {
            // Return default time slots if none exist
            const defaultSlots = [
                { id: 1, time_slot: '08:00-10:00', status: 'free' },
                { id: 2, time_slot: '10:00-12:00', status: 'free' },
                { id: 3, time_slot: '13:00-15:00', status: 'free' },
                { id: 4, time_slot: '15:00-17:00', status: 'free' },
            ];
            return res.json(defaultSlots);
        }
        
        res.json(results);
    });
});

// Create booking - FIXED VERSION
app.post('/api/bookings', (req, res) => {
    const { studentId, roomId, timeSlot } = req.body;
    const today = new Date().toISOString().split('T')[0];
    
    console.log('Booking request:', { studentId, roomId, timeSlot, today });
    
    // First check if student already booked today
    const checkSql = "SELECT * FROM bookings WHERE student_id = ? AND booking_date = ?";
    
    con.query(checkSql, [studentId, today], (err, results) => {
        if (err) {
            console.error('Error checking existing bookings:', err);
            return res.status(500).json({ error: 'Server error checking bookings' });
        }
        
        if (results.length > 0) {
            return res.status(400).json({ error: 'You can only book one slot per day' });
        }
        
        // Check if time slot is available
        const slotCheckSql = `
            SELECT * FROM room_availability 
            WHERE room_id = ? AND availability_date = ? AND time_slot = ? AND status = 'free'
        `;
        
        con.query(slotCheckSql, [roomId, today, timeSlot], (err, slotResults) => {
            if (err) {
                console.error('Error checking time slot availability:', err);
                return res.status(500).json({ error: 'Server error checking availability' });
            }
            
            if (slotResults.length === 0) {
                return res.status(400).json({ error: 'Time slot not available' });
            }
            
            // Create booking first
            const bookingId = 'book_' + Date.now();
            const bookingSql = `
                INSERT INTO bookings (id, student_id, room_id, booking_date, time_slot, status) 
                VALUES (?, ?, ?, ?, ?, 'Pending')
            `;
            
            console.log('Creating booking with ID:', bookingId);
            
            con.query(bookingSql, [bookingId, studentId, roomId, today, timeSlot], (err, result) => {
                if (err) {
                    console.error('Error creating booking:', err);
                    return res.status(500).json({ error: 'Database error creating booking: ' + err.message });
                }
                
                console.log('Booking created successfully, updating room availability...');
                
                // Update room availability - REMOVED booking_id to avoid foreign key issues
                const updateSql = `
                    UPDATE room_availability 
                    SET status = 'pending', student_id = ?
                    WHERE room_id = ? AND availability_date = ? AND time_slot = ?
                `;
                
                con.query(updateSql, [studentId, roomId, today, timeSlot], (err, updateResult) => {
                    if (err) {
                        console.error('Failed to update room availability:', err);
                        return res.status(500).json({ error: 'Booking update failed: ' + err.message });
                    }
                    
                    console.log('Room availability updated successfully');
                    res.json({ success: true, message: 'Booking created', bookingId: bookingId });
                });
            });
        });
    });
});

// Get user bookings
app.get('/api/bookings/student/:studentId', (req, res) => {
    const studentId = req.params.studentId;
    
    const sql = `
        SELECT b.*, r.name as room_name, r.location, r.image_url 
        FROM bookings b 
        JOIN rooms r ON b.room_id = r.id 
        WHERE b.student_id = ?
        ORDER BY b.booking_date DESC, b.booked_at DESC
    `;
    
    con.query(sql, [studentId], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

// Get today's bookings for a student (for request status)
app.get('/api/bookings/student/:studentId/today', (req, res) => {
    const studentId = req.params.studentId;
    const today = new Date().toISOString().split('T')[0];
    
    const sql = `
        SELECT b.*, r.name as room_name, r.location, r.image_url 
        FROM bookings b 
        JOIN rooms r ON b.room_id = r.id 
        WHERE b.student_id = ? AND b.booking_date = ?
        ORDER BY b.booked_at DESC
    `;
    
    con.query(sql, [studentId, today], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

// Check if student has booked today
app.get('/api/bookings/student/:studentId/has-booked-today', (req, res) => {
    const studentId = req.params.studentId;
    const today = new Date().toISOString().split('T')[0];
    
    const sql = `
        SELECT COUNT(*) as count 
        FROM bookings 
        WHERE student_id = ? AND booking_date = ?
    `;
    
    con.query(sql, [studentId, today], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json({ hasBooked: results[0].count > 0 });
    });
});

// Get all bookings (for staff/lecturer)
app.get('/api/bookings', (req, res) => {
    const sql = `
        SELECT b.*, r.name as room_name, r.location, u.full_name as student_name
        FROM bookings b 
        JOIN rooms r ON b.room_id = r.id 
        JOIN users u ON b.student_id = u.id
        ORDER BY b.booked_at DESC
    `;
    
    con.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results);
    });
});

// Update booking status (for lecturer approval) - FIXED VERSION
app.put('/api/bookings/:bookingId/status', (req, res) => {
    const bookingId = req.params.bookingId;
    const { status, approvedBy } = req.body;
    
    // First get the booking details to update room_availability
    const getBookingSql = `
        SELECT student_id, room_id, booking_date, time_slot 
        FROM bookings 
        WHERE id = ?
    `;
    
    con.query(getBookingSql, [bookingId], (err, bookingResults) => {
        if (err) return res.status(500).json({ error: 'Failed to get booking details' });
        
        if (bookingResults.length === 0) {
            return res.status(404).json({ error: 'Booking not found' });
        }
        
        const booking = bookingResults[0];
        
        // Update booking status
        const updateBookingSql = `
            UPDATE bookings 
            SET status = ?, approved_by = ?, approved_at = NOW() 
            WHERE id = ?
        `;
        
        con.query(updateBookingSql, [status, approvedBy, bookingId], (err, result) => {
            if (err) return res.status(500).json({ error: 'Update failed' });
            
            // Update room availability status - FIXED to not use booking_id
            const updateAvailabilitySql = `
                UPDATE room_availability 
                SET status = ? 
                WHERE room_id = ? AND availability_date = ? AND time_slot = ? AND student_id = ?
            `;
            
            let availabilityStatus = status.toLowerCase() === 'approved' ? 'reserved' : 'free';
            
            con.query(updateAvailabilitySql, [
                availabilityStatus, 
                booking.room_id, 
                booking.booking_date, 
                booking.time_slot,
                booking.student_id
            ], (err, updateResult) => {
                if (err) {
                    console.error('Failed to update room availability:', err);
                    // Still return success since booking was updated
                }
                
                res.json({ success: true, message: 'Booking status updated' });
            });
        });
    });
});

// Get dashboard stats
app.get('/api/dashboard/stats', (req, res) => {
    const today = new Date().toISOString().split('T')[0];
    
    const sql = `
        SELECT 
            (SELECT COUNT(*) FROM room_availability WHERE availability_date = ? AND status = 'free') as free_slots,
            (SELECT COUNT(*) FROM room_availability WHERE availability_date = ? AND status = 'pending') as pending_slots,
            (SELECT COUNT(*) FROM room_availability WHERE availability_date = ? AND status = 'reserved') as reserved_slots,
            (SELECT COUNT(*) FROM rooms WHERE is_disabled = 1) as disabled_rooms
    `;
    
    con.query(sql, [today, today, today], (err, results) => {
        if (err) return res.status(500).json({ error: 'Server error' });
        res.json(results[0]);
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});