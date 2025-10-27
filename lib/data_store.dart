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
  final String time;
  final String status; // Available, Booked, Pending
  final Color color;
  final int startHour;
  final int endHour;
  final DateTime? bookedDate;

  const TimeSlot({
    required this.time,
    required this.status,
    required this.color,
    required this.startHour,
    required this.endHour,
    this.bookedDate,
  });
}

class UserBooking {
  final String id;
  final String roomName;
  final String roomId;
  final DateTime date;
  final String timeSlot;
  final String studentName;
  final String studentId;
  final String status; // Pending, Approved, Rejected
  final DateTime bookedAt;

  const UserBooking({
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
  // Available rooms for booking
  static List<BookingRoom> availableRooms = [
    BookingRoom(
      id: 'room_001',
      name: 'Lanchester Study Room',
      category: 'Library',
      location: '2nd Floor, D1, Library',
      imageUrl: 'assets/images/study_room1.jpg',
      description: 'A quiet study room with individual desks and power outlets. Perfect for focused studying and research work.',
      timeSlots: [
        TimeSlot(time: '8:00 - 10:00 AM', status: 'Available', color: Colors.green, startHour: 8, endHour: 10),
        TimeSlot(time: '10:00 - 12:00 PM', status: 'Booked', color: Colors.red, startHour: 10, endHour: 12),
        TimeSlot(time: '1:00 - 3:00 PM', status: 'Available', color: Colors.green, startHour: 13, endHour: 15),
        TimeSlot(time: '3:00 - 5:00 PM', status: 'Pending', color: Colors.orange, startHour: 15, endHour: 17),
      ],
    ),
    BookingRoom(
      id: 'room_002',
      name: 'Multimedia Room 1',
      category: 'Multimedia Room',
      location: '1st Floor, C2, Multimedia Zone',
      imageUrl: 'assets/images/multimedia_1.jpg',
      description: 'Equipped with large screen displays, audio systems, and presentation tools. Ideal for group presentations and multimedia projects.',
      timeSlots: [
        TimeSlot(time: '8:00 - 10:00 AM', status: 'Booked', color: Colors.red, startHour: 8, endHour: 10),
        TimeSlot(time: '10:00 - 12:00 PM', status: 'Available', color: Colors.green, startHour: 10, endHour: 12),
        TimeSlot(time: '1:00 - 3:00 PM', status: 'Available', color: Colors.green, startHour: 13, endHour: 15),
        TimeSlot(time: '3:00 - 5:00 PM', status: 'Booked', color: Colors.red, startHour: 15, endHour: 17),
      ],
    ),
    BookingRoom(
      id: 'room_003',
      name: 'Study Room 2',
      category: 'Study Room',
      location: 'Ground Floor, B1, Study Area',
      imageUrl: 'assets/images/study_room2.jpg',
      description: 'Small collaborative space with whiteboards and comfortable seating. Great for group discussions and team projects.',
      timeSlots: [
        TimeSlot(time: '8:00 - 10:00 AM', status: 'Available', color: Colors.green, startHour: 8, endHour: 10),
        TimeSlot(time: '10:00 - 12:00 PM', status: 'Available', color: Colors.green, startHour: 10, endHour: 12),
        TimeSlot(time: '1:00 - 3:00 PM', status: 'Pending', color: Colors.orange, startHour: 13, endHour: 15),
        TimeSlot(time: '3:00 - 5:00 PM', status: 'Available', color: Colors.green, startHour: 15, endHour: 17),
      ],
    ),
    BookingRoom(
      id: 'room_004',
      name: 'Lecture Hall 1',
      category: 'Lecture Hall',
      location: '3rd Floor, E1, Academic Wing',
      imageUrl: 'assets/images/lecture_hall1.jpg',
      description: 'Large capacity hall with projector and sound system. Suitable for workshops, seminars, and large group activities.',
      timeSlots: [
        TimeSlot(time: '8:00 - 10:00 AM', status: 'Booked', color: Colors.red, startHour: 8, endHour: 10),
        TimeSlot(time: '10:00 - 12:00 PM', status: 'Booked', color: Colors.red, startHour: 10, endHour: 12),
        TimeSlot(time: '1:00 - 3:00 PM', status: 'Available', color: Colors.green, startHour: 13, endHour: 15),
        TimeSlot(time: '3:00 - 5:00 PM', status: 'Available', color: Colors.green, startHour: 15, endHour: 17),
      ],
    ),
    BookingRoom(
      id: 'room_005',
      name: 'Conference Room A',
      category: 'Conference Room',
      location: '4th Floor, F1, Admin Building',
      imageUrl: 'assets/images/study_room3.jpg',
      description: 'Professional meeting space with video conferencing capabilities and executive seating.',
      isDisabled: true,
      timeSlots: [
        TimeSlot(time: '8:00 - 10:00 AM', status: 'Booked', color: Colors.red, startHour: 8, endHour: 10),
        TimeSlot(time: '10:00 - 12:00 PM', status: 'Booked', color: Colors.red, startHour: 10, endHour: 12),
        TimeSlot(time: '1:00 - 3:00 PM', status: 'Booked', color: Colors.red, startHour: 13, endHour: 15),
        TimeSlot(time: '3:00 - 5:00 PM', status: 'Booked', color: Colors.red, startHour: 15, endHour: 17),
      ],
    ),
  ];

  // User's current bookings
  static List<UserBooking> userBookings = [
    UserBooking(
      id: 'booking_001',
      roomName: 'Multimedia Room 1',
      roomId: 'room_002',
      date: DateTime.now(),
      timeSlot: '10:00 - 12:00 PM',
      studentName: 'Riley Tan',
      studentId: 'STU12345',
      status: 'Approved',
      bookedAt: DateTime.now(),
    ),
    UserBooking(
      id: 'booking_002',
      roomName: 'Study Room 2',
      roomId: 'room_003',
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '1:00 - 3:00 PM',
      studentName: 'Riley Tan',
      studentId: 'STU12345',
      status: 'Pending',
      bookedAt: DateTime.now(),
    ),
  ];

  // Current student info
  static const String currentStudentName = 'Riley Tan';
  static const String currentStudentId = 'STU12345';

  // Helper methods
  static List<BookingRoom> getRoomsByCategory(String category) {
    if (category == 'All') return availableRooms;
    return availableRooms.where((room) => room.category == category).toList();
  }

  static List<TimeSlot> getAvailableTimeSlots(String roomId) {
    final room = availableRooms.firstWhere((room) => room.id == roomId);
    return room.timeSlots.where((slot) => slot.status == 'Available').toList();
  }

  static void addBooking(UserBooking booking) {
    userBookings.add(booking);
    
    // Update room availability
    final roomIndex = availableRooms.indexWhere((room) => room.id == booking.roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      final updatedTimeSlots = room.timeSlots.map((slot) {
        if (slot.time == booking.timeSlot) {
          return TimeSlot(
            time: slot.time, 
            status: 'Pending', 
            color: Colors.orange,
            startHour: slot.startHour,
            endHour: slot.endHour,
            bookedDate: booking.date,
          );
        }
        return slot;
      }).toList();
      
      availableRooms[roomIndex] = BookingRoom(
        id: room.id,
        name: room.name,
        category: room.category,
        location: room.location,
        imageUrl: room.imageUrl,
        description: room.description,
        timeSlots: updatedTimeSlots,
        isDisabled: room.isDisabled,
      );
    }
  }

  static void cancelBooking(String bookingId) {
    final booking = userBookings.firstWhere((b) => b.id == bookingId);
    userBookings.removeWhere((b) => b.id == bookingId);
    
    // Update room availability
    final roomIndex = availableRooms.indexWhere((room) => room.id == booking.roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      final updatedTimeSlots = room.timeSlots.map((slot) {
        if (slot.time == booking.timeSlot) {
          return TimeSlot(
            time: slot.time, 
            status: 'Available', 
            color: Colors.green,
            startHour: slot.startHour,
            endHour: slot.endHour,
          );
        }
        return slot;
      }).toList();
      
      availableRooms[roomIndex] = BookingRoom(
        id: room.id,
        name: room.name,
        category: room.category,
        location: room.location,
        imageUrl: room.imageUrl,
        description: room.description,
        timeSlots: updatedTimeSlots,
        isDisabled: room.isDisabled,
      );
    }
  }

  static bool canStudentBookToday() {
    final now = DateTime.now();
    return !userBookings.any((booking) => 
        booking.date.year == now.year &&
        booking.date.month == now.month &&
        booking.date.day == now.day);
  }

  static UserBooking? getTodayBooking() {
    final now = DateTime.now();
    try {
      return userBookings.firstWhere((booking) => 
          booking.date.year == now.year &&
          booking.date.month == now.month &&
          booking.date.day == now.day);
    } catch (e) {
      return null;
    }
  }

  static void resetRoomsForNextDay() {
    // This would typically reset room availability for a new day
    // For now, we'll just reset some slots to available
    availableRooms = availableRooms.map((room) {
      final updatedTimeSlots = room.timeSlots.map((slot) {
        if (slot.status == 'Pending' || slot.status == 'Booked') {
          return TimeSlot(
            time: slot.time,
            status: 'Available',
            color: Colors.green,
            startHour: slot.startHour,
            endHour: slot.endHour,
          );
        }
        return slot;
      }).toList();
      
      return BookingRoom(
        id: room.id,
        name: room.name,
        category: room.category,
        location: room.location,
        imageUrl: room.imageUrl,
        description: room.description,
        timeSlots: updatedTimeSlots,
        isDisabled: room.isDisabled,
      );
    }).toList();
  }
}