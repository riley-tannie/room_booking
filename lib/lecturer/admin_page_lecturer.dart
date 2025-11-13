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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    if (!_isRefreshing) {
      setState(() {
        isLoading = true;
      });
    }
    
    try {
      final requests = await ApiService.getAllBookings();
      setState(() {
        pendingRequests = requests.where((request) => request['status'] == 'Pending').toList();
        isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      print('Error loading pending requests: $e');
      setState(() {
        isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleDecision(Map<String, dynamic> request, bool approved) async {
    try {
      // Check if time slot is still valid
      if (!_isValidTimeSlot(request['time_slot'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot process expired time slot: ${request['time_slot']}'),
            backgroundColor: Colors.orange,
          ),
        );
        await _loadPendingRequests(); // Refresh to remove expired slots
        return;
      }

      final user = await ApiService.getCurrentUser();
      if (user == null) return;

      await ApiService.updateBookingStatus(
        bookingId: request['id'],
        status: approved ? 'Approved' : 'Rejected',
        approvedBy: user['uid'],
      );

      setState(() {
        pendingRequests.removeWhere((r) => r['id'] == request['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${approved ? "approved" : "rejected"} for ${request['student_name']}'),
          backgroundColor: approved ? const Color(0xFF26A65B) : const Color(0xFFEF6666),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating booking status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${approved ? "approve" : "reject"} request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidTimeSlot(String timeSlot) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Parse time slot (format: "08:00-10:00")
    final times = timeSlot.split('-');
    if (times.length != 2) return true; // Fallback if parsing fails
    
    try {
      final slotEnd = _parseTime(times[1]);
      // Check if current time is before slot end time
      return _isTimeBefore(currentTime, slotEnd);
    } catch (e) {
      return true; // Fallback if time parsing fails
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isTimeBefore(TimeOfDay a, TimeOfDay b) {
    if (a.hour < b.hour) return true;
    if (a.hour == b.hour && a.minute < b.minute) return true;
    return false;
  }

  // Format date to remove timezone and time part
  String _formatDate(String dateString) {
    try {
      // If it's already in a simple format, return as is
      if (!dateString.contains('T')) {
        return dateString;
      }
      
      // Parse ISO format and return only the date part
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      // If parsing fails, try to extract date part manually
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString; // Return original if all else fails
    }
  }

  // Format time slot to remove timezone information
  String _formatTimeSlot(String timeSlot) {
    try {
      // If it's already in simple format (08:00-10:00), return as is
      if (timeSlot.contains('-') && !timeSlot.contains('T')) {
        return timeSlot;
      }
      
      // Handle ISO format time slots
      if (timeSlot.contains('T')) {
        final parts = timeSlot.split('/');
        if (parts.length == 2) {
          final startTime = _extractTimeFromISO(parts[0]);
          final endTime = _extractTimeFromISO(parts[1]);
          return '$startTime-$endTime';
        }
      }
      
      return timeSlot; // Return original if format is unknown
    } catch (e) {
      return timeSlot; // Return original if parsing fails
    }
  }

  String _extractTimeFromISO(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      // Fallback: try to extract time manually
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
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),
            
            if (isLoading)
              _buildLoadingState()
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pending Approvals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isRefreshing = true;
                });
                _loadPendingRequests();
              },
              icon: Icon(
                Icons.refresh,
                color: const Color(0xFF2C5473),
                size: 28,
              ),
              tooltip: 'Refresh requests',
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage room booking requests from students',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C5473).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF2C5473),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Expired time slots will be automatically marked and cannot be approved',
                  style: TextStyle(
                    color: const Color(0xFF2C5473),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5473)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading requests...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No pending approval requests',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPendingRequests,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5473),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    return Column(
      children: [
        // Summary bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${pendingRequests.length} request${pendingRequests.length == 1 ? '' : 's'} pending',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              Text(
                'Tap buttons to approve/reject',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Requests list
        ...pendingRequests.map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final isValid = _isValidTimeSlot(request['time_slot']);
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
          color: isValid ? Colors.grey[200]! : Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main request info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isValid ? const Color(0xFFFFA000) : Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Request details
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
                      
                      // Student info
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
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
                      
                      // Date and time - FIXED: Use formatted date and time
                      Wrap(
                        spacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedTimeSlot,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
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
            
            // Action section - FIXED: Use Wrap instead of Row to prevent overflow
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending_actions,
                        size: 14,
                        color: Colors.orange[800],
                      ),
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
                
                // Action buttons or expired message
                if (isValid) ...[
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
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 16,
                          color: Colors.red[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Time Slot Expired',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            // Expired notice
            if (!isValid) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This time slot has ended and cannot be approved',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> request, bool approved) {
    final formattedDate = _formatDate(request['booking_date']);
    final formattedTimeSlot = _formatTimeSlot(request['time_slot']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request['student_name']} - ${request['room_name']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$formattedDate • $formattedTimeSlot',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                approved
                    ? 'This will approve the room booking request.'
                    : 'This will reject the room booking request.',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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