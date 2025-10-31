import 'package:flutter/material.dart';
import 'room_detail_lecturer.dart';
import 'data_store_lecturer.dart';
import 'time_slots.dart';

class RoomListLecturer extends StatelessWidget {
  const RoomListLecturer({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Room>> groupedRooms = {};
    for (var room in DataStore.rooms) {
      groupedRooms.putIfAbsent(room.group, () => []).add(room);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupedRooms.keys.map((groupName) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 12),
              ...groupedRooms[groupName]!.map((room) => _buildRoomCard(context, room)),
              const SizedBox(height: 24),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Room Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/room_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: room.isBookable ? null : Container(
                color: Colors.black54,
                child: const Icon(Icons.block, color: Colors.white, size: 30),
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
                    room.subTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRoomAvailabilityColor(room),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoomAvailabilityText(room),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // See Details Button
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RoomDetailLecturer(roomName: room.name)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5473),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'See Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoomAvailabilityColor(Room room) {
    final slots = TimeSlotManager.getTodaysTimeSlots(room.name);
    final freeSlots = slots.where((slot) => slot.status == 'free').length;
    
    if (freeSlots == 0) return Colors.red;
    if (freeSlots <= 2) return Colors.orange;
    return Colors.green;
  }

  String _getRoomAvailabilityText(Room room) {
    final slots = TimeSlotManager.getTodaysTimeSlots(room.name);
    final freeSlots = slots.where((slot) => slot.status == 'free').length;
    final pendingSlots = slots.where((slot) => slot.status == 'pending').length;
    
    if (freeSlots == 0 && pendingSlots > 0) return 'All Pending';
    if (freeSlots == 0) return 'Fully Booked';
    return '$freeSlots slots free';
  }
}