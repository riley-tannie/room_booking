import 'package:flutter/material.dart';
import 'home_staff.dart';
import 'booking_history.dart';
import 'profile.dart';
import 'staff_management.dart';
import '../api_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 2;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await ApiService.getTodayDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      // Fallback to default stats
      setState(() {
        _stats = {
          'free_slots': 0,
          'pending_slots': 0,
          'reserved_slots': 0,
          'disabled_rooms': 0,
          'pending_requests': 0,
          'approved_today': 0,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Column(
        children: [
          // Header - Keeping the original app bar
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Today is ${_getFormattedDate()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Statistics Grid
                  const Text(
                    'Room Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_isLoading)
                    _buildLoadingGrid()
                  else
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatusCard(
                          'Free Slots', 
                          _stats['free_slots']?.toString() ?? '0', 
                          const Color(0xFF26A65B), 
                          Icons.check_circle_outline,
                          'Available for booking'
                        ),
                        _buildStatusCard(
                          'Pending Requests', 
                          _stats['pending_requests']?.toString() ?? '0', 
                          const Color(0xFFF59E0B), 
                          Icons.pending_actions,
                          'Awaiting approval'
                        ),
                        _buildStatusCard(
                          'Reserved Slots', 
                          _stats['reserved_slots']?.toString() ?? '0', 
                          const Color(0xFF428BCA), 
                          Icons.book_online,
                          'Confirmed bookings'
                        ),
                        _buildStatusCard(
                          'Disabled Rooms', 
                          _stats['disabled_rooms']?.toString() ?? '0', 
                          const Color(0xFF6B7280), 
                          Icons.block,
                          'Unavailable rooms'
                        ),
                        _buildStatusCard(
                          'Approved Today', 
                          _stats['approved_today']?.toString() ?? '0', 
                          const Color(0xFF388E3C), 
                          Icons.verified,
                          'Approved bookings'
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation - Keeping the original bottom navigation
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
            _buildNavItem(Icons.admin_panel_settings, 'Admin', 1),
            _buildNavItem(Icons.dashboard, 'Dashboard', 2),
            _buildNavItem(Icons.history, 'History', 3),
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
                  MaterialPageRoute(builder: (_) => StaffManagementPage()),
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

  Widget _buildLoadingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildLoadingCard(),
        _buildLoadingCard(),
        _buildLoadingCard(),
        _buildLoadingCard(),
        _buildLoadingCard(),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const Spacer(),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}