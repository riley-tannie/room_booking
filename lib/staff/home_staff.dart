import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'booking_history.dart';
import 'profile.dart';
import 'room_detail.dart';
import 'edit.dart';
import 'data_store.dart';

class HomeStaff extends StatefulWidget {
  @override
  _HomeStaffState createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  int _currentIndex = 0; // Room List is first

  @override
  Widget build(BuildContext context) {
    // Get available rooms (not disabled)
    final availableRooms = StaffDataStore.availableRooms.where((room) => !room.isDisabled).toList();
    
    // Group rooms by category
    final multimediaRooms = availableRooms.where((room) => room.category == 'Multimedia Room').toList();
    final libraryRooms = availableRooms.where((room) => room.category == 'Library').toList();
    final studyRooms = availableRooms.where((room) => room.category == 'Study Room').toList();
    final lectureHalls = availableRooms.where((room) => room.category == 'Lecture Hall').toList();
    final conferenceRooms = availableRooms.where((room) => room.category == 'Conference Room').toList();

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
                      'Available Rooms',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (multimediaRooms.isNotEmpty)
                    _buildRoomSection('Multimedia Room', multimediaRooms),
                  
                  if (libraryRooms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRoomSection('Library', libraryRooms),
                  ],
                  
                  if (studyRooms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRoomSection('Study Room', studyRooms),
                  ],
                  
                  if (lectureHalls.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRoomSection('Lecture Hall', lectureHalls),
                  ],
                  
                  if (conferenceRooms.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRoomSection('Conference Room', conferenceRooms),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildReservedSection(),
                ],
              ),
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
                // Already on home page
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => EditRoomTypesPage()),
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

  Widget _buildRoomSection(String title, List<BookingRoom> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A3A),
          ),
        ),
        const SizedBox(height: 12),
        ...rooms.map((room) => _buildRoomCard(room)),
      ],
    );
  }

  Widget _buildReservedSection() {
    // Get rooms with reserved/pending slots
    final reservedRooms = StaffDataStore.availableRooms.where((room) {
      return room.timeSlots.any((slot) => slot.status == 'reserved' || slot.status == 'pending');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reserved & Pending Rooms',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        ...reservedRooms.map((room) => _buildReservedRoomCard(room)),
      ],
    );
  }

  Widget _buildRoomCard(BookingRoom room) {
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
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                room.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.photo,
                      color: Colors.grey,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRoomStatus(room),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5473),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)),
                );
              },
              child: const Text(
                'See details',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservedRoomCard(BookingRoom room) {
    final reservedSlots = room.timeSlots.where((slot) => slot.status == 'reserved' || slot.status == 'pending').toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
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
            // Room Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                room.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.photo,
                      color: Colors.grey,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reservedSlots.length} slot(s) ${reservedSlots.any((slot) => slot.status == 'reserved') ? 'Reserved' : 'Pending'}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)),
                );
              },
              child: const Text(
                'See details',
                style: TextStyle(
                  color: Color(0xFF2C5473),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomStatus(BookingRoom room) {
    final freeSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final totalSlots = room.timeSlots.length;
    
    return Text(
      '$freeSlots/$totalSlots slots available',
      style: TextStyle(
        color: freeSlots > 0 ? Colors.green : Colors.red,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}