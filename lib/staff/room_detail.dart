import 'package:flutter/material.dart';
import '../data_store.dart';
import '../api_service.dart';

class RoomDetailPage extends StatefulWidget {
  final BookingRoom room;
  final UserBooking? booking;

  const RoomDetailPage({Key? key, required this.room, this.booking}) : super(key: key);

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  late BookingRoom _room;
  bool _isLoading = false;
  List<dynamic> _timeSlots = [];

  // Define all possible time slots
  final List<String> _allTimeSlots = ['08:00-10:00', '10:00-12:00', '13:00-15:00', '15:00-17:00'];

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the lecturer API to get all time slots including status and student info
      final timeSlotsData = await ApiService.getTodayTimeSlots(_room.id);
      
      // Ensure we have all 4 time slots, fill in missing ones
      final List<dynamic> allSlots = [];
      
      for (String slotTime in _allTimeSlots) {
        final existingSlot = timeSlotsData.firstWhere(
          (slot) => slot['time_slot'] == slotTime,
          orElse: () => null,
        );
        
        if (existingSlot != null) {
          allSlots.add(existingSlot);
        } else {
          // Create a default slot for missing time slots
          allSlots.add({
            'time_slot': slotTime,
            'status': 'free', // Default to free if not found
            'student_name': '',
          });
        }
      }
      
      setState(() {
        _timeSlots = allSlots;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading room details with lecturer API: $e');
      // Fallback: create default slots for all time slots
      final defaultSlots = _allTimeSlots.map((slotTime) => {
        'time_slot': slotTime,
        'status': 'free',
        'student_name': '',
      }).toList();
      
      setState(() {
        _timeSlots = defaultSlots;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return const Color(0xFF26A65B);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'reserved':
        return const Color(0xFFEF4444);
      case 'disabled':
        return const Color(0xFF6B7280);
      case 'time_passed':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return 'Available';
      case 'pending':
        return 'Pending';
      case 'reserved':
        return 'Reserved';
      case 'disabled':
        return 'Disabled';
      case 'time_passed':
        return 'Time Passed';
      default:
        return 'Unknown';
    }
  }

  bool _isTimePassed(String timeSlot) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    
    // Parse the end time from time slot string (e.g., "08:00-10:00")
    try {
      final endTimeStr = timeSlot.split('-')[1];
      final endHours = int.parse(endTimeStr.split(':')[0]);
      final endMinutes = int.parse(endTimeStr.split(':')[1]);
      final slotEndTime = endHours * 60 + endMinutes;
      
      return currentTime >= slotEndTime;
    } catch (e) {
      return false;
    }
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    String status = slot['status']?.toString() ?? 'free';
    final timeSlot = slot['time_slot']?.toString() ?? '';
    final studentName = slot['student_name']?.toString() ?? '';
    
    // Check if time has passed and override status
    if (_isTimePassed(timeSlot)) {
      status = 'time_passed';
    }
    
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeSlot,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: status == 'time_passed' ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (studentName.isNotEmpty && status != 'time_passed') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Booked by: $studentName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(const Color(0xFF26A65B), 'Available'),
            _buildLegendItem(const Color(0xFFF59E0B), 'Pending'),
            _buildLegendItem(const Color(0xFFEF4444), 'Reserved'),
            _buildLegendItem(const Color(0xFF6B7280), 'Disabled'),
            _buildLegendItem(const Color(0xFF9CA3AF), 'Time Passed'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoomHeader() {
    // Check if image is network image or local asset
    final bool isNetworkImage = _room.imageUrl.startsWith('http');
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isNetworkImage
                ? Image.network(
                    _room.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getRoomIcon(_room.category),
                          size: 60,
                          color: const Color(0xFF2C5473),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    _room.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getRoomIcon(_room.category),
                          size: 60,
                          color: const Color(0xFF2C5473),
                        ),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Room Name and Category
        Row(
          children: [
            Icon(
              _getRoomIcon(_room.category),
              size: 32,
              color: const Color(0xFF2C5473),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _room.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildDetailRow('Category', _room.category),
        _buildDetailRow('Location', _room.location),
        
        // Description Section
        if (_room.description.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _room.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        Row(
          children: [
            const Icon(
              Icons.schedule,
              color: Color(0xFF2C5473),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const Text(
                "Today's Time Slots",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3A),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRoomDetails,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoomIcon(String category) {
    switch (category) {
      case 'Study Room':
        return Icons.school;
      case 'Multimedia Room':
        return Icons.video_library;
      case 'Lecture Hall':
        return Icons.people;
      case 'Library':
        return Icons.library_books;
      case 'Conference Room':
        return Icons.business_center;
      default:
        return Icons.meeting_room;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Column(
        children: [
          // Header
          Container(
            height: 150,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.booking != null ? 'Booking Details' : 'Room Details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Header with Image and Details
                        _buildRoomHeader(),
                        
                        // Status Legend
                        _buildStatusLegend(),
                        const SizedBox(height: 16),
                        
                        // All Time Slots Section
                        const Text(
                          "All Time Slots:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E2A3A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Date: ${_formatDateWithWeekday(DateTime.now())}",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Time Slots List - ALWAYS SHOWS ALL 4 SLOTS
                        ..._timeSlots.map((slot) => _buildTimeSlotCard(slot)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateWithWeekday(DateTime date) {
    const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final weekdayIndex = date.weekday % 7;
    return "${weekdays[weekdayIndex]}, ${date.day}/${date.month}/${date.year}";
  }
}