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
    return Scaffold(
      backgroundColor: const Color(0xFF2C5473),
      body: Column(
        children: [
          const SizedBox(height: 50),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text(
                  "Booking Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Room Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                room.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: const Color(0xFFE8EDF1),
                    child: const Icon(
                      Icons.photo,
                      size: 50,
                      color: Color(0xFF2C5473),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                room.location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Details Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(booking.status),
                        ),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Booking Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3C6E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow("Room Name", room.name),
                    _buildDetailRow("Booking Date", _formatDate(booking.date)),
                    _buildDetailRow("Time Slot", booking.timeSlot),
                    _buildDetailRow("Booked By", booking.studentName),
                    _buildDetailRow("Student ID", booking.studentId),
                    _buildDetailRow("Booking Status", booking.status),
                    _buildDetailRow("Booked On", _formatDateTime(booking.bookedAt)),

                    const SizedBox(height: 24),

                    const Text(
                      "Room Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3C6E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: const TextStyle(
                        color: Color(0xFF1D2D50),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5A5A5A),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0E3C6E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF10B981);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatDateTime(DateTime dateTime) {
    return "${_formatDate(dateTime)} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}