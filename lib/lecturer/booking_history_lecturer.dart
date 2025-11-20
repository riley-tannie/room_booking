/*import 'package:flutter/material.dart';
import 'room_detail_lecturer.dart';
// 1. Update the import to the new public class name
import 'booking_lecturer.dart'; // Import the whole file, or 'show LecturerStore'

class BookingHistoryLecturer extends StatefulWidget {
  @override
  State<BookingHistoryLecturer> createState() => _BookingHistoryLecturerState();
}

class _BookingHistoryLecturerState extends State<BookingHistoryLecturer> {
  // 2. Update usage
  final store = LecturerStore.instance; // <<< FIXED

  @override
  Widget build(BuildContext context) {
    final bookings = store.history;
    return Scaffold(
      appBar: AppBar(title: Text('Booking History')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: bookings.isEmpty
            ? Center(child: Text('No history yet'))
            : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final status = booking['status'] ?? 'Approved';
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    color: _statusColor(status),
                    child: ListTile(
                      title: Text('Room: ${booking['room']}'),
                      subtitle: Text('Date: ${booking['date']} • Slot: ${booking['slot']} • Student: ${booking['student']}'),
                      trailing: Text(status, style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RoomDetailLecturer(roomName: booking['room'] ?? '')),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green[50]!;
      case 'Rejected':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }
}*/