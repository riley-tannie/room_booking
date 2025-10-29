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
  bool isDisabled;

  BookingRoom({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.timeSlots,
    this.isDisabled = false,
  });

  BookingRoom copyWith({
    String? name,
    String? location,
    String? description,
    bool? isDisabled,
  }) {
    return BookingRoom(
      id: id,
      name: name ?? this.name,
      category: category,
      location: location ?? this.location,
      imageUrl: imageUrl,
      description: description ?? this.description,
      timeSlots: timeSlots,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}

class TimeSlot {
  final String time; // "8-10", "10-12", "13-15", "15-17"
  String status; // "free", "pending", "reserved", "disabled"
  final int startHour;
  final int endHour;
  String? studentId;
  String? studentName;
  DateTime? bookedDate;
  String? bookingId;
  String? approvedBy;

  TimeSlot({
    required this.time,
    required this.status,
    required this.startHour,
    required this.endHour,
    this.studentId,
    this.studentName,
    this.bookedDate,
    this.bookingId,
    this.approvedBy,
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
  String? approvedBy;

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
    this.approvedBy,
  });
}

// --- Staff Data Store ---
class StaffDataStore {
  // Available rooms for booking - MIXED STATUSES
  static List<BookingRoom> availableRooms = [
    // Room 1: Mostly available with one pending slot
    BookingRoom(
      id: 'room_001',
      name: 'Lanchester Study Room',
      category: 'Library',
      location: '2nd Floor, D1, Library',
      imageUrl: 'assets/images/study_room1.jpg',
      description: 'A quiet study room with individual desks and power outlets. Perfect for focused studying and research work.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'pending', startHour: 10, endHour: 12, studentId: 'STU1001', studentName: 'John Doe'),
        TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
      ],
    ),
    // Room 2: Mostly reserved/pending
    BookingRoom(
      id: 'room_002',
      name: 'Multimedia Room 1',
      category: 'Multimedia Room',
      location: '1st Floor, C2, Multimedia Zone',
      imageUrl: 'assets/images/multimedia_1.jpg',
      description: 'Equipped with large screen displays, audio systems, and presentation tools. Ideal for group presentations and multimedia projects.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'reserved', startHour: 8, endHour: 10, studentId: 'STU1002', studentName: 'Jane Smith', approvedBy: 'Dr. Johnson'),
        TimeSlot(time: '10-12', status: 'pending', startHour: 10, endHour: 12, studentId: 'STU1003', studentName: 'Mike Chen'),
        TimeSlot(time: '13-15', status: 'reserved', startHour: 13, endHour: 15, studentId: 'STU1004', studentName: 'Sarah Wilson', approvedBy: 'Dr. Johnson'),
        TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
      ],
    ),
    // Room 3: Partially disabled
    BookingRoom(
      id: 'room_003',
      name: 'Study Room 2',
      category: 'Study Room',
      location: 'Ground Floor, B1, Study Area',
      imageUrl: 'assets/images/study_room2.jpg',
      description: 'Small collaborative space with whiteboards and comfortable seating. Great for group discussions and team projects.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'disabled', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'pending', startHour: 13, endHour: 15, studentId: 'STU1005', studentName: 'Alex Brown'),
        TimeSlot(time: '15-17', status: 'disabled', startHour: 15, endHour: 17),
      ],
    ),
    // Room 4: All disabled (maintenance)
    BookingRoom(
      id: 'room_004',
      name: 'Lecture Hall 1',
      category: 'Lecture Hall',
      location: '3rd Floor, E1, Academic Wing',
      imageUrl: 'assets/images/lecture_hall1.jpg',
      description: 'Large capacity hall with projector and sound system. Suitable for workshops, seminars, and large group activities.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'disabled', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'disabled', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'disabled', startHour: 13, endHour: 15),
        TimeSlot(time: '15-17', status: 'disabled', startHour: 15, endHour: 17),
      ],
      isDisabled: true,
    ),
    // Room 5: Mixed status with more free slots
    BookingRoom(
      id: 'room_005',
      name: 'Conference Room A',
      category: 'Conference Room',
      location: '4th Floor, F1, Admin Building',
      imageUrl: 'assets/images/study_room3.jpg',
      description: 'Professional meeting space with video conferencing capabilities and executive seating.',
      timeSlots: [
        TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
        TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
        TimeSlot(time: '13-15', status: 'pending', startHour: 13, endHour: 15, studentId: 'STU1006', studentName: 'Emma Davis'),
        TimeSlot(time: '15-17', status: 'reserved', startHour: 15, endHour: 17, studentId: 'STU1007', studentName: 'Tom Wilson', approvedBy: 'Prof. Anderson'),
      ],
    ),
  ];

  // All bookings history (for staff to see all bookings)
  static List<UserBooking> allBookingsHistory = [
    UserBooking(
      id: 'book_001',
      roomName: 'Multimedia Room 1',
      roomId: 'room_002',
      date: DateTime.now(),
      timeSlot: '8-10',
      studentName: 'Jane Smith',
      studentId: 'STU1002',
      status: 'Approved',
      bookedAt: DateTime.now().subtract(Duration(hours: 2)),
      approvedBy: 'Dr. Johnson',
    ),
    UserBooking(
      id: 'book_002',
      roomName: 'Study Room 2',
      roomId: 'room_003',
      date: DateTime.now(),
      timeSlot: '13-15',
      studentName: 'Alex Brown',
      studentId: 'STU1005',
      status: 'Pending',
      bookedAt: DateTime.now().subtract(Duration(hours: 1)),
    ),
    UserBooking(
      id: 'book_003',
      roomName: 'Conference Room A',
      roomId: 'room_005',
      date: DateTime.now(),
      timeSlot: '15-17',
      studentName: 'Tom Wilson',
      studentId: 'STU1007',
      status: 'Approved',
      bookedAt: DateTime.now().subtract(Duration(days: 1)),
      approvedBy: 'Prof. Anderson',
    ),
  ];

  // Current staff info
  static const String currentStaffName = 'Staff User';
  static const String currentStaffId = 'STAFF001';

  // --- DASHBOARD STATS ---
  static Map<String, int> getDashboardStats() {
    int availableCount = 0;
    int pendingCount = 0;
    int reservedCount = 0;
    int disabledCount = 0;

    for (final room in availableRooms) {
      for (final slot in room.timeSlots) {
        switch (slot.status) {
          case 'free':
            availableCount++;
            break;
          case 'pending':
            pendingCount++;
            break;
          case 'reserved':
            reservedCount++;
            break;
          case 'disabled':
            disabledCount++;
            break;
        }
      }
    }

    return {
      'available': availableCount,
      'pending': pendingCount,
      'reserved': reservedCount,
      'disabled': disabledCount,
    };
  }

  // --- STAFF METHODS ---

  // Add new room
  static void addRoom(BookingRoom room) {
    availableRooms.add(room);
  }

  // Update room details
  static void updateRoom(String roomId, String newName, String newLocation, String newDescription) {
    final roomIndex = availableRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      availableRooms[roomIndex] = availableRooms[roomIndex].copyWith(
        name: newName,
        location: newLocation,
        description: newDescription,
      );
    }
  }

  // Disable a room (only if all time slots are free)
  static bool disableRoom(String roomId) {
    final roomIndex = availableRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      
      // Check if all time slots are free
      final allFree = room.timeSlots.every((slot) => slot.status == 'free');
      
      if (allFree) {
        // Disable all time slots
        for (final slot in room.timeSlots) {
          slot.status = 'disabled';
        }
        availableRooms[roomIndex] = room.copyWith(isDisabled: true);
        return true;
      }
    }
    return false;
  }

  // Enable a disabled room
  static void enableRoom(String roomId) {
    final roomIndex = availableRooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      final room = availableRooms[roomIndex];
      
      // Enable all time slots (set to free)
      for (final slot in room.timeSlots) {
        if (slot.status == 'disabled') {
          slot.status = 'free';
        }
      }
      availableRooms[roomIndex] = room.copyWith(isDisabled: false);
    }
  }

  // Disable specific time slot (only if free)
  static bool disableTimeSlot(String roomId, String timeSlot) {
    final room = availableRooms.firstWhere((room) => room.id == roomId);
    final slot = room.timeSlots.firstWhere((slot) => slot.time == timeSlot);
    
    if (slot.status == 'free') {
      slot.status = 'disabled';
      return true;
    }
    return false;
  }

  // Enable specific time slot
  static void enableTimeSlot(String roomId, String timeSlot) {
    final room = availableRooms.firstWhere((room) => room.id == roomId);
    final slot = room.timeSlots.firstWhere((slot) => slot.time == timeSlot);
    
    if (slot.status == 'disabled') {
      slot.status = 'free';
    }
  }

  // Get pending bookings for approval
  static List<UserBooking> getPendingBookings() {
    return allBookingsHistory.where((booking) => booking.status == 'Pending').toList();
  }

  // Approve a booking
  static void approveBooking(String bookingId, String approvedBy) {
    final bookingIndex = allBookingsHistory.indexWhere((booking) => booking.id == bookingId);
    if (bookingIndex != -1) {
      allBookingsHistory[bookingIndex].status = 'Approved';
      allBookingsHistory[bookingIndex].approvedBy = approvedBy;
      
      // Update room time slot status
      final booking = allBookingsHistory[bookingIndex];
      final room = availableRooms.firstWhere((room) => room.id == booking.roomId);
      final slot = room.timeSlots.firstWhere((slot) => slot.time == booking.timeSlot);
      slot.status = 'reserved';
      slot.approvedBy = approvedBy;
    }
  }

  // Reject a booking
  static void rejectBooking(String bookingId) {
    final bookingIndex = allBookingsHistory.indexWhere((booking) => booking.id == bookingId);
    if (bookingIndex != -1) {
      final booking = allBookingsHistory[bookingIndex];
      
      // Update room time slot status back to free
      final room = availableRooms.firstWhere((room) => room.id == booking.roomId);
      final slot = room.timeSlots.firstWhere((slot) => slot.time == booking.timeSlot);
      slot.status = 'free';
      slot.studentId = null;
      slot.studentName = null;
      slot.approvedBy = null;
      
      // Remove from bookings history
      allBookingsHistory.removeAt(bookingIndex);
    }
  }

  // Get rooms by category
  static List<BookingRoom> getRoomsByCategory(String category) {
    if (category == 'All') return availableRooms;
    return availableRooms.where((room) => room.category == category).toList();
  }

  // Get booking history for a specific room
  static List<UserBooking> getRoomBookingHistory(String roomId) {
    return allBookingsHistory.where((booking) => booking.roomId == roomId).toList();
  }

  // Reset all rooms for next day (as per requirements)
  static void resetRoomsForNextDay() {
    for (final room in availableRooms) {
      for (final slot in room.timeSlots) {
        if (slot.status != 'disabled') {
          slot.status = 'free';
          slot.studentId = null;
          slot.studentName = null;
          slot.bookedDate = null;
          slot.bookingId = null;
          slot.approvedBy = null;
        }
      }
    }
    
    // Clear today's bookings from history (keep for records if needed)
    final now = DateTime.now();
    allBookingsHistory.removeWhere((booking) => _isSameDay(booking.date, now));
  }

  // Helper method to check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}