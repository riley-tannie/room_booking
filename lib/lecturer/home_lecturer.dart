import 'package:flutter/material.dart';
import 'room_list_lecturer.dart';
import 'admin_lecturer.dart';
import 'booking_history_lecturer.dart';
import 'profile_lecturer.dart';

class HomeLecturer extends StatefulWidget {
  const HomeLecturer({super.key});

  @override
  State<HomeLecturer> createState() => _HomeLecturerState();
}

class _HomeLecturerState extends State<HomeLecturer> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RoomListLecturer(),
    const AdminLecturer(),
    const BookingHistoryLecturer(),
  ];

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Available Rooms';
      case 1: return 'Pending Requests';
      case 2: return 'Booking History';
      default: return 'Available Rooms';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileLecturer()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rule),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}