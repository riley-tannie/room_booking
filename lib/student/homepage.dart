import 'package:flutter/material.dart';
import 'room_list.dart';
import 'request_status.dart';
import 'booking_history.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    RoomList(), 
    RequestStatus(),
    BookingHistory(),
  ];

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Available Rooms';
      case 1:
        return 'Request Status';
      case 2:
        return 'Booking History';
      default:
        return 'Room Reservation';
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
                      _getAppBarTitle(_currentIndex),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Profile()),
                        );
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
            child: _pages[_currentIndex],
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
            _buildNavItem(Icons.pending_actions, 'Requests', 1),
            _buildNavItem(Icons.history, 'History', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            setState(() => _currentIndex = index);
          },
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
