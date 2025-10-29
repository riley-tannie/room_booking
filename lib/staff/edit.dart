import 'package:flutter/material.dart';
import 'editing_detail.dart';
import 'home_staff.dart';
import '../staff/booking_history.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'data_store.dart';

class EditRoomTypesPage extends StatefulWidget {
  @override
  _EditRoomTypesPageState createState() => _EditRoomTypesPageState();
}

class _EditRoomTypesPageState extends State<EditRoomTypesPage> {
  int _selectedTab = 0;
  int _currentIndex = 1;

  // Form controllers for Add tab
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomLocationController = TextEditingController();
  final TextEditingController _roomDescriptionController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomLocationController.dispose();
    _roomDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- Header ----------
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
                      'Editing Room Types',
                      style: TextStyle(
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomeStaff()),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
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

          // ---------- Body ----------
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(child: _buildCurrentTab()),
              ],
            ),
          ),
        ],
      ),

      // ---------- Floating Bottom Navigation ----------
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
                // Already on admin page
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

  // ---------- Tabs ----------
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTab('Add', 0),
          _buildTab('Edit', 1),
          _buildTab('Disable', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2C5473) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Tabs Content ----------
  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return _buildAddTab();
      case 1:
        return _buildEditTab();
      case 2:
        return _buildDisableTab();
      default:
        return _buildAddTab();
    }
  }

  // ---------- Add Tab ----------
  Widget _buildAddTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCardContainer(
            title: 'Add your image of room',
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.55,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCardContainer(
            title: 'Adding detail',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(_roomNameController, 'Room Name', 'Type your room name'),
                _buildTextField(_roomLocationController, 'Location', 'Type your location'),
                _buildTextField(_roomDescriptionController, 'Description', 'Type room description'),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5473),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _addNewRoom,
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Edit / Disable ----------
  Widget _buildEditTab() {
    final editableRooms = StaffDataStore.availableRooms.where((room) => !room.isDisabled).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: editableRooms
            .map((room) => _buildEditableRoomCard(room))
            .toList(),
      ),
    );
  }

  Widget _buildDisableTab() {
    final disableRooms = StaffDataStore.availableRooms.where((room) => !room.isDisabled).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: disableRooms
            .map((room) => _buildDisableRoomCard(room))
            .toList(),
      ),
    );
  }

  // ---------- Components ----------
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7FBF7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildEditableRoomCard(BookingRoom room) {
    return _buildRoomCard(room, true);
  }

  Widget _buildDisableRoomCard(BookingRoom room) {
    return _buildRoomCard(room, false);
  }

  Widget _buildRoomCard(BookingRoom room, bool editable) {
    // Count statuses
    final freeSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final pendingSlots = room.timeSlots.where((slot) => slot.status == 'pending').length;
    final reservedSlots = room.timeSlots.where((slot) => slot.status == 'reserved').length;
    final disabledSlots = room.timeSlots.where((slot) => slot.status == 'disabled').length;
    
    String statusText = '';
    if (freeSlots == room.timeSlots.length) {
      statusText = 'Available';
    } else if (pendingSlots > 0) {
      statusText = 'Pending';
    } else if (reservedSlots > 0) {
      statusText = 'Reserved';
    } else if (disabledSlots == room.timeSlots.length) {
      statusText = 'Disabled';
    } else {
      statusText = 'Mixed';
    }

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    room.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.photo,
                          color: Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: _getStatusColor(statusText),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room.location,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Slot status summary
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 72), // Align with text content
              child: Text(
                'Free: $freeSlots, Pending: $pendingSlots, Reserved: $reservedSlots, Disabled: $disabledSlots',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ),
            
            // Action button
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: editable
                  ? TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditingDetailPage(room: room)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEAF1FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit details',
                        style: TextStyle(
                          color: Color(0xFF204C72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _disableRoom(room);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF6666),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Disable Room',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'reserved':
        return Colors.blue;
      case 'disabled':
        return Colors.red;
      case 'mixed':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  void _addNewRoom() {
    if (_roomNameController.text.isEmpty || _roomLocationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in room name and location')),
      );
      return;
    }

    final newRoom = BookingRoom(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      name: _roomNameController.text,
      category: 'Study Room', // Default category
      location: _roomLocationController.text,
      imageUrl: 'assets/images/study_room1.jpg', // Default image
      description: _roomDescriptionController.text.isEmpty 
          ? 'Newly added room' 
          : _roomDescriptionController.text,
      timeSlots: _createDefaultTimeSlots(),
    );

    StaffDataStore.addRoom(newRoom);
    
    // Clear form
    _roomNameController.clear();
    _roomLocationController.clear();
    _roomDescriptionController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room added successfully')),
    );
  }

  void _disableRoom(BookingRoom room) {
    final success = StaffDataStore.disableRoom(room.id);
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room disabled successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot disable room with booked/pending slots')),
      );
    }
  }

  List<TimeSlot> _createDefaultTimeSlots() {
    return [
      TimeSlot(time: '8-10', status: 'free', startHour: 8, endHour: 10),
      TimeSlot(time: '10-12', status: 'free', startHour: 10, endHour: 12),
      TimeSlot(time: '13-15', status: 'free', startHour: 13, endHour: 15),
      TimeSlot(time: '15-17', status: 'free', startHour: 15, endHour: 17),
    ];
  }
}