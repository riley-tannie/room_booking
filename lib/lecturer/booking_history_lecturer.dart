import 'package:flutter/material.dart';
import '../api_service.dart';

class BookingHistoryLecturer extends StatefulWidget {
  const BookingHistoryLecturer({super.key});

  @override
  State<BookingHistoryLecturer> createState() => _BookingHistoryLecturerState();
}

class _BookingHistoryLecturerState extends State<BookingHistoryLecturer> {
  List<dynamic> historyEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    try {
      final user = await ApiService.getCurrentUser();
      if (user == null) {
        setState(() {
          historyEntries = [];
          isLoading = false;
        });
        return;
      }

      final allBookings = await ApiService.getAllBookings();
      setState(() {
        historyEntries = allBookings
            .where((b) =>
                b['approved_by'] == user['uid'] &&
                b['approved_at'] != null &&
                _isToday(b['approved_at']))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading lecturer history: $e');
      setState(() {
        historyEntries = [];
        isLoading = false;
      });
    }
  }

  bool _isToday(String? dateString) {
    if (dateString == null) return false;
    try {
      final date = DateTime.parse(dateString).toLocal();
      final today = DateTime.now().toLocal();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '-';
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : historyEntries.isEmpty
                  ? _buildEmptyHistory()
                  : ListView.builder(
                      itemCount: historyEntries.length,
                      itemBuilder: (context, index) {
                        final entry = historyEntries[index];
                        return _buildHistoryCard(entry);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No Approval History",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your approvals will appear here once you approve or reject a booking.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final isApproved = entry['status'] == 'Approved';
    final sideColor =
        isApproved ? const Color(0xFF26A65B) : const Color(0xFFEF4444);
    final statusColor = sideColor;
    final statusText = isApproved ? 'Approved' : 'Rejected';
    final statusBg = isApproved
        ? const Color(0xFF26A65B).withOpacity(0.1)
        : const Color(0xFFEF4444).withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sideColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['room_name'] ?? 'Unknown Room',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0E3C6E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student: ${entry['student_name'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatDate(entry['booking_date'])} • ${entry['time_slot'] ?? '-'}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'at ${_formatTime(entry['approved_at'])}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              isApproved
                  ? 'Reservation Approved Successfully'
                  : 'Reservation Rejected',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
