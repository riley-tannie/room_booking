import 'package:flutter/material.dart';
import '../data_store.dart';
import 'booking_detail_page.dart';

class RequestStatus extends StatelessWidget {
  const RequestStatus({super.key});

  static const Color successColor = Color(0xFF10B981); 
  static const Color infoColor = Color(0xFF3B82F6); 
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    // Filter bookings for current user
    final userBookings = BookingDataStore.userBookings
        .where((booking) => booking.studentId == BookingDataStore.currentStudentId)
        .toList();

    final pendingBookings = userBookings.where((b) => b.status == 'Pending').toList();
    final approvedBookings = userBookings.where((b) => b.status == 'Approved').toList();
    final rejectedBookings = userBookings.where((b) => b.status == 'Rejected').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),

              // Status Summary
              _buildStatusSummary(
                pending: pendingBookings.length,
                approved: approvedBookings.length,
                rejected: rejectedBookings.length,
              ),
              const SizedBox(height: 24),

              // Pending Requests
              if (pendingBookings.isNotEmpty) ...[
                const Text(
                  'Pending Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                ...pendingBookings.map((booking) => 
                  _buildRequestCard(booking, context)
                ).toList(),
                const SizedBox(height: 24),
              ],

              // Approved Requests
              if (approvedBookings.isNotEmpty) ...[
                const Text(
                  'Approved Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                ...approvedBookings.map((booking) => 
                  _buildRequestCard(booking, context)
                ).toList(),
                const SizedBox(height: 24),
              ],

              // Rejected Requests
              if (rejectedBookings.isNotEmpty) ...[
                const Text(
                  'Rejected Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 12),
                ...rejectedBookings.map((booking) => 
                  _buildRequestCard(booking, context)
                ).toList(),
              ],

              // Empty State
              if (userBookings.isEmpty) 
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummary({required int pending, required int approved, required int rejected}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            count: pending,
            label: 'Pending',
            color: warningColor,
          ),
          _buildStatusItem(
            count: approved,
            label: 'Approved',
            color: successColor,
          ),
          _buildStatusItem(
            count: rejected,
            label: 'Rejected',
            color: errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({required int count, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(UserBooking booking, BuildContext context) {
    final room = BookingDataStore.availableRooms
        .firstWhere((room) => room.id == booking.roomId, orElse: () => BookingDataStore.availableRooms.first);

    Color statusColor;
    String statusText;
    String approvalText;
    Color approvalBgColor;

    switch (booking.status) {
      case 'Approved':
        statusColor = successColor;
        statusText = 'Approved';
        approvalText = 'Reservation Approved';
        approvalBgColor = const Color(0xFFC8FACC);
        break;
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
                        child: const Icon(
                          Icons.photo,
                          color: Color(0xFF2C5473),
                          size: 30,
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
                                fontSize: 12, 
                                color: Colors.black54
                              ),
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
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No Booking Requests",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You haven't made any booking requests yet",
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