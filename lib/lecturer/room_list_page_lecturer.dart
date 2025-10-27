import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'room_detail_lecturer.dart';
import 'data_store.dart';

class RoomListPageLecturer extends StatelessWidget {
  const RoomListPageLecturer({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Room>> groupedRooms = {};
    for (var room in DataStore.rooms) {
      groupedRooms.putIfAbsent(room.group, () => []).add(room);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          room.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          room.subTitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: room.statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            room.statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RoomDetailLecturer(roomName: room.name)),
        ),
      ),
    );
  }
}