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
    "Pending",
    "Reserved",
    "Disabled",
  ];

  @override
  void initState() {
    super.initState();
    // Reset rooms for new day if needed
    _checkAndResetRooms();
  }

  void _checkAndResetRooms() {
    final now = DateTime.now();
    final lastReset = BookingDataStore.userBookings.isNotEmpty 
        ? BookingDataStore.userBookings.first.bookedAt 
        : now.subtract(const Duration(days: 1));
    
    if (!_isSameDay(lastReset, now)) {
      BookingDataStore.resetRoomsForNextDay();
    }
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

          // Show message if student already booked today
          if (!BookingDataStore.canStudentBookToday() && selectedTab == "Available")
            _buildAlreadyBookedMessage(),

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

  Widget _buildAlreadyBookedMessage() {
    final todayBooking = BookingDataStore.getTodayBooking();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Already Booked Today",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayBooking != null 
                    ? "You have already booked ${todayBooking.roomName} for ${todayBooking.timeSlot}"
                    : "You have already booked a room for today",
                  style: const TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
        return "No pending bookings";
      case "Reserved":
        return "No reserved rooms";
      case "Disabled":
        return "No disabled rooms";
      default:
        return "No rooms found";
    }
  }

  List<BookingRoom> _getFilteredRooms() {
    final now = DateTime.now();
    
    switch (selectedTab) {
      case "Available":
        return BookingDataStore.availableRooms.where((room) {
          if (room.isDisabled) return false;
          final hasAvailableSlots = room.timeSlots.any((slot) => 
              slot.status == 'free' && 
              BookingDataStore.isTimeSlotAvailable(slot));
          return hasAvailableSlots && BookingDataStore.canStudentBookToday();
        }).toList();
      
      case "Pending":
        return BookingDataStore.availableRooms.where((room) {
          final hasPendingSlots = room.timeSlots.any((slot) => 
              slot.status == 'pending' && 
              _isSameDay(slot.bookedDate ?? now, now));
          return hasPendingSlots;
        }).toList();
      
      case "Reserved":
        return BookingDataStore.availableRooms.where((room) {
          final hasReservedSlots = room.timeSlots.any((slot) => 
              slot.status == 'reserved' && 
              _isSameDay(slot.bookedDate ?? now, now));
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
        slot.status == 'free' && 
        BookingDataStore.isTimeSlotAvailable(slot)).length;
    
    final isAvailable = availableSlots > 0 && 
                       !room.isDisabled && 
                       BookingDataStore.canStudentBookToday();

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
                      '$availableSlots slot${availableSlots != 1 ? 's' : ''} available today',
                      style: TextStyle(
                        color: availableSlots > 0 ? Colors.green : Colors.red,
                        fontSize: 12,
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
                    _navigateToTimeSlots(context, room);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5473),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
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
    
    final now = DateTime.now();
    final hasPending = room.timeSlots.any((slot) => 
        slot.status == 'pending' && _isSameDay(slot.bookedDate ?? now, now));
    final hasReserved = room.timeSlots.any((slot) => 
        slot.status == 'reserved' && _isSameDay(slot.bookedDate ?? now, now));
    
    if (hasPending) return const Color(0xFFD4A017);
    if (hasReserved) return const Color(0xFF428BCA);
    
    final hasAvailable = room.timeSlots.any((slot) => 
        slot.status == 'free' && BookingDataStore.isTimeSlotAvailable(slot));
    
    return hasAvailable ? const Color(0xFF26A65B) : const Color(0xFFD64541);
  }

  String _getStatusText(BookingRoom room) {
    if (room.isDisabled) return "Disabled";
    
    final now = DateTime.now();
    final hasPending = room.timeSlots.any((slot) => 
        slot.status == 'pending' && _isSameDay(slot.bookedDate ?? now, now));
    final hasReserved = room.timeSlots.any((slot) => 
        slot.status == 'reserved' && _isSameDay(slot.bookedDate ?? now, now));
    
    if (hasPending) return "Pending";
    if (hasReserved) return "Reserved";
    
    final hasAvailable = room.timeSlots.any((slot) => 
        slot.status == 'free' && BookingDataStore.isTimeSlotAvailable(slot));
    
    return hasAvailable ? "Available" : "Full";
  }

  void _navigateToTimeSlots(BuildContext context, BookingRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeSlotSelectionPage(room: room),
      ),
    ).then((_) {
      // Refresh the state when returning from time slot selection
      setState(() {});
    });
  }
}

class TimeSlotSelectionPage extends StatefulWidget {
  final BookingRoom room;

  const TimeSlotSelectionPage({super.key, required this.room});

  @override
  State<TimeSlotSelectionPage> createState() => _TimeSlotSelectionPageState();
}

class _TimeSlotSelectionPageState extends State<TimeSlotSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availableSlots = BookingDataStore.getAvailableTimeSlots(widget.room.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
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
                      widget.room.name,
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Room Image
                  Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.room.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: const Color(0xFFE8EDF1),
                            child: const Icon(
                              Icons.photo,
                              size: 50,
                              color: Color(0xFF2C5473),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.black54, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        widget.room.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Check if student already booked today
                  if (!BookingDataStore.canStudentBookToday())
                    _buildAlreadyBookedTodayWarning(),

                  // Time Slots
                  Container(
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
                        const Text(
                          "Available Time Slots for Today",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
                        
                        if (availableSlots.isEmpty)
                          _buildNoSlotsAvailable()
                        else
                          ...availableSlots.map((slot) => _buildTimeSlotCard(slot, context)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Container(
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
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.room.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyBookedTodayWarning() {
    final todayBooking = BookingDataStore.getTodayBooking();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Already Booked Today",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayBooking != null
                    ? "You can only book one slot per day. You already have ${todayBooking.roomName} booked for ${todayBooking.timeSlot}"
                    : "You can only book one slot per day. You already have a booking for today.",
                  style: const TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSlotsAvailable() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          const Text(
            "No available time slots",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "All time slots for today are either booked or have expired",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, BuildContext context) {
    final now = DateTime.now();
    final isExpired = !BookingDataStore.isTimeSlotAvailable(slot);

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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isExpired ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Text(
          isExpired ? 'Expired' : slot.displayStatus,
          style: TextStyle(
            color: isExpired ? Colors.grey : slot.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: !isExpired && BookingDataStore.canStudentBookToday()
            ? ElevatedButton(
                onPressed: () {
                  _bookTimeSlot(context, slot);
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
            : null,
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
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
        return Icons.block;
      case 'disabled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  void _bookTimeSlot(BuildContext context, TimeSlot slot) {
    if (!BookingDataStore.canStudentBookToday()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only book one slot per day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${widget.room.name}'),
            Text('Time: ${slot.time}'),
            Text('Date: ${_formatDate(DateTime.now())}'),
            const SizedBox(height: 8),
            const Text(
              'Note: You can only book one slot per day',
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
              _confirmBooking(context, slot);
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

  void _confirmBooking(BuildContext context, TimeSlot slot) {
    try {
      // Create the booking
      final booking = UserBooking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        roomName: widget.room.name,
        roomId: widget.room.id,
        date: DateTime.now(),
        timeSlot: slot.time,
        studentName: BookingDataStore.currentStudentName,
        studentId: BookingDataStore.currentStudentId,
        status: 'Pending', 
        bookedAt: DateTime.now(),
      );

      // Add booking to history and update room status
      BookingDataStore.addBooking(booking);
      
      // Close dialog and go back to booking page
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Go back to booking page
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully booked ${widget.room.name} for ${slot.time}. Status: Pending'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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