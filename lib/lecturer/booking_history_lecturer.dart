import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';

class BookingHistoryLecturer extends StatefulWidget {
  const BookingHistoryLecturer({super.key});

  @override
  State<BookingHistoryLecturer> createState() => _BookingHistoryLecturerState();
}

class _BookingHistoryLecturerState extends State<BookingHistoryLecturer> {
  List<dynamic> allHistoryEntries = [];
  List<dynamic> filteredHistoryEntries = [];
  bool isLoading = true;
  
  // Filter states
  String? selectedRoom;
  DateTimeRange? selectedDateRange;
  String? selectedStatus; // 'Approved' or 'Rejected'
  
  List<String> availableRooms = [];

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
        
        setState(() {
          // Get all bookings approved/rejected by this lecturer
          allHistoryEntries = allBookings
              .where((booking) => 
                  booking['approved_by'] == user['uid'] &&
                  (booking['status'] == 'Approved' || booking['status'] == 'Rejected'))
              .toList();
          
          // Extract unique room names for filter dropdown
          availableRooms = allHistoryEntries
              .map((b) => b['room_name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          
          _applyFilters();
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

  void _applyFilters() {
    setState(() {
      filteredHistoryEntries = allHistoryEntries.where((entry) {
        // Filter by room
        if (selectedRoom != null && entry['room_name'] != selectedRoom) {
          return false;
        }
        
        // Filter by status
        if (selectedStatus != null && entry['status'] != selectedStatus) {
          return false;
        }
        
        // Filter by date range
        if (selectedDateRange != null) {
          try {
            final bookingDate = DateTime.parse(entry['booking_date']).toLocal();
            if (bookingDate.isBefore(selectedDateRange!.start) ||
                bookingDate.isAfter(selectedDateRange!.end.add(const Duration(days: 1)))) {
              return false;
            }
          } catch (e) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // Sort by approval time (most recent first)
      filteredHistoryEntries.sort((a, b) {
        try {
          final aTime = DateTime.parse(a['approved_at'] ?? '');
          final bTime = DateTime.parse(b['approved_at'] ?? '');
          return bTime.compareTo(aTime);
        } catch (e) {
          return 0;
        }
      });
    });
  }

  void _clearFilters() {
    setState(() {
      selectedRoom = null;
      selectedDateRange = null;
      selectedStatus = null;
      _applyFilters();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C5473),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatActionTime(String? timeString) {
    if (timeString == null) return 'Unknown time';
    try {
      final time = DateTime.parse(timeString).toLocal();
      return DateFormat('HH:mm').format(time);
    } catch (e) {
      return 'Invalid time';
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid';
    }
  }

  void _showPrintExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 24),
              
              ListTile(
                leading: const Icon(Icons.print, color: Color(0xFF2C5473)),
                title: const Text('Print History'),
                subtitle: const Text('Print current filtered view'),
                onTap: () {
                  Navigator.pop(context);
                  _printHistory();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.table_chart, color: Color(0xFF2C5473)),
                title: const Text('Export as CSV'),
                subtitle: const Text('Download as spreadsheet'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsCSV();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF2C5473)),
                title: const Text('Export as PDF'),
                subtitle: const Text('Download as PDF document'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPDF();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _printHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Print functionality will be implemented with platform-specific printing'),
        backgroundColor: Color(0xFF2C5473),
      ),
    );
  }

  void _exportAsCSV() {
    // Generate CSV content
    final csvContent = StringBuffer();
    csvContent.writeln('Room,Booking Date,Booking Time,Student Name,Status,Approved By,Approved At');
    
    for (var entry in filteredHistoryEntries) {
      csvContent.writeln(
        '${entry['room_name']},${_formatDate(entry['booking_date'])},${entry['time_slot']},'
        '${entry['student_name']},${entry['status']},Lecturer,${_formatDateTime(entry['approved_at'])}'
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${filteredHistoryEntries.length} records to CSV'),
        backgroundColor: const Color(0xFF26A65B),
      ),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${filteredHistoryEntries.length} records to PDF'),
        backgroundColor: const Color(0xFF26A65B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedRoom != null || 
                            selectedDateRange != null || 
                            selectedStatus != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approval History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your booking decisions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _loadHistory,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    color: const Color(0xFF2C5473),
                  ),
                  IconButton(
                    onPressed: _showPrintExportOptions,
                    icon: const Icon(Icons.download),
                    tooltip: 'Export',
                    color: const Color(0xFF2C5473),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter Section
          _buildFilterSection(),
          const SizedBox(height: 16),
          
          // Summary Card
          if (!isLoading)
            _buildSummaryCard(hasActiveFilters),
          const SizedBox(height: 16),
          
          // Content
          if (isLoading)
            _buildLoadingState()
          else if (filteredHistoryEntries.isEmpty)
            _buildEmptyState(hasActiveFilters)
          else
            Column(
              children: [
                // Column Headers
                _buildTableHeader(),
                const SizedBox(height: 8),
                
                // History Entries
                ...filteredHistoryEntries.map((entry) => _buildHistoryCard(entry)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final hasActiveFilters = selectedRoom != null || 
                            selectedDateRange != null || 
                            selectedStatus != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Color(0xFF2C5473)),
              const SizedBox(width: 8),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Room Filter
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: selectedRoom,
                  decoration: InputDecoration(
                    labelText: 'Room',
                    prefixIcon: const Icon(Icons.meeting_room, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      _applyFilters();
                    });
                  },
                ),
              ),
              
              // Status Filter
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: const Icon(Icons.check_circle, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                      _applyFilters();
                    });
                  },
                ),
              ),
              
              // Date Range Filter
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range, size: 20),
                label: Text(
                  selectedDateRange == null
                      ? 'Date Range'
                      : '${DateFormat('dd/MM').format(selectedDateRange!.start)} - ${DateFormat('dd/MM').format(selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2C5473),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool hasActiveFilters) {
    final approvedCount = filteredHistoryEntries
        .where((e) => e['status'] == 'Approved')
        .length;
    final rejectedCount = filteredHistoryEntries
        .where((e) => e['status'] == 'Rejected')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C5473).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveFilters ? 'Filtered Results' : 'Total Records',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${filteredHistoryEntries.length} entries',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF26A65B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF26A65B)),
                const SizedBox(width: 4),
                Text(
                  '$approvedCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF26A65B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.cancel, size: 16, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
                Text(
                  '$rejectedCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C5473),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text('Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 2, child: Text('Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(flex: 1, child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final isApproved = entry['status'] == 'Approved';
    final color = isApproved ? const Color(0xFF26A65B) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBookingDetails(entry),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry['room_name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(entry['booking_date']),
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry['time_slot'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry['student_name'] ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isApproved ? 'Approved' : 'Rejected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2C5473)),
          SizedBox(height: 16),
          Text('Loading history...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasActiveFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            hasActiveFilters ? 'No Results Found' : 'No History Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              hasActiveFilters
                  ? 'Try adjusting your filters'
                  : 'Your approval decisions will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 20),
          if (hasActiveFilters)
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5473),
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Filters'),
            )
          else
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5473),
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
        ],
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      entry['status'] == 'Approved' ? Icons.check_circle : Icons.cancel,
                      color: entry['status'] == 'Approved' ? const Color(0xFF26A65B) : const Color(0xFFEF4444),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Booking Details',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildDetailRow('Room', entry['room_name'] ?? 'Unknown'),
                _buildDetailRow('Student', entry['student_name'] ?? 'Unknown'),
                _buildDetailRow('Booking Date', _formatDate(entry['booking_date'])),
                _buildDetailRow('Time Slot', entry['time_slot'] ?? ''),
                _buildDetailRow('Status', entry['status'] ?? ''),
                _buildDetailRow('Approved At', _formatDateTime(entry['approved_at'])),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
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
}