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

class _DashboardLecturerState extends State<DashboardLecturer>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? dashboardStats;
  bool isLoading = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await ApiService.getTodayDashboardStats();
      setState(() {
        dashboardStats = {
          'free_slots': stats['free_slots'] ?? 0,
          'pending_requests': stats['pending_requests'] ?? 0,
          'reserved_slots': stats['reserved_slots'] ?? 0,
          'disabled_rooms': stats['disabled_rooms'] ?? 0,
        };
        isLoading = false;
        _controller.forward(from: 0);
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() {
        dashboardStats = {
          'free_slots': 0,
          'pending_requests': 0,
          'reserved_slots': 0,
          'disabled_rooms': 0,
        };
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: 1.05,
              children: [
                _buildStatusCard(
                  title: 'Free',
                  count: dashboardStats?['free_slots'] ?? 0,
                  color: const Color(0xFF10B981),
                  icon: Icons.meeting_room_rounded,
                  gradient: const [Color(0xFFDCFCE7), Color(0xFFA7F3D0)],
                  subtitle: 'Available now',
                ),
                _buildStatusCard(
                  title: 'Pending',
                  count: dashboardStats?['pending_requests'] ?? 0,
                  color: const Color(0xFFF59E0B),
                  icon: Icons.pending_actions_rounded,
                  gradient: const [Color(0xFFFFFBEB), Color(0xFFFDE68A)],
                  subtitle: 'Waiting approval',
                ),
                _buildStatusCard(
                  title: 'Reserved',
                  count: dashboardStats?['reserved_slots'] ?? 0,
                  color: const Color(0xFF3B82F6),
                  icon: Icons.verified_rounded,
                  gradient: const [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                  subtitle: 'Approved bookings',
                ),
                _buildStatusCard(
                  title: 'Disabled',
                  count: dashboardStats?['disabled_rooms'] ?? 0,
                  color: const Color(0xFF9CA3AF),
                  icon: Icons.block_rounded,
                  gradient: const [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                  subtitle: 'Not available',
                ),
              ],
            ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required List<Color> gradient,
    required String subtitle,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedCount = (count * _controller.value).toInt();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, size: 28, color: color),
                  ),
                ),
                Text(
                  "$animatedCount",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.9),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
