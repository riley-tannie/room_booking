import 'package:flutter/material.dart';

class RoomDetailLecturer extends StatelessWidget {
  final String roomName;

  RoomDetailLecturer({required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$roomName Details')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: $roomName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Location: Building A, Floor 2'),
            SizedBox(height: 10),
            Text('Capacity: 40 People'),
            SizedBox(height: 10),
            Text('Equipment: Projector, Whiteboard'),
            SizedBox(height: 20),
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Suitable for lectures, seminars, and group discussions.', style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),
            Text('Note: Approve/Reject is done from the Pending screen.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
