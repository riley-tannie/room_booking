import 'package:flutter/material.dart';
import '../api_service.dart';
import 'booking_detail_page.dart';
import '../data_store.dart';

class RequestStatus extends StatelessWidget {
  const RequestStatus({super.key});

  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: FutureBuilder(
        future: _loadStudentRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<UserBooking> todayRequests = snapshot.data ?? [];
          final pendingBookings = todayRequests.where((b) => b.status == 'Pending').toList();
          final rejectedBookings = todayRequests.where((b) => b.status == 'Rejected').toList();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pendingBookings.isNotEmpty) ...[
                    const Text(
                      'Pending Requests - Today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...pendingBookings.map((b) => _buildRequestCard(b, context)),
                    const SizedBox(height: 24),
                  ],
                  if (rejectedBookings.isNotEmpty) ...[
                    const Text(
                      'Rejected Requests - Today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...rejectedBookings.map((b) => _buildRequestCard(b, context)),
                  ],
                  if (pendingBookings.isEmpty && rejectedBookings.isEmpty)
                    _buildEmptyState(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<UserBooking>> _loadStudentRequests() async {
    final studentId = await ApiService.getCurrentStudentId();
    if (studentId == null) return [];

    final requestsData = await ApiService.getStudentRequests(studentId);
    return requestsData.map((request) => UserBooking.fromJson(request)).toList();
  }

  Widget _buildRequestCard(UserBooking booking, BuildContext context) {
    final room = BookingRoom(
      id: booking.roomId,
      name: booking.roomName,
      category: 'Room',
      location: booking.roomLocation,
      imageUrl: booking.roomImageUrl,
      description: 'Room description',
      isDisabled: false,
      timeSlots: [],
    );

    Color statusColor;
    String statusText;
    Color approvalBgColor;
    String approvalText;

    switch (booking.status) {
      case 'Rejected':
        statusColor = errorColor;
        statusText = 'Rejected';
        approvalText = 'Reservation Rejected';
        approvalBgColor = const Color(0xFFFBCACA);
        break;
      case 'Pending':
      default:
        statusColor = warningColor;
        statusText = 'Pending';
        approvalText = 'Awaiting Approval';
        approvalBgColor = const Color(0xFFFFF3CD);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                        child: const Icon(Icons.photo, color: Color(0xFF2C5473)),
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(booking.date)} • ${booking.timeSlot}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on,
                              color: Colors.black54, size: 16),
                          Expanded(
                            child: Text(
                              room.location,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingDetailPage(
                                    booking: booking,
                                    room: room,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'See details',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: approvalBgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(
              approvalText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
                fontSize: 12,
              ),
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
          Icon(Icons.event_note_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No Booking Requests Today",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You have no pending or rejected requests for today.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}