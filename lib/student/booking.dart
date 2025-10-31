import 'package:flutter/material.dart';
import '../data_store.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String selectedTab = "Available";

  final List<String> tabs = [
    "Available",
    "Pending", // Separate Pending tab
    "Reserved", // Separate Reserved tab
    "Disabled",
  ];

  @override
  void initState() {
    super.initState();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    // Filter rooms based on selected tab
    final filteredRooms = _getFilteredRooms();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Request Booking",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A3A),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EDF1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: tabs.map((tab) {
                return _buildTab(tab);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Room List
          if (filteredRooms.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: filteredRooms.map((room) {
                return _buildRoomCard(context, room);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            _getEmptyStateIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateText(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (selectedTab) {
      case "Available":
        return Icons.meeting_room_outlined;
      case "Pending":
        return Icons.pending_actions;
      case "Reserved":
        return Icons.event_available;
      case "Disabled":
        return Icons.block;
      default:
        return Icons.search_off;
    }
  }

  String _getEmptyStateText() {
    switch (selectedTab) {
      case "Available":
        return "No available rooms at the moment";
      case "Pending":
        return "No pending rooms";
      case "Reserved":
        return "No reserved rooms";
      case "Disabled":
        return "No disabled rooms";
      default:
        return "No rooms found";
    }
  }

  List<BookingRoom> _getFilteredRooms() {
    switch (selectedTab) {
      case "Available":
        return BookingDataStore.availableRooms.where((room) {
          if (room.isDisabled) return false;
          final hasAvailableSlots = room.timeSlots.any((slot) => 
              slot.status == 'free');
          return hasAvailableSlots; // REMOVED: && BookingDataStore.canStudentBookToday()
        }).toList();
      
      case "Pending":
        // Show rooms that have pending slots
        return BookingDataStore.availableRooms.where((room) {
          if (room.isDisabled) return false;
          final hasPendingSlots = room.timeSlots.any((slot) => 
              slot.status == 'pending');
          return hasPendingSlots;
        }).toList();
      
      case "Reserved":
        // Show rooms that have reserved slots
        return BookingDataStore.availableRooms.where((room) {
          if (room.isDisabled) return false;
          final hasReservedSlots = room.timeSlots.any((slot) => 
              slot.status == 'reserved');
          return hasReservedSlots;
        }).toList();
      
      case "Disabled":
        return BookingDataStore.availableRooms.where((room) => room.isDisabled).toList();
      
      default:
        return BookingDataStore.availableRooms;
    }
  }

  Widget _buildTab(String title) {
    final bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, BookingRoom room) {
    final availableSlots = room.timeSlots.where((slot) => 
        slot.status == 'free').length;
    
    final pendingSlots = room.timeSlots.where((slot) => 
        slot.status == 'pending').length;
    
    final reservedSlots = room.timeSlots.where((slot) => 
        slot.status == 'reserved').length;
    
    final isAvailable = availableSlots > 0 && 
                       !room.isDisabled; // REMOVED: && BookingDataStore.canStudentBookToday()

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
            
            // Room Info
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
                  if (selectedTab == "Available" && !room.isDisabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$availableSlots available, $pendingSlots pending, $reservedSlots reserved',
                      style: TextStyle(
                        color: availableSlots > 0 ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (selectedTab == "Pending" && !room.isDisabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$pendingSlots pending slot${pendingSlots != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (selectedTab == "Reserved" && !room.isDisabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$reservedSlots reserved slot${reservedSlots != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (selectedTab == "Disabled") ...[
                    const SizedBox(height: 4),
                    Text(
                      'Room temporarily unavailable',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Status and Action
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(room),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isAvailable ? () {
                    _showTimeSlotSelection(context, room);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? const Color(0xFF2C5473) : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    selectedTab == "Pending" || selectedTab == "Reserved" || selectedTab == "Disabled" ? 'View' : 'Book Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Color _getStatusColor(BookingRoom room) {
    if (room.isDisabled) return const Color(0xFFD64541);
    
    final availableSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final pendingSlots = room.timeSlots.where((slot) => slot.status == 'pending').length;
    final reservedSlots = room.timeSlots.where((slot) => slot.status == 'reserved').length;
    final totalSlots = room.timeSlots.length;
    
    // If most slots are pending, show as pending
    if (pendingSlots > totalSlots / 2) return const Color(0xFFD4A017);
    // If most slots are reserved, show as reserved
    if (reservedSlots > totalSlots / 2) return const Color(0xFF428BCA);
    // If has any pending slots, show as pending
    if (pendingSlots > 0) return const Color(0xFFD4A017);
    // If has any reserved slots, show as reserved
    if (reservedSlots > 0) return const Color(0xFF428BCA);
    
    return availableSlots > 0 ? const Color(0xFF26A65B) : const Color(0xFFD64541);
  }

  String _getStatusText(BookingRoom room) {
    if (room.isDisabled) return "Disabled";
    
    final availableSlots = room.timeSlots.where((slot) => slot.status == 'free').length;
    final pendingSlots = room.timeSlots.where((slot) => slot.status == 'pending').length;
    final reservedSlots = room.timeSlots.where((slot) => slot.status == 'reserved').length;
    final totalSlots = room.timeSlots.length;
    
    // If most slots are pending, show as pending
    if (pendingSlots > totalSlots / 2) return "Mostly Pending";
    // If most slots are reserved, show as reserved
    if (reservedSlots > totalSlots / 2) return "Mostly Reserved";
    // If has any pending slots, show as pending
    if (pendingSlots > 0) return "Partially Pending";
    // If has any reserved slots, show as reserved
    if (reservedSlots > 0) return "Partially Reserved";
    
    return availableSlots > 0 ? "Available" : "Full";
  }

  void _showTimeSlotSelection(BuildContext context, BookingRoom room) {
    final availableSlots = BookingDataStore.getAvailableTimeSlots(room.id);
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
            // Header
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
            
            // Room Info
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
                            Icons.photo,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Time Slots
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "All Time Slots",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date: ${_formatDate(DateTime.now())}",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (allSlots.isEmpty)
                      _buildNoSlotsAvailable()
                    else
                      Expanded(
                        child: ListView(
                          children: allSlots.map((slot) => _buildTimeSlotCard(slot, context, room)).toList(),
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

  Widget _buildNoSlotsAvailable() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            "No time slots available",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, BuildContext context, BookingRoom room) {
    final isAvailable = slot.status == 'free' && BookingDataStore.isTimeSlotAvailable(slot);
    
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
          child: Icon(
            _getStatusIcon(slot.status),
            color: slot.color,
          ),
        ),
        title: Text(
          slot.time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          slot.displayStatus,
          style: TextStyle(
            color: slot.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: isAvailable 
            ? ElevatedButton(
                onPressed: () {
                  _bookTimeSlot(context, slot, room);
                },
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
            : Text(
                slot.displayStatus,
                style: TextStyle(
                  color: slot.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
    // REMOVED: Booking limit check
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
            Text('Date: ${_formatDate(DateTime.now())}'),
            const SizedBox(height: 8),
            const Text(
              'Note: Booking will be pending approval',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
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
    try {
      // Create the booking
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

      // Add booking to history and update room status
      BookingDataStore.addBooking(booking);
      
      // Close all dialogs and bottom sheet
      Navigator.pop(context); // Close confirmation dialog
      Navigator.pop(context); // Close bottom sheet
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked ${room.name} for ${slot.time}. Status: Pending'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh the state
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}