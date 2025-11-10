import 'package:flutter/material.dart';
import '../api_service.dart';

class RoomDetailLecturer extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailLecturer({super.key, required this.room});

  @override
  State<RoomDetailLecturer> createState() => _RoomDetailLecturerState();
}

class _RoomDetailLecturerState extends State<RoomDetailLecturer> {
  List<dynamic> timeSlots = [];
  bool isLoading = true;
  Map<String, dynamic>? roomDetails;

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    try {
      final response = await ApiService.getTodayTimeSlots(widget.room['id']);
      setState(() {
        timeSlots = response;
        roomDetails = widget.room;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load room data : $e'), backgroundColor: Colors.red),
      );
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
      default:
        return Colors.grey;
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
      default:
        return 'Unknown';
    }
  }

  Widget _buildTimeSlotCard(Map<String, dynamic> slot) {
    final status = slot['status'] ?? 'free';
    final student = slot['student_name'] ?? '';
    final time = slot['time_slot'] ?? '';

    Color color = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2A3A)),
                  ),
                  if (student.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Booked by: $student",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(status),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _headerRoomCard() {
    final imageUrl = roomDetails?['image_url'] ?? 'assets/images/default_room.jpg';
    bool isNetwork = imageUrl.toString().startsWith('http');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetwork
                  ? Image.network(imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _errorImageBox())
                  : Image.asset(imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _errorImageBox()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomDetails?['name'] ?? 'No name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(roomDetails?['category'] ?? 'General',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          roomDetails?['location'] ?? '-',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _errorImageBox() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFE8EDF1),
      child: const Icon(Icons.image_not_supported, size: 30, color: Color(0xFF2C5473)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Room Detail (Lecturer)'),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerRoomCard(),
                  const SizedBox(height: 20),
                  const Text("Today's Time Slots",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  if (timeSlots.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No time slots available',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else
                    ...timeSlots.map((e) => _buildTimeSlotCard(e)).toList(),
                ],
              ),
            ),
    );
  }
}
