import 'package:flutter/material.dart';
import '../data_store.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  String selectedTab = "All";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // กรองห้องที่ไม่ต้องการ
    final filteredRooms = BookingDataStore.availableRooms
        .where((room) =>
            room.name != "Conference Room A" &&
            room.name != "Collaborative Space 1")
        .where((room) {
      final matchesTab = selectedTab == "All" || room.category == selectedTab;
      final matchesSearch =
          room.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    // จัดกลุ่มห้องตามประเภทสำหรับแท็บ All
    final Map<String, List<BookingRoom>> groupedRooms = {};
    if (selectedTab == "All") {
      for (var room in BookingDataStore.availableRooms) {
        if (room.name == "Conference Room A" ||
            room.name == "Collaborative Space 1") continue;
        if (room.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          groupedRooms.putIfAbsent(room.category, () => []).add(room);
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hi Riley, you're at",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          // 🗓 วันที่สวย
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 16),
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

          // Search + Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Looking for room",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF1),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTab("All"),
                _buildTab("Multimedia Room"),
                _buildTab("Study Room"),
                _buildTab("Lecture Hall"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // แสดงห้อง
          selectedTab == "All"
              ? _buildGroupedRooms(groupedRooms)
              : _buildFilteredRooms(filteredRooms),
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
    final availableSlots =
        room.timeSlots.where((slot) => slot.status == 'free').length;
    final pendingSlots =
        room.timeSlots.where((slot) => slot.status == 'pending').length;
    final reservedSlots =
        room.timeSlots.where((slot) => slot.status == 'reserved').length;
    final disabledSlots =
        room.timeSlots.where((slot) => slot.status == 'disabled').length;

    final canBook = availableSlots > 0 && !room.isDisabled;

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
                      Icons.photo,
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
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.black54),
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
                    '$availableSlots available, $pendingSlots pending, $reservedSlots reserved${disabledSlots > 0 ? ', $disabledSlots disabled' : ''}',
                    style: TextStyle(
                      color: canBook ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed:
                  canBook ? () => _showTimeSlotSelection(context, room) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canBook ? const Color(0xFF2C5473) : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
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
                      'Time Slots - ${room.name}',
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

            // Room Info + วันที่
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Color(0xFF2C5473)),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateWithWeekday(DateTime.now()),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C5473)),
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
                child: allSlots.isEmpty
                    ? _buildNoSlotsAvailable()
                    : ListView(
                        children: allSlots
                            .map((slot) =>
                                _buildTimeSlotCard(slot, context, room))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
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
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(
      TimeSlot slot, BuildContext context, BookingRoom room) {
    final isAvailable =
        slot.status == 'free' && BookingDataStore.isTimeSlotAvailable(slot);

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: slot.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getStatusIcon(slot.status), color: slot.color),
        ),
        title: Text(slot.time,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
        trailing: isAvailable
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
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              )
            : Text(
                slot.displayStatus,
                style: TextStyle(
                    color: slot.color, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  String _formatDateWithWeekday(DateTime date) {
    const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return "${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}";
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'free':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'reserved':
        return Icons.event_available;
      case 'disabled':
        return Icons.block;
      default:
        return Icons.help;
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
              'Note: Booking will be pending approval',
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

  void _confirmBooking(BuildContext context, TimeSlot slot, BookingRoom room) {
    final booking = UserBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      roomName: room.name,
      roomId: room.id,
      date: DateTime.now(),
      timeSlot: slot.time,
      studentName: BookingDataStore.currentStudentName,
      studentId: BookingDataStore.currentStudentId,
      status: 'Pending',
      bookedAt: DateTime.now(),
    );

    BookingDataStore.addBooking(booking);
    Navigator.pop(context);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully booked ${room.name} for ${slot.time}. Status: Pending'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {});
  }
}
