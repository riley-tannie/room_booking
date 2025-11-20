/*import 'package:flutter/material.dart';
import 'dashboard_lecturer.dart';
import 'booking_lecturer.dart';
import 'booking_history_lecturer.dart';
import 'profile_lecturer.dart';

class HomeLecturer extends StatefulWidget {
  @override
  _HomeLecturerState createState() => _HomeLecturerState();
}

class _HomeLecturerState extends State<HomeLecturer> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    DashboardLecturer(),
    BookingLecturer(),
    BookingHistoryLecturer(),
    ProfileLecturer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Book Room',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}*/
