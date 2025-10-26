import 'package:flutter/material.dart';
import 'home_staff.dart';
import 'booking_history.dart';
import 'profile.dart';
import 'edit.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 2; // Dashboard active tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- ส่วนหัว ----------
          Container(
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔹 ข้อความตรงกลาง
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // 🔹 ไอคอนโปรไฟล์อยู่ขนานกันด้านขวา
                  Positioned(
                    right: 18,
                    top: 15,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- เนื้อหา ----------
          Padding(
            padding: const EdgeInsets.only(top: 130),
            child: Column(
              children: [
                const Text(
                  'All Status of Rooms',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: [
                      _buildStatusCard(
                        Icons.pie_chart,
                        'Available',
                        '7',
                        const Color(0xFFB9EACF),
                        const Color(0xFF26A65B),
                      ),
                      _buildStatusCard(
                        Icons.bar_chart,
                        'Pending',
                        '6',
                        const Color(0xFFF6E1A6),
                        const Color(0xFFD4A017),
                      ),
                      _buildStatusCard(
                        Icons.remove_circle_outline,
                        'Reserved',
                        '6',
                        const Color(0xFFCCE5F8),
                        const Color(0xFF428BCA),
                      ),
                      _buildStatusCard(
                        Icons.visibility_off,
                        'Disabled',
                        '5',
                        const Color(0xFFF8C1C1),
                        const Color(0xFFD64541),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ---------- แถบ Navigation ด้านล่าง ----------
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 75,
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
                    MaterialPageRoute(builder: (_) => EditRoomTypesPage()),
                  );
                  break;
                case 2:
                  // Current page
                  break;
                case 3:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BookingHistoryPage()),
                  );
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

  // ---------- การ์ดสถานะ ----------
  Widget _buildStatusCard(
    IconData icon,
    String title,
    String count,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.black87),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
