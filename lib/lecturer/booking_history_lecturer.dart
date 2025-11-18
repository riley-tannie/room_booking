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
    try {
      final user = await ApiService.getCurrentUser();
      if (user != null) {
        final allBookings = await ApiService.getAllBookings();
        // Filter for approvals by this lecturer and sort with today's first
        setState(() {
          historyEntries = allBookings
              .where((booking) => booking['approved_by'] == user['uid'])
              .toList()
            ..sort((a, b) {
              // Sort by approval date, most recent first (today's first)
              final aDate = DateTime.parse(a['approved_at'] ?? '');
              final bDate = DateTime.parse(b['approved_at'] ?? '');
              return bDate.compareTo(aDate); // Descending order
            });
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading history: $e');
      setState(() {
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

  bool _isYesterday(String? dateString) {
    if (dateString == null) return false;
    try {
      final date = DateTime.parse(dateString).toLocal();
      final yesterday = DateTime.now().toLocal().subtract(const Duration(days: 1));
      return date.year == yesterday.year &&
             date.month == yesterday.month &&
             date.day == yesterday.day;
    } catch (e) {
      return false;
    }
  }

  String _formatActionTime(String? timeString) {
    if (timeString == null) return 'Unknown time';
    try {
      final time = DateTime.parse(timeString).toLocal();
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return 'at $hour:$minute';
    } catch (e) {
      return 'Invalid time';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getRelativeDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    
    if (_isToday(dateString)) return 'Today';
    if (_isYesterday(dateString)) return 'Yesterday';
    
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now().toLocal();
    final difference = now.difference(date).inDays;
    
    if (difference < 7) {
      return '${difference} day${difference > 1 ? 's' : ''} ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks} week${weeks > 1 ? 's' : ''} ago';
    } else {
      return _formatDate(dateString);
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
            "Approval History",
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
          const SizedBox(height: 16),
          
          if (isLoading)
            _buildLoadingState()
          else if (historyEntries.isEmpty)
            _buildEmptyState()
          else
            _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Group entries by date
    final Map<String, List<dynamic>> groupedEntries = {};
    
    for (final entry in historyEntries) {
      final date = DateTime.parse(entry['approved_at'] ?? '').toLocal();
      final dateKey = '${date.year}-${date.month}-${date.day}';
      
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }
    
    // Convert to list and sort by date (most recent first)
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    return Column(
      children: sortedDates.map((dateKey) {
        final entries = groupedEntries[dateKey]!;
        final firstEntry = entries.first;
        final dateString = firstEntry['approved_at'];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _getRelativeDate(dateString),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2A3A),
                ),
              ),
            ),
            ...entries.map((entry) => _buildHistoryCard(context, entry)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading history...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Approval History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Your approval decisions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5473),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh History'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> entry) {
    final isApproved = entry['status'] == 'Approved';
    final color = isApproved ? const Color(0xFF26A65B) : const Color(0xFFEF4444);
    final icon = isApproved ? Icons.check_circle : Icons.cancel;
    final actionText = isApproved ? 'Approved' : 'Rejected';
    final bgColor = isApproved ? const Color(0xFFE8F5E8) : const Color(0xFFFFEBEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry['room_name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student: ${entry['student_name']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Time: ${entry['time_slot']} • ${_formatDate(entry['booking_date'])}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          actionText,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatActionTime(entry['approved_at']),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _showBookingDetails(entry);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      entry['status'] == 'Approved' ? Icons.check_circle : Icons.cancel,
                      color: entry['status'] == 'Approved' ? const Color(0xFF26A65B) : const Color(0xFFEF4444),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Room', entry['room_name']),
                _buildDetailRow('Student', entry['student_name']),
                _buildDetailRow('Date', _formatDate(entry['booking_date'])),
                _buildDetailRow('Time Slot', entry['time_slot']),
                _buildDetailRow('Status', entry['status']),
                _buildDetailRow('Decision Time', _formatActionTime(entry['approved_at'])),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2C5473),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}