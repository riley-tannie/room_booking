import 'package:flutter/material.dart';
import '../app_theme.dart';

// --- Data Models ---
class Room {
  final String name;
  final String subTitle;
  final String group;
  final String statusText; 
  final Color statusColor;
  final bool isBookable;

  const Room(this.name, this.subTitle, this.group, this.statusText, this.statusColor, {this.isBookable = true});
}

class Request {
  final String studentName;
  final String roomName;
  final String date;
  final String timeSlot;
  final String reason;
  final String requestId;

  const Request({
    required this.studentName,
    required this.roomName,
    required this.date,
    required this.timeSlot,
    required this.reason,
    required this.requestId,
  });
}

class HistoryEntry {
  final String roomName;
  final String studentName;
  final String date;
  final bool isApproved; 
  final DateTime actionTime;

  const HistoryEntry({
    required this.roomName,
    required this.studentName,
    required this.date,
    required this.isApproved,
    required this.actionTime,
  });
}

// --- Central Data Store ---
class DataStore {
  static final List<Room> rooms = [
    const Room('Study Room 2', 'Study Room', 'Multimedia Room', 'See details', AppTheme.primaryDark),
    const Room('Multimedia Room 1', 'Multiweek', 'Multimedia Room', 'See details', AppTheme.primaryDark),
    const Room('Study Room', 'Multimedia Room 1', 'Multimedia Room', 'See details', AppTheme.primaryDark, isBookable: false),
    
    const Room('Lanchester Study Room', 'Library Wing A', 'Library', 'See details', AppTheme.primaryDark, isBookable: false),
    const Room('Lecture Hall 1', 'North Wing', 'Library', 'Reserved', AppTheme.errorColor, isBookable: false),
    const Room('Collaboration Pod 5', 'South Wing', 'Library', 'Book Now', AppTheme.primaryDark),
  ];
  
  static List<Request> pendingRequests = [
    const Request(studentName: 'Aiman Haikal', roomName: 'Multimedia Room 1', date: 'Dec 15, 2025', timeSlot: '10:00 - 12:00', reason: 'Group project discussion.', requestId: 'REQ001'),
    const Request(studentName: 'Siti Nurhaliza', roomName: 'Study Room 2', date: 'Dec 16, 2025', timeSlot: '14:00 - 16:00', reason: 'Preparation for presentation.', requestId: 'REQ002'),
    const Request(studentName: 'Zahir Ariff', roomName: 'Lecture Hall 3', date: 'Dec 15, 2025', timeSlot: '16:00 - 18:00', reason: 'Student club meeting.', requestId: 'REQ003'),
  ];
  
  static List<HistoryEntry> historyRecords = [
    HistoryEntry(roomName: 'Lecture Hall 2', studentName: 'Jane Doe', date: 'Dec 14, 2025', isApproved: true, actionTime: DateTime(2025, 12, 14, 10, 0, 0)),
    HistoryEntry(roomName: 'Collaboration Pod 1', studentName: 'Alex Lee', date: 'Dec 13, 2025', isApproved: false, actionTime: DateTime(2025, 12, 13, 14, 30, 0)),
  ];

  static void addHistoryEntry(Request request, bool approved) {
    final entry = HistoryEntry(
      roomName: request.roomName,
      studentName: request.studentName,
      date: request.date,
      isApproved: approved,
      actionTime: DateTime.now(),
    );
    historyRecords.insert(0, entry);
  }
}
