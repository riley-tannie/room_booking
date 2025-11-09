import 'package:flutter/material.dart';
import '../api_service.dart';

class DashboardLecturer extends StatefulWidget {
  final VoidCallback onNavigateToAdmin;
  final VoidCallback onNavigateToHistory;

  const DashboardLecturer({
    super.key,
    required this.onNavigateToAdmin,
    required this.onNavigateToHistory,
  });

  @override
  State<DashboardLecturer> createState() => _DashboardLecturerState();
}

class _DashboardLecturerState extends State<DashboardLecturer> {
  Map<String, dynamic>? dashboardStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      // Use today-specific dashboard stats
      final stats = await ApiService.getTodayDashboardStats();
      // Ensure we have valid numbers, default to 0 if null
      setState(() {
        dashboardStats = {
          'free_slots': stats['free_slots'] ?? 0,
          'pending_slots': stats['pending_slots'] ?? 0,
          'reserved_slots': stats['reserved_slots'] ?? 0,
          'disabled_rooms': stats['disabled_rooms'] ?? 0,
          'pending_requests': stats['pending_requests'] ?? 0,
          'approved_today': stats['approved_today'] ?? 0,
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      // Fallback to default values
      setState(() {
        dashboardStats = {
          'free_slots': 0,
          'pending_slots': 0,
          'reserved_slots': 0,
          'disabled_rooms': 0,
          'pending_requests': 0,
          'approved_today': 0,
        };
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            'Statistics for ${_getFormattedDate()}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),
          
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
          
          if (isLoading)
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
                  dashboardStats?['free_slots']?.toString() ?? '0', 
                  const Color(0xFF26A65B), 
                  Icons.check_circle_outline,
                  'Available for booking'
                ),
                _buildStatusCard(
                  'Pending Requests', 
                  dashboardStats?['pending_requests']?.toString() ?? '0', 
                  const Color(0xFFF59E0B), 
                  Icons.pending_actions,
                  'Awaiting approval'
                ),
                _buildStatusCard(
                  'Approved Today', 
                  dashboardStats?['reserved_slots']?.toString() ?? '0', 
                  const Color(0xFF428BCA), 
                  Icons.verified,
                  'Confirmed bookings'
                ),
                _buildStatusCard(
                  'Disabled Rooms', 
                  dashboardStats?['disabled_rooms']?.toString() ?? '0', 
                  const Color(0xFF6B7280), 
                  Icons.block,
                  'Unavailable rooms'
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onNavigateToAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5473),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.rule, size: 20),
                  label: const Text(
                    'Manage Requests',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onNavigateToHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8EDF1),
                    foregroundColor: const Color(0xFF2C5473),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text(
                    'View History',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
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