import 'package:flutter/material.dart';
import '../api_service.dart';
import 'room_detail_lecturer.dart';

class RoomListPageLecturer extends StatefulWidget {
  const RoomListPageLecturer({super.key});

  @override
  State<RoomListPageLecturer> createState() => _RoomListPageLecturerState();
}

class _RoomListPageLecturerState extends State<RoomListPageLecturer> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final roomsData = await ApiService.getTodayRooms();
      setState(() {
        rooms = roomsData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading rooms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, List<dynamic>> _groupRoomsByCategory(List<dynamic> rooms) {
    final Map<String, List<dynamic>> groupedRooms = {};
    
    // Filter out invalid rooms first
    final validRooms = rooms.where((room) {
      final name = room['name']?.toString() ?? '';
      final category = room['category']?.toString() ?? '';
      return name.isNotEmpty && 
             name != 'Unknown' && 
             name != 'null' && 
             category.isNotEmpty;
    }).toList();
    
    for (var room in validRooms) {
      final category = room['category'] ?? 'General';
      groupedRooms.putIfAbsent(category, () => []).add(room);
    }
    return groupedRooms;
  }

  String _getRoomStatus(int freeSlots, int pendingSlots, int reservedSlots) {
    if (freeSlots > 0) return 'Available';
    if (pendingSlots > 0) return 'Pending Approval';
    if (reservedSlots > 0) return 'Reserved';
    return 'No Slots';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF26A65B);
      case 'Pending Approval':
        return const Color(0xFFF59E0B);
      case 'Reserved':
        return const Color(0xFF428BCA);
      case 'No Slots':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getAvailabilityText(int freeSlots, int pendingSlots, int reservedSlots) {
    final totalSlots = freeSlots + pendingSlots + reservedSlots;
    if (totalSlots == 0) return 'No slots today';
    
    final parts = <String>[];
    if (freeSlots > 0) parts.add('$freeSlots free');
    if (pendingSlots > 0) parts.add('$pendingSlots pending');
    if (reservedSlots > 0) parts.add('$reservedSlots reserved');
    
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final groupedRooms = _groupRoomsByCategory(rooms);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Available Rooms",
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
          else if (groupedRooms.isEmpty)
            _buildEmptyState()
          else
            ...groupedRooms.keys.map((category) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2A3A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Room Cards
                    ...groupedRooms[category]!.map((room) => _buildRoomCard(context, room)),
                    const SizedBox(height: 24),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2C5473),
          ),
          SizedBox(height: 16),
          Text(
            'Loading today\'s rooms...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
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
            Icons.meeting_room_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Rooms Available Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'All rooms might be disabled or fully booked',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadRooms,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5473),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refresh Rooms'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Map<String, dynamic> room) {
    final freeSlots = room['free_slots'] ?? 0;
    final pendingSlots = room['pending_slots'] ?? 0;
    final reservedSlots = room['reserved_slots'] ?? 0;
    final status = _getRoomStatus(freeSlots, pendingSlots, reservedSlots);
    final statusColor = _getStatusColor(status);
    final availabilityText = _getAvailabilityText(freeSlots, pendingSlots, reservedSlots);

    final imageUrl = room['image_url'] ?? 'assets/images/default_room.jpg';
    final bool isNetworkImage = imageUrl.startsWith('http');

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomDetailLecturer(room: room),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Room Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFE8EDF1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isNetworkImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildRoomIcon(room['category']);
                            },
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildRoomIcon(room['category']);
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Room Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name'] ?? 'Unnamed Room',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room['location'] ?? 'No location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        availabilityText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomIcon(String? category) {
    return Center(
      child: Icon(
        _getRoomIconData(category),
        size: 30,
        color: const Color(0xFF2C5473),
      ),
    );
  }

  IconData _getRoomIconData(String? category) {
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

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}