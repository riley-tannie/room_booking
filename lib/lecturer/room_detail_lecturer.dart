import 'package:flutter/material.dart';
import '../api_service.dart';

class RoomDetailLecturer extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailLecturer({super.key, required this.room});

  @override
  State<RoomDetailLecturer> createState() => _RoomDetailLecturerState();
}

class _RoomDetailLecturerState extends State<RoomDetailLecturer> {
  List<dynamic> timeSlots = [];
  bool isLoading = true;
  Map<String, dynamic>? roomDetails;

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    try {
      final roomId = widget.room['id'];
      final response = await ApiService.getTodayTimeSlots(roomId);
      
      setState(() {
        timeSlots = response;
        roomDetails = widget.room;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading room details: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load room details: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return 'Available';
      case 'pending':
        return 'Pending Approval';
      case 'reserved':
        return 'Reserved';
      case 'disabled':
        return 'Disabled';
      default:
        return 'Unknown';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'reserved':
        return Icons.event_busy;
      case 'disabled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    final status = slot['status']?.toString() ?? 'free';
    final timeSlot = slot['time_slot']?.toString() ?? '';
    final studentName = slot['student_name']?.toString() ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 20,
          ),
        ),
        title: Text(
          timeSlot,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: studentName.isNotEmpty 
            ? Text(
                'Booked by: $studentName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomHeader() {
    final imageUrl = roomDetails?['image_url'] ?? 'assets/images/default_room.jpg';
    final bool isNetworkImage = imageUrl.startsWith('http');

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
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getRoomIcon(roomDetails?['category']),
                          size: 60,
                          color: const Color(0xFF2C5473),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          _getRoomIcon(roomDetails?['category']),
                          size: 60,
                          color: const Color(0xFF2C5473),
                        ),
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Icon(
              _getRoomIcon(roomDetails?['category']),
              size: 32,
              color: const Color(0xFF2C5473),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                roomDetails?['name'] ?? 'Unnamed Room',
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
        
        _buildDetailRow('Category', roomDetails?['category'] ?? 'General'),
        _buildDetailRow('Location', roomDetails?['location'] ?? 'No location'),
        
        if (roomDetails?['description'] != null) ...[
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
            roomDetails?['description'] ?? '',
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
            const Text(
              "Today's Time Slots",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
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

  IconData _getRoomIcon(String? category) {
    switch (category) {
      case 'Study Room':
        return Icons.school;
      case 'Multimedia Room':
        return Icons.video_library;
      case 'Lecture Hall':
        return Icons.people;
      default:
        return Icons.meeting_room;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      appBar: AppBar(
        title: const Text('Room Details'),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF2C5473),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading room details...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoomHeader(),
                  
                  if (timeSlots.isEmpty)
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No time slots available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...timeSlots.map((slot) => _buildTimeSlotCard(slot)),
                ],
              ),
            ),
    );
  }
}