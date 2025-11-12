import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';

class AdminPageLecturer extends StatefulWidget {
  const AdminPageLecturer({super.key});

  @override
  State<AdminPageLecturer> createState() => _AdminPageLecturerState();
}

class _AdminPageLecturerState extends State<AdminPageLecturer> {
  List<dynamic> pendingRequests = [];
  bool isLoading = true;
  bool _isRefreshing = false;
  
  // For filtering
  String? selectedRoom;
  List<String> availableRooms = [];

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
        pendingRequests = requests
            .where((request) => request['status'] == 'Pending')
            .toList();
        
        // Sort by booking time (oldest first for FIFO processing)
        pendingRequests.sort((a, b) {
          try {
            final aTime = DateTime.parse(a['booked_at'] ?? '');
            final bTime = DateTime.parse(b['booked_at'] ?? '');
            return aTime.compareTo(bTime);
          } catch (e) {
            return 0;
          }
        });
        
        // Extract unique rooms for filter
        availableRooms = pendingRequests
            .map((r) => r['room_name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        
        isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      print('Error loading pending requests: $e');
      setState(() {
        isLoading = false;
        _isRefreshing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDecision(Map<String, dynamic> request, bool approved) async {
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

    try {
      final user = await ApiService.getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Update booking status
      await ApiService.updateBookingStatus(
        bookingId: request['id'],
        status: approved ? 'Approved' : 'Rejected',
        approvedBy: user['uid'],
      );

      // Immediately update UI without refresh
      setState(() {
        pendingRequests.removeWhere((r) => r['id'] == request['id']);
        
        // Update available rooms filter if needed
        availableRooms = pendingRequests
            .map((r) => r['room_name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  approved ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    approved
                        ? 'Approved booking for ${request['student_name']}'
                        : 'Rejected booking for ${request['student_name']}',
                  ),
                ),
              ],
            ),
            backgroundColor: approved ? const Color(0xFF26A65B) : const Color(0xFFEF6666),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () {
                // Could navigate to history page
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error updating booking status: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${approved ? "approve" : "reject"} request: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
    final parts = timeStr.trim().split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isTimeBefore(TimeOfDay a, TimeOfDay b) {
    if (a.hour < b.hour) return true;
    if (a.hour == b.hour && a.minute < b.minute) return true;
    return false;
  }

  String _formatDate(String dateString) {
    try {
      if (!dateString.contains('T')) {
        return dateString;
      }
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      if (dateString.contains('T')) {
        return dateString.split('T')[0];
      }
      return dateString;
    }
  }

  String _formatTimeSlot(String timeSlot) {
    try {
      if (timeSlot.contains('-') && !timeSlot.contains('T')) {
        return timeSlot;
      }
      
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
      return DateFormat('HH:mm').format(dateTime);
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

  String _formatBookedTime(String? bookedAt) {
    if (bookedAt == null) return '';
    try {
      final dateTime = DateTime.parse(bookedAt).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return '';
    }
  }

  List<dynamic> _getFilteredRequests() {
    if (selectedRoom == null) {
      return pendingRequests;
    }
    return pendingRequests.where((r) => r['room_name'] == selectedRoom).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isRefreshing = true;
          });
          await _loadPendingRequests();
        },
        color: const Color(0xFF2C5473),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              
              // Filter section
              if (availableRooms.isNotEmpty)
                _buildFilterSection(),
              const SizedBox(height: 16),
              
              if (isLoading)
                _buildLoadingState()
              else if (filteredRequests.isEmpty)
                _buildEmptyState()
              else
                _buildRequestsList(filteredRequests),
            ],
          ),
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Approvals',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Review and manage room booking requests',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
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
                _isRefreshing ? Icons.sync : Icons.refresh,
                color: const Color(0xFF2C5473),
                size: 28,
              ),
              tooltip: 'Refresh requests',
            ),
          ],
        ),
        const SizedBox(height: 12),
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
              const Icon(
                Icons.info_outline,
                color: Color(0xFF2C5473),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Expired time slots are marked and cannot be approved. Pull down to refresh.',
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20, color: Color(0xFF2C5473)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedRoom,
              decoration: const InputDecoration(
                labelText: 'Filter by Room',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Rooms')),
                ...availableRooms.map((room) => 
                  DropdownMenuItem(value: room, child: Text(room)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRoom = value;
                });
              },
            ),
          ),
          if (selectedRoom != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedRoom = null;
                });
              },
              icon: const Icon(Icons.clear, size: 20),
              tooltip: 'Clear filter',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5473)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading requests...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedRoom != null ? Icons.search_off : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              selectedRoom != null ? 'No Requests for This Room' : 'All Caught Up!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              selectedRoom != null
                  ? 'Try selecting a different room'
                  : 'No pending approval requests',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: selectedRoom != null
                  ? () => setState(() => selectedRoom = null)
                  : _loadPendingRequests,
              icon: Icon(selectedRoom != null ? Icons.clear : Icons.refresh, size: 18),
              label: Text(selectedRoom != null ? 'Clear Filter' : 'Refresh'),
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

  Widget _buildRequestsList(List<dynamic> requests) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA000).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: Color(0xFFFFA000),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${requests.length} ${requests.length == 1 ? 'request' : 'requests'} pending',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    if (selectedRoom != null)
                      Text(
                        'Filtered by: $selectedRoom',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                'Tap to approve/reject',
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
        ...requests.map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final isValid = _isValidTimeSlot(request['time_slot']);
    final formattedDate = _formatDate(request['booking_date']);
    final formattedTimeSlot = _formatTimeSlot(request['time_slot']);
    final bookedAgo = _formatBookedTime(request['booked_at']);

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
            // Header row with urgency indicator
            Row(
              children: [
                // Urgency indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isValid ? const Color(0xFFFFA000) : Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request['room_name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2A3A),
                              ),
                            ),
                          ),
                          if (bookedAgo.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                bookedAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Date and time
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedTimeSlot,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
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
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Action section
            if (isValid) ...[
              Row(
                children: [
                  // Status badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(8),
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
                            'Awaiting Decision',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Action buttons
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
              // Expired slot warning
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 20,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Slot Expired',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This booking can no longer be approved',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
        elevation: 0,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: approved 
                      ? const Color(0xFF26A65B).withOpacity(0.1)
                      : const Color(0xFFEF6666).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  approved ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: approved ? const Color(0xFF26A65B) : const Color(0xFFEF6666),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  approved ? 'Approve Request?' : 'Reject Request?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogDetailRow(
                      'Student',
                      request['student_name'],
                      Icons.person,
                    ),
                    const Divider(height: 16),
                    _buildDialogDetailRow(
                      'Room',
                      request['room_name'],
                      Icons.meeting_room,
                    ),
                    const Divider(height: 16),
                    _buildDialogDetailRow(
                      'Date',
                      formattedDate,
                      Icons.calendar_today,
                    ),
                    const Divider(height: 16),
                    _buildDialogDetailRow(
                      'Time',
                      formattedTimeSlot,
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                approved
                    ? 'This will confirm the room booking for the student.'
                    : 'This will reject the booking request. The student will be notified.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(approved ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2A3A),
            ),
          ),
        ),
      ],
    );
  }
}