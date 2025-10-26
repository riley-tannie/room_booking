import 'package:flutter/material.dart';
import 'home_staff.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'room_detail.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  int _currentIndex = 3; // History active

  final List<Map<String, String>> _rooms = [
    {'name': 'Multimedia Room 1', 'image': 'https://picsum.photos/200/150?1'},
    {'name': 'Lecture Hall 3', 'image': 'https://picsum.photos/200/150?2'},
    {'name': 'Study Room 4', 'image': 'https://picsum.photos/200/150?3'},
    {'name': 'Lecture Hall 7', 'image': 'https://picsum.photos/200/150?4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- The Head part  ----------
          Container(
            height: 110, // 🔹 เท่ากับ Dashboard
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473), // 🔹 สีเดียวกัน
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(70), // 🔹 มุมโค้งเท่ากัน
              ),
            ),
            child: const SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Your Booking History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20, // 🔹 ขนาดตัวอักษรเท่ากัน
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // ---------- Content ----------
          Padding(
            padding: const EdgeInsets.only(top: 130, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: _rooms
                    .map(
                      (room) =>
                          _buildHistoryItem(room['name']!, room['image']!),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),

      // ---------- Navigation Bar ----------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xFF2C5473), // 🔹 สีพื้นหลังเหมือนหัว
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF2C5473),
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: (index) {
              setState(() => _currentIndex = index);
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeStaff()),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                  break;
                case 2:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );
                  break;
                case 3:
                  // Current page
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.meeting_room),
                label: 'Rooms',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- card show room ----------
  Widget _buildHistoryItem(String name, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RoomDetailPage()),
                  );
                },
                child: const Text(
                  'See detail',
                  style: TextStyle(
                    color: Color(0xFF204C72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
