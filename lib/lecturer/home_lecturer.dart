import 'package:flutter/material.dart';
import 'dashboard_lecturer.dart';
import 'room_list_page_lecturer.dart';
import 'booking_history_lecturer.dart';
import 'profile_lecturer.dart';
import 'admin_page_lecturer.dart';

class HomeLecturer extends StatefulWidget {
  const HomeLecturer({super.key});

  @override
  State<HomeLecturer> createState() => _HomeLecturerState();
}

class _HomeLecturerState extends State<HomeLecturer> {
  int currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final PageStorageBucket bucket = PageStorageBucket();

  late final List<Widget> _pages = [
    const RoomListPageLecturer(key: PageStorageKey('pageRooms')),
    const AdminPageLecturer(key: PageStorageKey('pageAdmin')),
    DashboardLecturer(
      key: const PageStorageKey('pageDashboard'),
      onNavigateToAdmin: () => setIndex(1),
      onNavigateToHistory: () => setIndex(3),
    ),
    const BookingHistoryLecturer(key: PageStorageKey('pageHistory')),
    const ProfileLecturer(key: PageStorageKey('pageProfile')),
  ];

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Available Rooms';
      case 1:
        return 'Admin Panel';
      case 2:
        return 'Dashboard';
      case 3:
        return 'Booking History';
      case 4:
        return 'Profile';
      default:
        return 'Available Rooms';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- Header ----------
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _getAppBarTitle(currentIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setIndex(4); // Navigate to Profile page
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Body ----------
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: PageStorage(bucket: bucket, child: _pages[currentIndex]),
          ),
        ],
      ),

      // ---------- Floating Bottom Navigation ----------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2C5473),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(Icons.meeting_room, 'Rooms', 0),
            _buildNavItem(Icons.rule, 'Admin', 1),
            _buildNavItem(Icons.dashboard, 'Dashboard', 2),
            _buildNavItem(Icons.history, 'History', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => setIndex(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}