import 'package:flutter/material.dart';
import '../api_service.dart';
import '../data_store.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  String selectedTab = "All";
  String searchQuery = "";
  List<BookingRoom> availableRooms = [];
  bool isLoading = true;
  bool hasBookedToday = false;
  String? currentStudentId;
  String? currentStudentName;

  // Define the 4 required time slots
  final List<String> allTimeSlots = ['08:00-10:00', '10:00-12:00', '13:00-15:00', '15:00-17:00'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners here if needed
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() {
        isLoading = true;
      });

      currentStudentId = await ApiService.getCurrentStudentId();
      final user = await ApiService.getCurrentUser();
      currentStudentName = user?['fullName'] ?? 'Student';
      
      if (currentStudentId != null) {
        // Check if student has booked today
        hasBookedToday = await _checkIfStudentHasBookedToday(currentStudentId!);
        
        // Load available rooms
        final roomsData = await ApiService.getAvailableRooms();
        
        if (!mounted) return;
        
        availableRooms.clear();
        
        for (var roomData in roomsData) {
          try {
            final room = BookingRoom.fromJson(roomData);
            final timeSlotsData = await ApiService.getRoomTimeSlots(room.id);
            
            // Create time slots with proper status handling
            room.timeSlots = _createTimeSlotsWithStatus(timeSlotsData);
            
            availableRooms.add(room);
          } catch (e) {
            print('Error loading room ${roomData['name']}: $e');
            continue;
          }
        }
      }
      
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      
    } catch (e) {
      print('Error loading data: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load rooms: $e');
    }
  }

  Future<bool> _checkIfStudentHasBookedToday(String studentId) async {
    try {
      final todayRequests = await _loadStudentRequests();
      return todayRequests.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserBooking>> _loadStudentRequests() async {
    final studentId = await ApiService.getCurrentStudentId();
    if (studentId == null) return [];

    try {
      final requestsData = await ApiService.getStudentRequests(studentId);
      return requestsData.map((request) => UserBooking.fromJson(request)).toList();
    } catch (e) {
      return [];
    }
  }

  List<TimeSlot> _createTimeSlotsWithStatus(List<dynamic> timeSlotsData) {
    final List<TimeSlot> timeSlots = [];
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    // Define time slots with their start times in minutes
    final timeSlotConfig = [
      {'time': '08:00-10:00', 'start': 8 * 60},
      {'time': '10:00-12:00', 'start': 10 * 60},
      {'time': '13:00-15:00', 'start': 13 * 60},
      {'time': '15:00-17:00', 'start': 15 * 60},
    ];

    for (var slotConfig in timeSlotConfig) {
      final slotTime = slotConfig['time'] as String;
      final slotStart = slotConfig['start'] as int;
      
      // Find matching slot from API data
      final slotData = timeSlotsData.firstWhere(
        (s) => s['time_slot'] == slotTime,
        orElse: () => null,
      );
      
      String status = 'free';
      String displayStatus = 'Available';
      Color color = const Color(0xFF26A65B);

      // Check if time slot has passed first
      if (currentTime >= slotStart) {
        status = 'disabled';
        displayStatus = 'Time Passed';
        color = const Color(0xFF6B7280);
      } 
      // If we have slot data, use its status
      else if (slotData != null) {
        status = slotData['status'] ?? 'free';
        
        switch (status) {
          case 'pending':
            displayStatus = 'Pending';
            color = const Color(0xFFF59E0B);
            break;
          case 'reserved':
            displayStatus = 'Reserved';
            color = const Color(0xFFEF4444);
            break;
          case 'disabled':
            displayStatus = 'Disabled';
            color = const Color(0xFF6B7280);
            break;
          case 'free':
          default:
            displayStatus = 'Available';
            color = const Color(0xFF26A65B);
            break;
        }
      }

      timeSlots.add(TimeSlot(
        id: slotData?['id']?.toString() ?? slotTime,
        time: slotTime,
        status: status,
        displayStatus: displayStatus,
        color: color,
      ));
    }

    return timeSlots;
  }

  void _showErrorDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5473)),
        ),
      );
    }

    final filteredRooms = availableRooms.where((room) {
      bool matchesTab;
      if (selectedTab == "All") {
        matchesTab = true;
      } else {
        // Exact category matching based on your database
        matchesTab = room.category == selectedTab;
      }
      
      final matchesSearch = room.name.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesTab && matchesSearch;
    }).toList();

    final Map<String, List<BookingRoom>> groupedRooms = {};
    if (selectedTab == "All") {
      for (var room in filteredRooms) {
        final category = room.category;
        if (!groupedRooms.containsKey(category)) {
          groupedRooms[category] = [];
        }
        groupedRooms[category]!.add(room);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi ${currentStudentName ?? 'Student'},",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Available Rooms for Today",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2C5473)),
                const SizedBox(width: 8),
                Text(
                  _formatDateWithWeekday(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C5473),
                  ),
                ),
              ],
            ),
          ),

          if (hasBookedToday)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFC107)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have already booked a room for today. Only one booking per day is allowed.',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search rooms...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5473),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF1),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab("All"),
                _buildTab("Study Room"),
                _buildTab("Multimedia Room"),
                _buildTab("Lecture Hall"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (filteredRooms.isEmpty)
            _buildEmptyState()
          else if (selectedTab == "All" && groupedRooms.isNotEmpty)
            _buildGroupedRooms(groupedRooms)
          else
            _buildFilteredRooms(filteredRooms),
        ],
      ),
    );
  }

  Widget _buildGroupedRooms(Map<String, List<BookingRoom>> groupedRooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedRooms.keys.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 12),
                ...groupedRooms[category]!.map((room) => _buildRoomCard(room)),
                const SizedBox(height: 24),
              ],
            )),
      ],
    );
  }

  Widget _buildFilteredRooms(List<BookingRoom> filteredRooms) {
    return Column(
      children: [
        ...filteredRooms.map((room) => _buildRoomCard(room)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No Rooms Available Today",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "All rooms are currently booked or no available time slots for today",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5473),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C5473) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BookingRoom room) {
    final availableSlots = room.timeSlots.where((slot) => 
        slot.status == 'free' && slot.displayStatus == 'Available').length;
    
    // Check if user has booked today OR if room has no available slots
    final canBook = !hasBookedToday && availableSlots > 0 && !room.isDisabled;

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
                    color: const Color(0xFFE8EDF1),
                    child: const Icon(
                      Icons.meeting_room,
                      color: Color(0xFF2C5473),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasBookedToday 
                      ? 'Booking submitted - Pending approval'
                      : '$availableSlots of ${allTimeSlots.length} time slots available',
                    style: TextStyle(
                      color: hasBookedToday ? Colors.orange : (canBook ? Colors.green : Colors.red),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Updated booking button with disabled state
            if (hasBookedToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: canBook ? () => _showTimeSlotSelection(context, room) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBook ? const Color(0xFF2C5473) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  availableSlots > 0 ? 'Book Now' : 'Full',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTimeSlotSelection(BuildContext context, BookingRoom room) {
    // Show ALL time slots, not just available ones
    final allSlots = room.timeSlots;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2C5473),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All Time Slots - ${room.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      room.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: const Color(0xFFE8EDF1),
                          child: const Icon(
                            Icons.meeting_room,
                            color: Color(0xFF2C5473),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2C5473)),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateWithWeekday(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C5473)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "All Time Slots:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Date: ${_formatDateWithWeekday(DateTime.now())}",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Status Legend
                    _buildStatusLegend(),
                    const SizedBox(height: 16),
                    
                    if (allSlots.isEmpty)
                      _buildNoSlotsAvailable()
                    else
                      Expanded(
                        child: ListView(
                          children: allSlots
                              .map((slot) => _buildTimeSlotCard(slot, context, room))
                              .toList(),
                        ),
                      ),
                  ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(const Color(0xFF26A65B), 'Available'),
          _buildLegendItem(const Color(0xFFF59E0B), 'Pending'),
          _buildLegendItem(const Color(0xFFEF4444), 'Reserved'),
          _buildLegendItem(const Color(0xFF6B7280), 'Disabled'),
        ],
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

  Widget _buildNoSlotsAvailable() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            "No time slots available",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            "All time slots are either booked, pending, or have passed for today",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, BuildContext context, BookingRoom room) {
    // Only allow booking if slot is free AND user hasn't booked today
    final canBook = slot.status == 'free' && !hasBookedToday;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: slot.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getStatusIcon(slot.status), color: slot.color),
        ),
        title: Text(
          slot.time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: canBook ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(
          slot.displayStatus,
          style: TextStyle(
            color: slot.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: canBook 
            ? ElevatedButton(
                onPressed: () => _bookTimeSlot(context, slot, room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5473),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: slot.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: slot.color),
                ),
                child: Text(
                  slot.displayStatus,
                  style: TextStyle(
                    color: slot.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending_actions;
      case 'reserved':
        return Icons.event_available;
      case 'disabled':
        return Icons.block;
      default:
        return Icons.access_time;
    }
  }

  void _bookTimeSlot(BuildContext context, TimeSlot slot, BookingRoom room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${room.name}'),
            Text('Time: ${slot.time}'),
            Text('Date: ${_formatDateWithWeekday(DateTime.now())}'),
            const SizedBox(height: 8),
            const Text(
              'Note: Booking will be pending approval from lecturer',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _confirmBooking(context, slot, room);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5473),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context, TimeSlot slot, BookingRoom room) async {
    try {
      final studentId = await ApiService.getCurrentStudentId();
      if (studentId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Attempting to book: Student=$studentId, Room=${room.id}, Time=${slot.time}');

      // Final validation - ensure slot is still available
      if (slot.status != 'free') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This time slot is no longer available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create the booking
      final result = await ApiService.createBooking(
        studentId: studentId,
        roomId: room.id,
        timeSlot: slot.time,
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Close confirmation dialog
      Navigator.pop(context); // Close time slot selection

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked ${room.name} for ${slot.time}. Status: Pending Approval'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      if (!mounted) return;
      setState(() {
        hasBookedToday = true;
      });
      await _loadData();

    } catch (e) {
      print('Booking error details: $e');
      if (!mounted) return;
      
      String errorMessage = 'Booking failed';
      if (e.toString().contains('already booked')) {
        errorMessage = 'You have already booked a room for today';
        setState(() {
          hasBookedToday = true;
        });
      } else if (e.toString().contains('no longer available')) {
        errorMessage = 'This time slot was just taken. Please try another slot.';
        await _loadData(); // Refresh data to show current availability
      } else if (e.toString().contains('Database error')) {
        errorMessage = 'Server error. Please try again.';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  String _formatDateWithWeekday(DateTime date) {
    const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return "${weekdays[date.weekday]}, ${date.day}/${date.month}/${date.year}";
  }
}