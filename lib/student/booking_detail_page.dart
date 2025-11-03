import 'package:flutter/material.dart';
import '../data_store.dart';

class BookingDetailPage extends StatelessWidget {
  final UserBooking booking;
  final BookingRoom room;

  const BookingDetailPage({
    super.key,
    required this.booking,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusDescription;

    switch (booking.status) {
      case 'Approved':
        statusColor = const Color(0xFF26A65B);
        statusDescription = 'Your booking has been approved.';
        break;
      case 'Rejected':
        statusColor = const Color(0xFFEF4444);
        statusDescription = 'Your booking request has been rejected.';
        break;
      case 'Pending':
      default:
        statusColor = const Color(0xFFF59E0B);
        statusDescription = 'Your booking is waiting for approval.';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2A3A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.category,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  room.location,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
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
            ),

            const SizedBox(height: 20),

            // Booking Details Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Date', _formatDate(booking.date)),
                    _buildDetailRow('Time Slot', booking.timeSlot),
                    _buildDetailRow('Booked At', _formatDateTime(booking.bookedAt)),
                    _buildDetailRow('Student ID', booking.studentId),
                    _buildDetailRow('Student Name', booking.studentName),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Status Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusDescription,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Room Description
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Room Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateTime(DateTime dateTime) {
    return "${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}