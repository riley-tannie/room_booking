import 'package:flutter/material.dart';
import '../app_theme.dart';
// 1. Update imports
import 'booking_lecturer.dart'; 
import 'booking_history_lecturer.dart';

class DashboardLecturer extends StatefulWidget {
  @override
  State<DashboardLecturer> createState() => _DashboardLecturerState();
}

class _DashboardLecturerState extends State<DashboardLecturer> {
  // 2. Update usage
  final store = LecturerStore.instance; // <<< FIXED

  @override
  Widget build(BuildContext context) {
    final total = store.history.length;
    final approved = store.history.where((h) => h['status'] == 'Approved').length;
    final rejected = store.history.where((h) => h['status'] == 'Rejected').length;
    final pending = store.pending.length;

    return Scaffold(
      appBar: AppBar(title: Text('Lecturer Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assuming AppTheme.textTheme.displaySmall is defined elsewhere
            // Text('Welcome, Lecturer 👋', style: AppTheme.textTheme.displaySmall),
            Text('Welcome, Lecturer 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Temporary style
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Total Bookings', '$total', Colors.blue),
                _buildStatCard('Pending', '$pending', Colors.orange),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Approved', '$approved', Colors.green),
                _buildStatCard('Rejected', '$rejected', Colors.red),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingLecturer()));
                setState(() {}); // refresh counters after returning
              },
              icon: Icon(Icons.rule),
              label: Text('Review Pending Requests'),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => BookingHistoryLecturer()));
                setState(() {});
              },
              icon: Icon(Icons.history),
              label: Text('View Booking History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}