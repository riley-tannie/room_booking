// time_slots.dart
import 'package:flutter/material.dart';

class TimeSlot {
  final String timeRange;
  final String status; // 'free', 'pending', 'reserved', 'disabled'
  final String? bookedBy;
  final String? requestId;

  TimeSlot({
    required this.timeRange,
    required this.status,
    this.bookedBy,
    this.requestId,
  });
}

class TimeSlotManager {
  static List<TimeSlot> getTodaysTimeSlots(String roomName) {
    // Mock data - replace with actual logic based on room name
    if (roomName.contains('Multimedia')) {
      return [
        TimeSlot(timeRange: '8:00 - 10:00', status: 'free'),
        TimeSlot(timeRange: '10:00 - 12:00', status: 'pending', bookedBy: 'Aiman Haikal', requestId: 'REQ001'),
        TimeSlot(timeRange: '13:00 - 15:00', status: 'free'),
        TimeSlot(timeRange: '15:00 - 17:00', status: 'reserved', bookedBy: 'Jane Doe'),
      ];
    } else if (roomName.contains('Study')) {
      return [
        TimeSlot(timeRange: '8:00 - 10:00', status: 'free'),
        TimeSlot(timeRange: '10:00 - 12:00', status: 'free'),
        TimeSlot(timeRange: '13:00 - 15:00', status: 'pending', bookedBy: 'Siti Nurhaliza', requestId: 'REQ002'),
        TimeSlot(timeRange: '15:00 - 17:00', status: 'free'),
      ];
    } else {
      return [
        TimeSlot(timeRange: '8:00 - 10:00', status: 'reserved', bookedBy: 'Alex Lee'),
        TimeSlot(timeRange: '10:00 - 12:00', status: 'free'),
        TimeSlot(timeRange: '13:00 - 15:00', status: 'free'),
        TimeSlot(timeRange: '15:00 - 17:00', status: 'disabled'),
      ];
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'free': return Colors.green;
      case 'pending': return Colors.orange;
      case 'reserved': return Colors.blue;
      case 'disabled': return Colors.red;
      default: return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'free': return Icons.check_circle;
      case 'pending': return Icons.pending;
      case 'reserved': return Icons.event_available;
      case 'disabled': return Icons.block;
      default: return Icons.help;
    }
  }

  static bool isTimeSlotAvailable(String status) {
    return status == 'free';
  }

  static bool canBookTimeSlot(String status) {
    return status == 'free';
  }
}