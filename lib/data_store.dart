import 'package:flutter/material.dart';

class BookingRoom {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final String description;
  bool isDisabled;
  List<TimeSlot> timeSlots;

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

  factory BookingRoom.fromJson(Map<String, dynamic> json) {
    return BookingRoom(
      id: json['id']?.toString() ?? json['room_id']?.toString() ?? '',
      name: json['name'] ?? json['room_name'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['image_url'] ?? 'assets/images/default_room.jpg',
      description: json['description'] ?? '',
      isDisabled: (json['is_disabled'] ?? 0) == 1,
      timeSlots: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'image_url': imageUrl,
      'description': description,
      'is_disabled': isDisabled ? 1 : 0,
    };
  }

  BookingRoom copyWith({
    String? name,
    String? location,
    String? description,
    bool? isDisabled,
    List<TimeSlot>? timeSlots,
  }) {
    return BookingRoom(
      id: id,
      name: name ?? this.name,
      category: category,
      location: location ?? this.location,
      imageUrl: imageUrl,
      description: description ?? this.description,
      timeSlots: timeSlots ?? this.timeSlots,
      isDisabled: isDisabled ?? this.isDisabled,
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
  final String? studentId;
  final String? bookingId;

  TimeSlot({
    required this.id,
    required this.time,
    required this.status,
    required this.displayStatus,
    required this.color,
    this.studentName,
    this.studentId,
    this.bookingId,
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
      studentId: json['student_id'],
      bookingId: json['booking_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_slot': time,
      'status': status,
      'student_id': studentId,
      'booking_id': bookingId,
    };
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
  final String? approvedByName;
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
    this.approvedByName,
    this.approvedBy,
  });

  factory UserBooking.fromJson(Map<String, dynamic> json) {
    DateTime bookingDate;
    try {
      bookingDate = DateTime.parse(json['booking_date'] ?? DateTime.now().toString()).toLocal();
    } catch (e) {
      bookingDate = DateTime.now().toLocal();
    }

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
      approvedByName: json['approved_by_name']?.toString(),
      approvedBy: json['approved_by'],
    );
  }
}

// DataStore class to manage the data
class DataStore {
  static List<BookingRoom> bookingRooms = [];

  // Method to load rooms from API
  static Future<void> loadRooms() async {
    // This will be implemented with API calls
  }
}