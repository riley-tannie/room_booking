import 'package:flutter/material.dart';
import 'package:room_booking/lecturer/room_detail_lecturer.dart';
import 'data_store.dart';

class BookingHistoryLecturer extends StatelessWidget {
  const BookingHistoryLecturer({super.key});

  String _formatActionTime(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$month/$day/${time.year} at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final historyEntries = DataStore.historyRecords;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (historyEntries.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Recent Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'History will appear here after you approve or disapprove a student request.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...historyEntries.map((entry) => _buildHistoryCard(context, entry)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryEntry entry) {
    final color = entry.isApproved ? const Color(0xFF26A65B) : const Color(0xFFD64541);
    final icon = entry.isApproved ? Icons.check_circle : Icons.cancel;
    final actionText = entry.isApproved ? 'Approved' : 'Disapproved';

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
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.roomName} - $actionText',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student: ${entry.studentName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Action Taken: ${_formatActionTime(entry.actionTime)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // ADD ONTAP TO THE ARROW ICON
            GestureDetector(
              onTap: () {
                // Navigate to room details or show more info
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoomDetailLecturer(roomName: entry.roomName)),
                );
              },
              child: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}