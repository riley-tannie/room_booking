import 'package:flutter/material.dart';
import '../api_service.dart';

class AdminPageLecturer extends StatefulWidget {
  const AdminPageLecturer({super.key});

  @override
  State<AdminPageLecturer> createState() => _AdminPageLecturerState();
}

class _AdminPageLecturerState extends State<AdminPageLecturer> {
  List<dynamic> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => isLoading = true);
    try {
      final requests = await ApiService.getAllBookings();
      setState(() {
        pendingRequests = requests
            .where((request) =>
                request['status'] == 'Pending' &&
                request['room_name'] != 'Study Room')
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading pending requests: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleDecision(Map<String, dynamic> request, bool approved) async {
    try {
      final user = await ApiService.getCurrentUser();
      if (user == null) return;

      // ✅ อัปเดต booking status (Node.js จะอัปเดต room_availability ให้อัตโนมัติ)
      await ApiService.updateBookingStatus(
        bookingId: request['id'],
        status: approved ? 'Approved' : 'Rejected',
        approvedBy: user['uid'],
      );

      // ✅ โหลดข้อมูลใหม่หลังอัปเดต
      await _loadPendingRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approved
                ? '✅ Approved: ${request['room_name']} (${request['student_name']})'
                : '❌ Rejected: ${request['room_name']} (${request['student_name']})',
          ),
          backgroundColor: approved ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update booking status'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      if (!dateString.contains('T')) return dateString;
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      if (dateString.contains('T')) return dateString.split('T')[0];
      return dateString;
    }
  }

  String _formatTimeSlot(String timeSlot) {
    try {
      if (timeSlot.contains('-') && !timeSlot.contains('T')) return timeSlot;
      if (timeSlot.contains('T')) {
        final parts = timeSlot.split('/');
        if (parts.length == 2) {
          final startTime = _extractTimeFromISO(parts[0]);
          final endTime = _extractTimeFromISO(parts[1]);
          return '$startTime-$endTime';
        }
      }
      return timeSlot;
    } catch (e) {
      return timeSlot;
    }
  }

  String _extractTimeFromISO(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      if (isoString.contains('T')) {
        final timePart = isoString.split('T')[1];
        if (timePart.contains(':')) {
          final timeComponents = timePart.split(':');
          return "${timeComponents[0]}:${timeComponents[1]}";
        }
      }
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (isLoading)
              const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
            else if (pendingRequests.isEmpty)
              _buildEmptyState()
            else
              _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Approvals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A3A),
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2A3A),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'No pending approval requests',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return Column(
      children: pendingRequests.map((request) => _buildRequestCard(request)).toList(),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final formattedDate = _formatDate(request['booking_date']);
    final formattedTimeSlot = _formatTimeSlot(request['time_slot']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA000),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['room_name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2A3A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request['student_name'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(formattedDate, style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(formattedTimeSlot, style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending_actions, size: 14, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        'Pending Approval',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 🔹 แสดงปุ่ม Approve / Reject ทุกการ์ด
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      icon: Icons.close,
                      label: 'Reject',
                      color: const Color(0xFFEF6666),
                      onPressed: () => _showConfirmationDialog(request, false),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.check,
                      label: 'Approve',
                      color: const Color(0xFF26A65B),
                      onPressed: () => _showConfirmationDialog(request, true),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> request, bool approved) {
    final formattedDate = _formatDate(request['booking_date']);
    final formattedTimeSlot = _formatTimeSlot(request['time_slot']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                approved ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: approved ? const Color(0xFF26A65B) : const Color(0xFFEF6666),
              ),
              const SizedBox(width: 12),
              Text(
                approved ? 'Approve Request?' : 'Reject Request?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${request['student_name']} - ${request['room_name']}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('$formattedDate • $formattedTimeSlot', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              Text(
                approved
                    ? 'This will approve the room booking request.'
                    : 'This will reject the room booking request.',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleDecision(request, approved);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approved ? const Color(0xFF26A65B) : const Color(0xFFEF6666),
                foregroundColor: Colors.white,
              ),
              child: Text(approved ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }
}
