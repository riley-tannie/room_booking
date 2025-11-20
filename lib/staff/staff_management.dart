import 'package:flutter/material.dart';
import '../api_service.dart';
import '../data_store.dart';
import 'home_staff.dart';
import 'booking_history.dart';
import 'profile.dart';
import 'dashboard.dart';
import 'room_edit.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  _StaffManagementPageState createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<BookingRoom> _rooms = [];
  bool _isLoading = true;
  int _currentIndex = 1;

  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomLocationController = TextEditingController();
  final TextEditingController _roomDescriptionController =
      TextEditingController();
  String _selectedCategory = 'Study Room';

  final List<String> _categories = [
    'Study Room',
    'Multimedia Room',
    'Lecture Hall',
    'Library',
    'Conference Room',
  ];
  
  // Function to check if the time slot has already passed
  bool _isTimePassed(String timeSlot) {
    final now = DateTime.now();
    // แปลงเวลาปัจจุบันเป็นนาทีเพื่อเปรียบเทียบ
    final currentTime = now.hour * 60 + now.minute; 
    
    try {
      // Parse เวลาสิ้นสุดจาก Time Slot string (เช่น "08:00-10:00" -> 10:00)
      final timeParts = timeSlot.split('-');
      if (timeParts.length < 2) return false;

      final endTimeStr = timeParts[1];
      final endHourMinute = endTimeStr.split(':');
      if (endHourMinute.length < 2) return false;
      
      final endHours = int.parse(endHourMinute[0]);
      final endMinutes = int.parse(endHourMinute[1]);
      final slotEndTime = endHours * 60 + endMinutes;
      
      // ตรวจสอบ: เวลาปัจจุบัน >= เวลาสิ้นสุดของสล็อต
      return currentTime >= slotEndTime;
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการแปลงเวลา ให้ถือว่ายังไม่ผ่าน
      return false; 
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomLocationController.dispose();
    _roomDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      // Single API call to get all rooms with their slots data
      final roomsData = await ApiService.getAvailableRooms();

      if (!mounted) return;

      setState(() {
        _rooms = roomsData
            .map((roomData) => BookingRoom.fromJson(roomData))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createRoom() async {
    if (_roomNameController.text.isEmpty ||
        _roomLocationController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in room name and location')),
      );
      return;
    }

    try {
      await ApiService.createRoom(
        name: _roomNameController.text,
        category: _selectedCategory,
        location: _roomLocationController.text,
        description: _roomDescriptionController.text,
        isDisabled: true, // New rooms are disabled by default
      );

      _roomNameController.clear();
      _roomLocationController.clear();
      _roomDescriptionController.clear();

      await _loadRooms();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create room: $e')));
    }
  }

  /*Future<void> _disableRoom(BookingRoom room) async {
    final freeSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final totalSlots = room.timeSlots.length;

    if (freeSlots != totalSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot disable room with booked or pending slots')),
      );
      return;
    }

    try {
      await ApiService.disableRoom(room.id);
      await _loadRooms();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room disabled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disable room: $e')),
      );
    }
  }*/
  //new version of disable room
  Future<void> _disableRoom(BookingRoom room) async {
    //count available 'free' slots that are not past time
    final availableFreeSlots = room.timeSlots
        .where((slot) => slot.status == 'free' && !_isTimePassed(slot.time))
        .length;

    //count slots that are 'pending' or 'reserved'
    final nonFreeOrDisabledSlots = room.timeSlots
        .where((slot) => slot.status == 'pending' || slot.status == 'reserved')
        .length;

    //check if there are any non-free slots
    if (nonFreeOrDisabledSlots > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot disable room with active bookings (Pending or Reserved).',
          ),
        ),
      );
      return;
    }

    // If there are no pending reservations, you can call the API to close the room.
    try {
      await ApiService.disableRoom(room.id);
      await _loadRooms();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room disabled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to disable room: $e')));
    }
  }

  Future<void> _enableRoom(BookingRoom room) async {
    try {
      await ApiService.enableRoom(room.id);
      await _loadRooms();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room enabled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to enable room: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // Header
          Container(
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
            ),
            child: const SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Room Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.only(top: 130, left: 20, right: 20),
            child: Column(
              children: [
                // Tab Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTab('Room List', 0),
                      _buildTab('Add Room', 1),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Content Area
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildCurrentTabContent(),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeStaff()),
                );
                break;
              case 1:
                // Current page
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

  int _selectedTab = 0;

  Widget _buildTab(String title, int index) {
    final bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2C5473) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF2C5473),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    if (_selectedTab == 0) {
      return _buildRoomList();
    } else {
      return _buildAddRoomForm();
    }
  }

  Widget _buildRoomList() {
    return _rooms.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No rooms available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadRooms,
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return _buildRoomCard(room);
              },
            ),
          );
  }

  Widget _buildRoomCard(BookingRoom room) {
    final freeSlots = room.timeSlots
        .where((slot) => slot.status == 'free')
        .length;
    final totalSlots = room.timeSlots.length;

    final bool canDisableRoom = freeSlots == totalSlots && !room.isDisabled;
    final bool canEnableRoom = room.isDisabled;

    // Check if image is network image or local asset
    final bool isNetworkImage = room.imageUrl.startsWith('http');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image/Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isNetworkImage
                    ? Image.network(
                        room.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildRoomIcon(room.category);
                        },
                      )
                    : Image.asset(
                        room.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildRoomIcon(room.category);
                        },
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Room Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (room.isDisabled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'DISABLED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Availability Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: freeSlots > 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: freeSlots > 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Text(
                      freeSlots > 0
                          ? '$freeSlots/$totalSlots slots available'
                          : 'No available slots',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: freeSlots > 0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                // Edit Button
                if (room.isDisabled)...{  // Only allow editing if room is disabled
                  SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomEditPage(room: room),
                            ),
                          ).then((_) => _loadRooms());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5473),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  } else ...{
                    SizedBox(
                      width: 80,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  },
                const SizedBox(height: 8),

                // Enable/Disable Button
                if (canDisableRoom)
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () => _disableRoom(room),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Disable',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                else if (canEnableRoom)
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: () => _enableRoom(room),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Enable',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Locked',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomIcon(String category) {
    return Center(
      child: Icon(
        _getRoomIcon(category),
        size: 24,
        color: const Color(0xFF2C5473),
      ),
    );
  }

  Widget _buildAddRoomForm() {
    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Room',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fill in the details to create a new room',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(_getRoomIcon(category), size: 20),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _roomLocationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _roomDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5473),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create Room',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
