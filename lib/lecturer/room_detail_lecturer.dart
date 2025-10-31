import 'package:flutter/material.dart';
import 'time_slots.dart';

class RoomDetailLecturer extends StatelessWidget {
  final String roomName;

  const RoomDetailLecturer({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/room_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Location & General Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF457B9D), size: 28),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        '2nd Floor, D1, Library (Multimedia 1)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text(
              "Today's Time Slots",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimeSlotsSection(context),
            
            const SizedBox(height: 20),
            
            const Text(
              'Room Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Our multimedia room provides comfy beanbags and a large TV for relaxation and productivity. This room is equipped with high-speed internet and presentation tools. Students with ID and a lecturer\'s approval can book available time slots.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsSection(BuildContext context) {
    final timeSlots = TimeSlotManager.getTodaysTimeSlots(roomName);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: timeSlots.map((slot) => _buildTimeSlotRow(slot)).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeSlotRow(TimeSlot slot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            TimeSlotManager.getStatusIcon(slot.status),
            color: TimeSlotManager.getStatusColor(slot.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.timeRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (slot.bookedBy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Booked by: ${slot.bookedBy}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TimeSlotManager.getStatusColor(slot.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              slot.status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}