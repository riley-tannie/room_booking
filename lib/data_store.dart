import 'package:flutter/material.dart';

class BookingRoom {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final String description;
  final bool isDisabled;
  List<TimeSlot> timeSlots;

  BookingRoom({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.description,
    required this.isDisabled,
    required this.timeSlots,
  });

  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      id: json['id']?.toString() ?? json['room_id']?.toString() ?? '',
      name: json['name'] ?? json['room_name'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'] ?? 'assets/images/default_room.jpg',
      description: json['description'] ?? '',
      isDisabled: (json['is_disabled'] ?? json['disabled'] ?? 0) == 1,
      timeSlots: [],
    );
  }
}

class TimeSlot {
  final String id;
  final String time;
  final String status;
  final String displayStatus;
  final Color color;
  final String? studentName;

  TimeSlot({
    required this.id,
    required this.time,
    required this.status,
    required this.displayStatus,
    required this.color,
    this.studentName,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    String status = json['status'] ?? 'free';
    String displayStatus = 'Available';
    Color color = const Color(0xFF26A65B); // Green for free
    
    switch (status) {
      case 'pending':
        displayStatus = 'Pending';
        color = const Color(0xFFF59E0B); // Orange for pending
        break;
      case 'reserved':
        displayStatus = 'Reserved';
        color = const Color(0xFFEF4444); // Red for reserved
        break;
      case 'disabled':
        displayStatus = 'Disabled';
        color = const Color(0xFF6B7280); // Gray for disabled
        break;
      case 'free':
      default:
        displayStatus = 'Available';
        color = const Color(0xFF26A65B); // Green for free
        break;
    }

    return TimeSlot(
      id: json['id']?.toString() ?? json['slot_id']?.toString() ?? '',
      time: json['time_slot'] ?? json['time'] ?? '',
      status: status,
      displayStatus: displayStatus,
      color: color,
      studentName: json['student_name'],
    );
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
  final String status;
  final DateTime bookedAt;
  final String roomLocation;
  final String roomImageUrl;
  final String? approvedBy;

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
    required this.roomLocation,
    required this.roomImageUrl,
    this.approvedBy,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    // Parse the date and convert to local timezone
    DateTime bookingDate;
    try {
      // Parse as UTC and convert to local time
      bookingDate = DateTime.parse(json['booking_date'] ?? DateTime.now().toString()).toLocal();
    } catch (e) {
      // Fallback if parsing fails
      bookingDate = DateTime.now().toLocal();
    }

    // Parse bookedAt with timezone handling
    DateTime bookedAt;
    try {
      bookedAt = DateTime.parse(json['booked_at'] ?? json['created_at'] ?? DateTime.now().toString()).toLocal();
    } catch (e) {
      bookedAt = DateTime.now().toLocal();
    }

    return UserBooking(
      id: json['id']?.toString() ?? json['booking_id']?.toString() ?? '',
      roomName: json['room_name'] ?? '',
      roomId: json['room_id'] ?? '',
      date: bookingDate,
      timeSlot: json['time_slot'] ?? '',
      studentName: json['student_name'] ?? json['user_name'] ?? '',
      studentId: json['student_id'] ?? json['user_id'] ?? '',
      status: json['status'] ?? 'pending',
      bookedAt: bookedAt,
      roomLocation: json['location'] ?? '',
      roomImageUrl: json['image_url'] ?? 'assets/images/default_room.jpg',
      approvedBy: json['approved_by'],
    );
  }
}

// Add these missing classes for lecturer functionality
class Request {
  final String requestId;
  final String roomName;
  final String studentName;
  final String date;
  final String timeSlot;
  final String roomId;
  final String studentId;

  Request({
    required this.requestId,
    required this.roomName,
    required this.studentName,
    required this.date,
    required this.timeSlot,
    required this.roomId,
    required this.studentId,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestId: json['id']?.toString() ?? '',
      roomName: json['room_name'] ?? '',
      studentName: json['student_name'] ?? '',
      date: json['booking_date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      roomId: json['room_id'] ?? '',
      studentId: json['student_id'] ?? '',
    );
  }
}

class HistoryEntry {
  final String roomName;
  final String studentName;
  final bool isApproved;
  final DateTime actionTime;

  HistoryEntry({
    required this.roomName,
    required this.studentName,
    required this.isApproved,
    required this.actionTime,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      roomName: json['room_name'] ?? '',
      studentName: json['student_name'] ?? '',
      isApproved: json['status']?.toString().toLowerCase() == 'approved',
      actionTime: DateTime.parse(json['approved_at'] ?? DateTime.now().toString()).toLocal(),
    );
  }
}

class Room {
  final String name;
  final String subTitle;
  final String group;
  final Color statusColor;
  final String statusText;

  Room({
    required this.name,
    required this.subTitle,
    required this.group,
    required this.statusColor,
    required this.statusText,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name: json['name'] ?? '',
      subTitle: json['location'] ?? '',
      group: json['category'] ?? 'General',
      statusColor: const Color(0xFF26A65B), // Default green
      statusText: 'Available', // Default status
    );
  }
}

// DataStore class to manage the data
class DataStore {
  static List<Request> pendingRequests = [];
  static List<HistoryEntry> historyRecords = [];
  static List<Room> rooms = [];
  static List<BookingRoom> bookingRooms = [];

  // Method to add history entry
  static void addHistoryEntry(Request request, bool approved) {
    historyRecords.insert(0, HistoryEntry(
      roomName: request.roomName,
      studentName: request.studentName,
      isApproved: approved,
      actionTime: DateTime.now(),
    ));
  }

  // Method to load pending requests from API
  static Future<void> loadPendingRequests() async {
    // This will be implemented with API calls
  }

  // Method to load history from API
  static Future<void> loadHistory() async {
    // This will be implemented with API calls
  }

  // Method to load rooms from API
  static Future<void> loadRooms() async {
    // This will be implemented with API calls
  }
}