import 'package:flutter/material.dart';
import '../api_service.dart';
import 'room_detail_lecturer.dart';

class RoomListPageLecturer extends StatefulWidget {
  const RoomListPageLecturer({super.key});

  @override
  State<RoomListPageLecturer> createState() => _RoomListPageLecturerState();
}

class _RoomListPageLecturerState extends State<RoomListPageLecturer> {
  String selectedTab = "All";
  String searchQuery = "";
  List<LecturerRoom> availableRooms = [];
  bool isLoading = true;

  final List<String> allTimeSlots = ['08:00-10:00', '10:00-12:00', '13:00-15:00', '15:00-17:00'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final roomsData = await ApiService.getTodayRooms();

      final List<LecturerRoom> rooms = [];
      for (var r in roomsData) {
        try {
          // Best-effort mapping: adapt to your API keys if different
          final id = (r['id'] ?? r['room_id'] ?? r['roomId'])?.toString() ?? '';
          final name = (r['name'] ?? 'Unnamed Room').toString();
          final category = (r['category'] ?? 'General').toString();
          final location = (r['location'] ?? r['place'] ?? '').toString();
          final imageUrl = (r['image_url'] ?? r['image'] ?? 'assets/images/default_room.jpg').toString();
          final isDisabled = (r['is_disabled'] ?? r['disabled'] ?? false) as bool? ?? false;

          final room = LecturerRoom(
            id: id,
            name: name,
            category: category,
            location: location,
            imageUrl: imageUrl,
            isDisabled: isDisabled,
            timeSlots: [],
          );

          // Try to fetch slot-level details if API provides them
          try {
            final slotData = await ApiService.getRoomTimeSlots(room.id);
            room.timeSlots = _createTimeSlotsWithStatus(slotData);
          } catch (_) {
            // If API doesn't provide per-slot details, try to infer from counts
            final free = (r['free_slots'] ?? 0) as int? ?? 0;
            final pending = (r['pending_slots'] ?? 0) as int? ?? 0;
            final reserved = (r['reserved_slots'] ?? 0) as int? ?? 0;
            room.timeSlots = _createTimeSlotsFromCounts(free, pending, reserved);
          }

          rooms.add(room);
        } catch (e) {
          // skip malformed room item
          continue;
        }
      }

      if (!mounted) return;
      setState(() {
        availableRooms = rooms;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Failed to load rooms: $e');
    }
  }

  List<TimeSlot> _createTimeSlotsFromCounts(int free, int pending, int reserved) {
    // Simple distribution: prefer marking earliest slots as reserved/pending then free.
    final List<TimeSlot> slots = [];
    int remainingFree = free;
    int remainingPending = pending;
    int remainingReserved = reserved;

    for (var t in allTimeSlots) {
      String status = 'free';
      String displayStatus = 'Available';
      Color color = const Color(0xFF26A65B);

      if (remainingReserved > 0) {
        status = 'reserved';
        displayStatus = 'Reserved';
        color = const Color(0xFFEF4444);
        remainingReserved--;
      } else if (remainingPending > 0) {
        status = 'pending';
        displayStatus = 'Pending';
        color = const Color(0xFFF59E0B);
        remainingPending--;
      } else if (remainingFree > 0) {
        status = 'free';
        displayStatus = 'Available';
        color = const Color(0xFF26A65B);
        remainingFree--;
      } else {
        status = 'disabled';
        displayStatus = 'Disabled';
        color = const Color(0xFF6B7280);
      }

      slots.add(TimeSlot(
        id: t,
        time: t,
        status: status,
        displayStatus: displayStatus,
        color: color,
      ));
    }
    return slots;
  }

  List<TimeSlot> _createTimeSlotsWithStatus(List<dynamic> timeSlotsData) {
    final List<TimeSlot> timeSlots = [];
    final now = DateTime.now();
    final currentTime = now.hour * 60 + now.minute;

    final timeSlotConfig = [
      {'time': '08:00-10:00', 'start': 8 * 60},
      {'time': '10:00-12:00', 'start': 10 * 60},
      {'time': '13:00-15:00', 'start': 13 * 60},
      {'time': '15:00-17:00', 'start': 15 * 60},
    ];

    for (var slotConfig in timeSlotConfig) {
      final slotTime = slotConfig['time'] as String;
      final slotStart = slotConfig['start'] as int;

      dynamic slotData;
      try {
        slotData = timeSlotsData.firstWhere((s) {
          final key = s is Map ? (s['time_slot'] ?? s['time'] ?? s['slot']) : null;
          return key != null && key.toString() == slotTime;
        });
      } catch (e) {
        slotData = null;
      }

      String status = 'free';
      String displayStatus = 'Available';
      Color color = const Color(0xFF26A65B);

      if (currentTime >= slotStart) {
        status = 'disabled';
        displayStatus = 'Time Passed';
        color = const Color(0xFF6B7280);
      } else if (slotData != null) {
        status = slotData['status']?.toString() ?? 'free';
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
      final matchesTab = selectedTab == "All" ? true : room.category == selectedTab;
      final matchesSearch = room.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    final Map<String, List<LecturerRoom>> groupedRooms = {};
    if (selectedTab == "All") {
      for (var room in filteredRooms) {
        final category = room.category;
        groupedRooms.putIfAbsent(category, () => []).add(room);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Available Room for Today",
            style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            ),
          ),

          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFE8EDF1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2C5473)),
                const SizedBox(width: 8),
                Text(_formatDateWithWeekday(DateTime.now()),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C5473))),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search rooms...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF2C5473), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(color: const Color(0xFFE8EDF1), borderRadius: BorderRadius.circular(25)),
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

  Widget _buildGroupedRooms(Map<String, List<LecturerRoom>> groupedRooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedRooms.keys.map((category) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E2A3A))),
                const SizedBox(height: 12),
                ...groupedRooms[category]!.map((room) => _buildRoomCard(room)),
                const SizedBox(height: 24),
              ],
            )),
      ],
    );
  }

  Widget _buildFilteredRooms(List<LecturerRoom> filteredRooms) {
    return Column(children: [...filteredRooms.map((room) => _buildRoomCard(room))]);
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("No Rooms Available Today",
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text("All rooms are currently disabled or no available time slots for today",
              style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5473), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Refresh', style: TextStyle(color: Colors.white)),
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
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF2C5473) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(title,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(LecturerRoom room) {
    final availableSlots = room.timeSlots.where((slot) => slot.status == 'free' && slot.displayStatus == 'Available').length;
    final bool canBook = availableSlots > 0 && !room.isDisabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
        BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
      ]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: room.imageUrl.startsWith('http')
                  ? Image.network(room.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => _roomImageFallback())
                  : Image.asset(room.imageUrl, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => _roomImageFallback()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(room.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(child: Text(room.location, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                ]),
                const SizedBox(height: 4),
                Text(
                  '$availableSlots of ${allTimeSlots.length} time slots available',
                  style: TextStyle(color: canBook ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ]),
            ),
            ElevatedButton(
              onPressed: canBook
                  ? () {
                      _showTimeSlotSelection(context, room);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canBook ? const Color(0xFF2C5473) : Colors.grey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(availableSlots > 0 ? 'View Slots' : 'Full',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roomImageFallback() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFE8EDF1),
      child: const Icon(Icons.meeting_room, color: Color(0xFF2C5473), size: 30),
    );
  }

  void _showTimeSlotSelection(BuildContext context, LecturerRoom room) {
    final allSlots = room.timeSlots;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFF2C5473), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('All Time Slots - ${room.name}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: room.imageUrl.startsWith('http')
                      ? Image.network(room.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _roomImageFallback())
                      : Image.asset(room.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _roomImageFallback()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(room.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(room.location, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(color: const Color(0xFFE8EDF1), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2C5473)),
                        const SizedBox(width: 4),
                        Text(_formatDateWithWeekday(DateTime.now()), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C5473))),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("All Time Slots:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E2A3A))),
                  const SizedBox(height: 12),
                  Text("Date: ${_formatDateWithWeekday(DateTime.now())}", style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  _buildStatusLegend(),
                  const SizedBox(height: 16),
                  if (allSlots.isEmpty)
                    _buildNoSlotsAvailable()
                  else
                    Expanded(
                      child: ListView(children: allSlots.map((slot) => _buildTimeSlotCard(slot, context, room)).toList()),
                    ),
                ]),
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
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildLegendItem(const Color(0xFF26A65B), 'Available'),
        _buildLegendItem(const Color(0xFFF59E0B), 'Pending'),
        _buildLegendItem(const Color(0xFFEF4444), 'Reserved'),
        _buildLegendItem(const Color(0xFF6B7280), 'Disabled'),
      ]),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildNoSlotsAvailable() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        const Text("No time slots available", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const Text("All time slots are either booked, pending, or have passed for today", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildTimeSlotCard(TimeSlot slot, BuildContext context, LecturerRoom room) {
    final canBook = slot.status == 'free';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3)),
      ]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: slot.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(_getStatusIcon(slot.status), color: slot.color)),
        title: Text(slot.time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: canBook ? Colors.black87 : Colors.grey)),
        subtitle: Text(slot.displayStatus, style: TextStyle(color: slot.color, fontWeight: FontWeight.w600)),
        trailing: canBook
            ? ElevatedButton(
                onPressed: () {
                  // Lecturer view: we open detail page (lecturer can view bookings/approve there)
                  Navigator.push(context, MaterialPageRoute(builder: (c) => RoomDetailLecturer(room: room.toMap())));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5473), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: slot.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: slot.color)),
                child: Text(slot.displayStatus, style: TextStyle(color: slot.color, fontSize: 12, fontWeight: FontWeight.w600)),
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

  String _formatDateWithWeekday(DateTime date) {
    const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final weekdayIndex = date.weekday % 7;
    return "${weekdays[weekdayIndex]}, ${date.day}/${date.month}/${date.year}";
  }
}

/// Lightweight LecturerRoom model for this file
class LecturerRoom {
  final String id;
  final String name;
  final String category;
  final String location;
  final String imageUrl;
  final bool isDisabled;
  List<TimeSlot> timeSlots;

  LecturerRoom({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.isDisabled,
    required this.timeSlots,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'location': location,
      'image_url': imageUrl,
      'is_disabled': isDisabled,
      // timeSlots serialized minimally
      'time_slots': timeSlots.map((s) => s.toMap()).toList(),
    };
  }
}

/// Lightweight TimeSlot model for this file
class TimeSlot {
  final String id;
  final String time;
  final String status;
  final String displayStatus;
  final Color color;

  TimeSlot({
    required this.id,
    required this.time,
    required this.status,
    required this.displayStatus,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'time': time, 'status': status, 'display_status': displayStatus};
  }
}
