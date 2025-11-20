import 'package:flutter/material.dart';
import '../api_service.dart';
import '../data_store.dart';

class RoomEditPage extends StatefulWidget {
  final BookingRoom room;

  const RoomEditPage({Key? key, required this.room}) : super(key: key);

  @override
  _RoomEditPageState createState() => _RoomEditPageState();
}

class _RoomEditPageState extends State<RoomEditPage> {
  late BookingRoom _room;
  bool _isLoading = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Study Room';

  final List<String> _categories = [
    'Study Room',
    'Multimedia Room',
    'Lecture Hall',
    'Library',
    'Conference Room'
  ];

  // Define all possible time slots
  final List<String> _allTimeSlots = ['08:00-10:00', '10:00-12:00', '13:00-15:00', '15:00-17:00'];

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _nameController.text = _room.name;
    _locationController.text = _room.location;
    _descriptionController.text = _room.description;
    _selectedCategory = _room.category;
    _loadRoomTimeSlots();
  }

  Future<void> _loadRoomTimeSlots() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch actual time slots for the room
      final timeSlotsData = await ApiService.getTodayTimeSlots(_room.id);
      
      // Convert to TimeSlot objects with time validation
      _room.timeSlots = timeSlotsData.map((slotData) {
        final slot = TimeSlot.fromJson(slotData);
        // Check if time has passed and update status accordingly
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

      // Ensure we have all 4 time slots
      _ensureAllTimeSlots();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Fallback: ensure we have all time slots
      _ensureAllTimeSlots();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _ensureAllTimeSlots() {
    // Ensure we have all 4 time slots
    final existingSlots = _room.timeSlots.map((slot) => slot.time).toList();
    
    for (String slotTime in _allTimeSlots) {
      if (!existingSlots.contains(slotTime)) {
        // Add missing time slot as free (if not passed) or time_passed
        final isPassed = _isTimePassed(slotTime);
        _room.timeSlots.add(TimeSlot(
          id: slotTime,
          time: slotTime,
          status: isPassed ? 'time_passed' : 'free',
          displayStatus: isPassed ? 'Time Passed' : 'Available',
          color: isPassed ? const Color(0xFF9CA3AF) : const Color(0xFF26A65B),
        ));
      }
    }

    // Sort time slots
    _room.timeSlots.sort((a, b) => _allTimeSlots.indexOf(a.time).compareTo(_allTimeSlots.indexOf(b.time)));
  }

  bool _isTimePassed(String timeSlot) {
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;
    
    // Parse the end time from time slot string (e.g., "08:00-10:00")
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

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateRoom() async {
    if (_nameController.text.isEmpty || _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in room name and location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateRoom(
        roomId: _room.id,
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update room: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTimeSlot(TimeSlot slot) async {
    try {
      // Don't allow toggling if time has passed
      if (_isTimePassed(slot.time)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot modify time slots that have already passed')),
        );
        return;
      }

      // Don't allow toggling if slot is booked or pending
      if (slot.status == 'pending' || slot.status == 'reserved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot modify booked or pending time slots')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (slot.status == 'disabled') {
        await ApiService.enableTimeSlot(
          roomId: _room.id,
          timeSlot: slot.time,
        );
      } else if (slot.status == 'free') {
        await ApiService.disableTimeSlot(
          roomId: _room.id,
          timeSlot: slot.time,
        );
      }

      // Reload the time slots to get updated status
      await _loadRoomTimeSlots();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time slot updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update time slot: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      case 'time_passed':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return 'Available';
      case 'pending':
        return 'Pending';
      case 'reserved':
        return 'Reserved';
      case 'disabled':
        return 'Disabled';
      case 'time_passed':
        return 'Time Passed';
      default:
        return 'Unknown';
    }
  }

  Widget _buildTimeSlotCard(TimeSlot slot) {
    final isPassed = _isTimePassed(slot.time);
    final isInteractive = (slot.status == 'free' || slot.status == 'disabled') && !isPassed;
    final statusColor = _getStatusColor(isPassed ? 'time_passed' : slot.status);
    final statusText = _getStatusText(isPassed ? 'time_passed' : slot.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time slot info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (slot.studentName != null && slot.studentName!.isNotEmpty && !isPassed) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Booked by: ${slot.studentName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (isPassed) ...[
                    const SizedBox(height: 4),
                    Text(
                      'This time slot has ended',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action button or status badge
            if (isInteractive)
              ElevatedButton(
                onPressed: _isLoading ? null : () => _toggleTimeSlot(slot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: slot.status == 'free' ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        slot.status == 'free' ? 'Disable' : 'Enable',
                        style: const TextStyle(color: Colors.white),
                      ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomImage() {
    final bool isNetworkImage = _room.imageUrl.startsWith('http');
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNetworkImage
            ? Image.network(
                _room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildRoomIcon(_room.category);
                },
              )
            : Image.asset(
                _room.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildRoomIcon(_room.category);
                },
              ),
      ),
    );
  }

  Widget _buildRoomIcon(String category) {
    return Center(
      child: Icon(
        _getRoomIcon(category),
        size: 30,
        color: const Color(0xFF2C5473),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Edit ${_room.name}',
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.only(top: 160),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Header
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildRoomImage(),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _room.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _room.category,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _room.location,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Room Details Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Room Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2A3A),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextField(
                                  controller: _nameController,
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
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Location',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.location_on),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.description),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 20),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updateRoom,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2C5473),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Update Room Details',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Time Slots Section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time Slots Management',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E2A3A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Manage availability for all time slots',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Show all 4 time slots
                                ..._room.timeSlots.map((slot) => _buildTimeSlotCard(slot)),
                              ],
                            ),
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