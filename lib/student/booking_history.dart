import 'package:flutter/material.dart';
import '../data_store.dart';
import 'booking_detail_page.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ALL bookings for current user, sorted by date (newest first)
    final userBookings = BookingDataStore.userBookings
        .where((booking) => booking.studentId == BookingDataStore.currentStudentId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group by month
    final Map<String, List<UserBooking>> bookingsByMonth = {};
    for (final booking in userBookings) {
      final monthKey = "${_getMonthName(booking.date.month)} ${booking.date.year}";
      if (!bookingsByMonth.containsKey(monthKey)) {
        bookingsByMonth[monthKey] = [];
      }
      bookingsByMonth[monthKey]!.add(booking);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Booking History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3C6E),
                ),
              ),
              const SizedBox(height: 16),

              if (bookingsByMonth.isEmpty)
                _buildEmptyHistory()
              else
                ...bookingsByMonth.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E3C6E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...entry.value.map((booking) => 
                        _buildBookingCard(context, booking)
                      ).toList(),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, UserBooking booking) {
    final room = BookingDataStore.availableRooms
        .firstWhere((room) => room.id == booking.roomId, orElse: () => BookingDataStore.availableRooms.first);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0E3C6E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(booking.date)} • ${booking.timeSlot}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          room.location,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Add status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(booking.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFF3FF),
                      foregroundColor: const Color(0xFF3E56C3),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
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
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No Booking History",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your bookings will appear here",
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF26A65B); // Green
      case 'Pending':
        return const Color(0xFFD4A017); // Orange/Yellow
      case 'Rejected':
        return const Color(0xFFD64541); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}