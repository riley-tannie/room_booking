import 'package:flutter/material.dart';
import 'package:room_booking/staff/dashboard.dart';
import 'package:room_booking/staff/booking_history.dart';
import 'package:room_booking/staff/profile.dart';
import 'package:room_booking/staff/room_detail.dart';
import 'package:room_booking/staff/staff_management.dart';
import 'package:room_booking/data_store.dart';
import 'package:room_booking/api_service.dart';

class HomeStaff extends StatefulWidget {
  @override
  _HomeStaffState createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  int _currentIndex = 0;
  List<BookingRoom> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use getAllRooms to include disabled rooms
      final roomsData = await ApiService.getAllRooms();
      
      if (!mounted) return;
      
      final List<BookingRoom> detailedRooms = [];
      
      for (var roomData in roomsData) {
        try {
          final room = BookingRoom.fromJson(roomData);
          
          final timeSlotsData = await ApiService.getTodayTimeSlots(room.id);
          
          room.timeSlots = timeSlotsData.map((slotData) {
            final slot = TimeSlot.fromJson(slotData);
            if (_isTimePassed(slot.time)) {
              return TimeSlot(
                id: slot.id,
                time: slot.time,
                status: 'time_passed',
                displayStatus: 'Time Passed',
                color: const Color(0xFF9CA3AF),
                studentName: slot.studentName,
                studentId: slot.studentId,
                bookingId: slot.bookingId,
              );
            }
            return slot;
          }).toList();
          
          detailedRooms.add(room);
        } catch (e) {
          detailedRooms.add(BookingRoom.fromJson(roomData));
        }
      }
      
      setState(() {
        _rooms = detailedRooms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isTimePassed(String timeSlot) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    
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

  Map<String, List<BookingRoom>> _groupRoomsByCategory(List<BookingRoom> rooms) {
    final Map<String, List<BookingRoom>> groupedRooms = {};
    
    for (var room in rooms) {
      final category = room.category;
      groupedRooms.putIfAbsent(category, () => []).add(room);
    }
    return groupedRooms;
  }

  String _getRoomStatus(BookingRoom room) {
    if (room.isDisabled) return 'Disabled';
    
    final freeSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final pendingSlots = room.timeSlots.where((slot) => slot.status == 'pending').length;
    final reservedSlots = room.timeSlots.where((slot) => slot.status == 'reserved').length;
    final availableSlots = freeSlots + room.timeSlots.where((slot) => 
        slot.status == 'free' && !_isTimePassed(slot.time)).length;
    
    if (availableSlots > 0) return 'Available';
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
      case 'Disabled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getAvailabilityText(BookingRoom room) {
    if (room.isDisabled) return 'Room is disabled';
    
    final freeSlots = room.timeSlots.where((slot) => 
        slot.status == 'free' && !_isTimePassed(slot.time)).length;
    final pendingSlots = room.timeSlots.where((slot) => 
        slot.status == 'pending' && !_isTimePassed(slot.time)).length;
    final reservedSlots = room.timeSlots.where((slot) => 
        slot.status == 'reserved' && !_isTimePassed(slot.time)).length;
    final disabledSlots = room.timeSlots.where((slot) => slot.status == 'disabled').length;
    final timePassedSlots = room.timeSlots.where((slot) => _isTimePassed(slot.time)).length;
    
    final availableSlots = freeSlots + pendingSlots + reservedSlots;
    if (availableSlots == 0) return 'No available slots today';
    
    final parts = <String>[];
    if (freeSlots > 0) parts.add('$freeSlots free');
    if (pendingSlots > 0) parts.add('$pendingSlots pending');
    if (reservedSlots > 0) parts.add('$reservedSlots reserved');
    if (disabledSlots > 0) parts.add('$disabledSlots disabled');
    if (timePassedSlots > 0) parts.add('$timePassedSlots passed');
    
    return parts.join(', ');
  }

  int _getAvailableSlotCount(BookingRoom room) {
    if (room.isDisabled) return 0;
    return room.timeSlots.where((slot) => 
        slot.status == 'free' && !_isTimePassed(slot.time)).length;
  }

  @override
  Widget build(BuildContext context) {
    final groupedRooms = _groupRoomsByCategory(_rooms);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
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
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'All Rooms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedRooms.isEmpty
                    ? _buildEmptyState()
                    : _buildRoomList(groupedRooms),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2C5473),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(Icons.meeting_room, 'Rooms', 0),
            _buildNavItem(Icons.admin_panel_settings, 'Admin', 1),
            _buildNavItem(Icons.dashboard, 'Dashboard', 2),
            _buildNavItem(Icons.history, 'History', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => StaffManagementPage()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Dashboard()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BookingHistoryPage()),
                );
                break;
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
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
            'No Rooms Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'There are no rooms in the system',
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

  Widget _buildRoomList(Map<String, List<BookingRoom>> groupedRooms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          ...groupedRooms.keys.map((category) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  
                  ...groupedRooms[category]!.map((room) => _buildRoomCard(context, room)),
                  const SizedBox(height: 24),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, BookingRoom room) {
    final status = _getRoomStatus(room);
    final statusColor = _getStatusColor(status);
    final availabilityText = _getAvailabilityText(room);
    final availableSlotCount = _getAvailableSlotCount(room);

    final bool isNetworkImage = room.imageUrl.startsWith('http');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: room.isDisabled ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: room.isDisabled ? Border.all(color: Colors.red.withOpacity(0.3), width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: room.isDisabled ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomDetailPage(room: room),
              ),
            );
          },
          child: Opacity(
            opacity: room.isDisabled ? 0.7 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: room.isDisabled ? Colors.grey[300] : const Color(0xFFE8EDF1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isNetworkImage
                          ? Image.network(
                              room.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildRoomIcon(room.category, room.isDisabled);
                              },
                            )
                          : Image.asset(
                              room.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildRoomIcon(room.category, room.isDisabled);
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                room.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: room.isDisabled ? Colors.grey : Colors.black87,
                                ),
                              ),
                            ),
                            if (room.isDisabled)
                              const Icon(Icons.block, size: 16, color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: room.isDisabled ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          availabilityText,
                          style: TextStyle(
                            fontSize: 12,
                            color: room.isDisabled ? Colors.grey : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (availableSlotCount > 0 && !room.isDisabled) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$availableSlotCount slot${availableSlotCount > 1 ? 's' : ''} available for booking',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF26A65B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
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
                      Icon(
                        Icons.chevron_right,
                        color: room.isDisabled ? Colors.grey : Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomIcon(String category, bool isDisabled) {
    return Center(
      child: Icon(
        _getRoomIconData(category),
        size: 30,
        color: isDisabled ? Colors.grey : const Color(0xFF2C5473),
      ),
    );
  }

  IconData _getRoomIconData(String category) {
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
}