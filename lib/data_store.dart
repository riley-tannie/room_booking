import 'package:flutter/material.dart';

// --- Booking Data Models ---
class BookingRoom {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final String description;
  final List<TimeSlot> timeSlots;
  final bool isDisabled;

  const BookingRoom({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.timeSlots,
    this.isDisabled = false,
  });
}

class TimeSlot {
  final String time; // "8-10", "10-12", "13-15", "15-17"
  String status; // "free", "pending", "reserved", "disabled"
  final int startHour;
  final int endHour;
  String? studentId;
  DateTime? bookedDate;
  String? bookingId;

  TimeSlot({
    required this.time,
    required this.status,
    required this.startHour,
    required this.endHour,
    this.studentId,
    this.bookedDate,
    this.bookingId,
  });

  // Get color based on status
  Color get color {
    switch (status) {
      case 'free': return Colors.green;
      case 'pending': return Colors.orange;
      case 'reserved': return Colors.red;
      case 'disabled': return Colors.grey;
      default: return Colors.green;
    }
  }

  // Get display text for status
  String get displayStatus {
    switch (status) {
      case 'free': return 'Available';
      case 'pending': return 'Pending';
      case 'reserved': return 'Reserved';
      case 'disabled': return 'Disabled';
      default: return 'Available';
    }
  }
}

class UserBooking {
  final String id;
  final String roomName;
  final String roomId;
  final DateTime date;
  final String timeSlot;
  final String studentName;
  final String studentId;
  String status; // "Pending", "Approved", "Rejected"
  final DateTime bookedAt;

   UserBooking({
    required this.id,
    required this.roomName,
    required this.roomId,
    required this.date,
    required this.timeSlot,
    required this.studentName,
    required this.studentId,
    required this.status,
    required this.bookedAt,
  });
}

// --- Booking Data Store ---
class BookingDataStore {
  // Available rooms for booking - MIXED AVAILABILITY
  static List<BookingRoom> availableRooms = [
    // Room 1: Mostly available (3 free slots, 1 pending) - Changed to Study Room
    BookingRoom(
      id: 'room_001',
      name: 'Study Room 1',
      category: 'Study Room',
      location: '2nd Floor, D1, Study Area',
      imageUrl: 'assets/images/study_room1.jpg',
      description: 'A quiet study room with individual desks and power outlets. Perfect for focused studying and research work.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'pending', startHour: 15, endHour: 17, bookedDate: DateTime.now()),
      ],
    ),
    // Room 2: Half available, half reserved
    BookingRoom(
      id: 'room_002',
      name: 'Multimedia Room 1',
      category: 'Multimedia Room',
      location: '1st Floor, C2, Multimedia Zone',
      imageUrl: 'assets/images/multimedia_1.jpg',
      description: 'Equipped with large screen displays, audio systems, and presentation tools. Ideal for group presentations and multimedia projects.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'reserved', startHour: 8, endHour: 10, bookedDate: DateTime.now()),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'reserved', startHour: 13, endHour: 15, bookedDate: DateTime.now()),
        TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
      ],
    ),
    // Room 3: All available (fresh room)
    BookingRoom(
      id: 'room_003',
      name: 'Study Room 2',
      category: 'Study Room',
      location: 'Ground Floor, B1, Study Area',
      imageUrl: 'assets/images/study_room2.jpg',
      description: 'Small collaborative space with whiteboards and comfortable seating. Great for group discussions and team projects.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
      ],
    ),
    // Room 4: Mostly reserved (1 free slot)
    BookingRoom(
      id: 'room_004',
      name: 'Lecture Hall 1',
      category: 'Lecture Hall',
      location: '3rd Floor, E1, Academic Wing',
      imageUrl: 'assets/images/lecture_hall1.jpg',
      description: 'Large capacity hall with projector and sound system. Suitable for workshops, seminars, and large group activities.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'reserved', startHour: 8, endHour: 10, bookedDate: DateTime.now()),
        TimeSlot(time: '10-12', status: 'reserved', startHour: 10, endHour: 12, bookedDate: DateTime.now()),
        TimeSlot(time: '13-15', status: 'reserved', startHour: 13, endHour: 15, bookedDate: DateTime.now()),
        TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
      ],
    ),
    // Room 5: Disabled room
    BookingRoom(
      id: 'room_005',
      name: 'Conference Room A',
      category: 'Conference Room',
      location: '4th Floor, F1, Admin Building',
      imageUrl: 'assets/images/study_room3.jpg',
      description: 'Professional meeting space with video conferencing capabilities and executive seating.',
      isDisabled: true,
      timeSlots: [
        TimeSlot(time: '8-10', status: 'disabled', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'disabled', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'disabled', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'disabled', startHour: 15, endHour: 17),
      ],
    ),
    // Room 6: Mixed availability - Mostly Pending
    BookingRoom(
      id: 'room_006',
      name: 'Collaborative Space 1',
      category: 'Study Room',
      location: '1st Floor, A2, Learning Commons',
      imageUrl: 'assets/images/collab_space1.jpg',
      description: 'Modern collaborative area with movable furniture and multiple power outlets. Perfect for group work.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'pending', startHour: 8, endHour: 10, bookedDate: DateTime.now()),
        TimeSlot(time: '10-12', status: 'pending', startHour: 10, endHour: 12, bookedDate: DateTime.now()),
        TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'pending', startHour: 15, endHour: 17, bookedDate: DateTime.now()),
      ],
    ),
    // Room 7: Multimedia Room 2 - Mixed availability
    BookingRoom(
      id: 'room_007',
      name: 'Multimedia Room 2',
      category: 'Multimedia Room',
      location: '1st Floor, C3, Multimedia Zone',
      imageUrl: 'assets/images/multimedia_2.jpg',
      description: 'Advanced multimedia room with 4K displays and surround sound system. Perfect for video presentations.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'pending', startHour: 13, endHour: 15, bookedDate: DateTime.now()),
        TimeSlot(time: '15-17', status: 'reserved', startHour: 15, endHour: 17, bookedDate: DateTime.now()),
      ],
    ),
    // Room 8: Lecture Hall 2 - Mostly available
    BookingRoom(
      id: 'room_008',
      name: 'Lecture Hall 2',
      category: 'Lecture Hall',
      location: '3rd Floor, E2, Academic Wing',
      imageUrl: 'assets/images/lecture_hall2.jpg',
      description: 'Medium-sized lecture hall with comfortable seating and modern audio-visual equipment.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'reserved', startHour: 15, endHour: 17, bookedDate: DateTime.now()),
      ],
    ),
  ];

  // User's current bookings - WITH PAST BOOKINGS
  static List<UserBooking> userBookings = [
    // Today's booking
    UserBooking(
      id: 'booking_001',
      roomName: 'Study Room 1',
      roomId: 'room_001',
      date: DateTime.now(),
      timeSlot: '8-10',
      studentName: currentStudentName,
      studentId: currentStudentId,
      status: 'Pending',
      bookedAt: DateTime.now(),
    ),
    // Past approved booking (yesterday)
    UserBooking(
      id: 'booking_002',
      roomName: 'Multimedia Room 1',
      roomId: 'room_002',
      date: DateTime.now().subtract(const Duration(days: 1)),
      timeSlot: '13-15',
      studentName: currentStudentName,
      studentId: currentStudentId,
      status: 'Approved',
      bookedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    // Past rejected booking (2 days ago)
    UserBooking(
      id: 'booking_003',
      roomName: 'Lecture Hall 1',
      roomId: 'room_004',
      date: DateTime.now().subtract(const Duration(days: 2)),
      timeSlot: '10-12',
      studentName: currentStudentName,
      studentId: currentStudentId,
      status: 'Rejected',
      bookedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    // Older approved booking (last week)
    UserBooking(
      id: 'booking_004',
      roomName: 'Study Room 2',
      roomId: 'room_003',
      date: DateTime.now().subtract(const Duration(days: 7)),
      timeSlot: '15-17',
      studentName: currentStudentName,
      studentId: currentStudentId,
      status: 'Approved',
      bookedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // Current student info
  static const String currentStudentName = 'Riley Tan';
  static const String currentStudentId = 'STU12345';

  // SIMPLIFIED: Check if time slot is available (NO TIME EXPIRY, NO BOOKING LIMIT)
  static bool isTimeSlotAvailable(TimeSlot slot) {
    // Check if slot is disabled
    if (slot.status == 'disabled') return false;
    
    // Check if slot is already booked
    if (slot.status != 'free') return false;
    
    // NO TIME EXPIRY CHECK - users can book any time slot regardless of current time
    // NO BOOKING LIMIT CHECK - users can book multiple slots per day
    return true;
  }

  // Get available time slots for a room (NO TIME EXPIRY, NO BOOKING LIMIT)
  static List<TimeSlot> getAvailableTimeSlots(String roomId) {
    final room = availableRooms.firstWhere((room) => room.id == roomId);
    return room.timeSlots.where((slot) => isTimeSlotAvailable(slot)).toList();
  }

  // Book a time slot - NO BOOKING LIMIT
  static void addBooking(UserBooking booking) {
    userBookings.add(booking);
    
    // Update room time slot status
    final roomIndex = availableRooms.indexWhere((room) => room.id == booking.roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      final slotIndex = room.timeSlots.indexWhere((slot) => slot.time == booking.timeSlot);
      
      if (slotIndex != -1) {
        room.timeSlots[slotIndex].status = 'pending';
        room.timeSlots[slotIndex].studentId = booking.studentId;
        room.timeSlots[slotIndex].bookedDate = booking.date;
        room.timeSlots[slotIndex].bookingId = booking.id;
      }
    }
  }

  // Cancel a booking
  static void cancelBooking(String bookingId) {
    final booking = userBookings.firstWhere((b) => b.id == bookingId);
    userBookings.removeWhere((b) => b.id == bookingId);
    
    // Update room time slot status back to free
    final roomIndex = availableRooms.indexWhere((room) => room.id == booking.roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      final slotIndex = room.timeSlots.indexWhere((slot) => slot.bookingId == bookingId);
      
      if (slotIndex != -1) {
        room.timeSlots[slotIndex].status = 'free';
        room.timeSlots[slotIndex].studentId = null;
        room.timeSlots[slotIndex].bookedDate = null;
        room.timeSlots[slotIndex].bookingId = null;
      }
    }
  }

  // Get today's booking for current student
  static UserBooking? getTodayBooking() {
    final now = DateTime.now();
    try {
      return userBookings.firstWhere((booking) => 
          _isSameDay(booking.date, now) && 
          booking.studentId == currentStudentId);
    } catch (e) {
      return null;
    }
  }

  // Reset all rooms for next day
  static void resetRoomsForNextDay() {
    for (final room in availableRooms) {
      for (final slot in room.timeSlots) {
        if (slot.status != 'disabled') {
          slot.status = 'free';
          slot.studentId = null;
          slot.bookedDate = null;
          slot.bookingId = null;
        }
      }
    }
    
    // Clear today's bookings (keep history for records)
    final now = DateTime.now();
    userBookings.removeWhere((booking) => _isSameDay(booking.date, now));
  }

  // Get rooms by category
  static List<BookingRoom> getRoomsByCategory(String category) {
    if (category == 'All') return availableRooms;
    return availableRooms.where((room) => room.category == category).toList();
  }

  // Get available rooms (with at least one available time slot)
  static List<BookingRoom> getAvailableRooms() {
    return availableRooms.where((room) => 
        !room.isDisabled && 
        room.timeSlots.any((slot) => isTimeSlotAvailable(slot))).toList();
  }

  // Helper method to check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}