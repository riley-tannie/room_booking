import 'package:flutter/material.dart'; 
import '../api_service.dart';
import 'booking_detail_page.dart';
import '../data_store.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: FutureBuilder(
        future: _loadStudentBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<UserBooking> userBookings = snapshot.data ?? [];
          
          // Group by month - sort months in descending order (newest first)
          final Map<String, List<UserBooking>> bookingsByMonth = {};
          for (final booking in userBookings) {
            final monthKey = "${_getMonthName(booking.date.month)} ${booking.date.year}";
            if (!bookingsByMonth.containsKey(monthKey)) {
              bookingsByMonth[monthKey] = [];
            }
            bookingsByMonth[monthKey]!.add(booking);
          }

          // Sort months in descending order (newest first)
          final sortedMonths = bookingsByMonth.entries.toList()
            ..sort((a, b) {
              // Extract year and month from the key (e.g., "Nov 2025")
              final aYear = int.parse(a.key.split(' ')[1]);
              final bYear = int.parse(b.key.split(' ')[1]);
              final aMonth = _getMonthNumber(a.key.split(' ')[0]);
              final bMonth = _getMonthNumber(b.key.split(' ')[0]);
              
              // Compare years first, then months
              if (aYear != bYear) {
                return bYear.compareTo(aYear); // Descending
              }
              return bMonth.compareTo(aMonth); // Descending
            });

          return SafeArea(
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
                    ...sortedMonths.map((entry) {
                      // Sort bookings within each month by date (newest first) and then by time slot
                      final sortedBookings = entry.value..sort((a, b) {
                        // First compare by date
                        final dateComparison = b.date.compareTo(a.date);
                        if (dateComparison != 0) return dateComparison;
                        
                        // If same date, compare by time slot (convert to comparable format)
                        final aTime = _convertTimeSlotToComparable(a.timeSlot);
                        final bTime = _convertTimeSlotToComparable(b.timeSlot);
                        return bTime.compareTo(aTime);
                      });

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
                          ...sortedBookings.map((booking) => 
                            _buildBookingCard(context, booking)
                          ).toList(),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<UserBooking>> _loadStudentBookings() async {
    final studentId = await ApiService.getCurrentStudentId();
    print('Loading booking history for student: $studentId');
    
    if (studentId == null) {
      print('No student ID found');
      return [];
    }

    try {
      final bookingsData = await ApiService.getStudentBookings(studentId);
      print('Received ${bookingsData.length} bookings from API');
      
      final allBookings = bookingsData.map((booking) {
        print('Processing booking: ${booking.toString()}');
        return UserBooking.fromJson(booking);
      }).toList();
      
      // Sort by date (newest first) and then by time slot
      allBookings.sort((a, b) {
        // First compare by date
        final dateComparison = b.date.compareTo(a.date);
        if (dateComparison != 0) return dateComparison;
        
        // If same date, compare by time slot (convert to comparable format)
        final aTime = _convertTimeSlotToComparable(a.timeSlot);
        final bTime = _convertTimeSlotToComparable(b.timeSlot);
        return bTime.compareTo(aTime);
      });
      
      print('Successfully parsed ${allBookings.length} booking history items');
      return allBookings;
    } catch (e) {
      print('Error loading booking history: $e');
      return [];
    }
  }

  Widget _buildBookingCard(BuildContext context, UserBooking booking) {
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
    Color statusBgColor;
    String approvalText;

    switch (booking.status) {
      case 'Approved':
        statusColor = const Color(0xFF26A65B);
        statusText = 'Approved';
        statusBgColor = const Color(0xFF26A65B).withOpacity(0.1);
        approvalText = 'Reservation Approved';
        break;
      case 'Rejected':
        statusColor = const Color(0xFFEF4444);
        statusText = 'Rejected';
        statusBgColor = const Color(0xFFEF4444).withOpacity(0.1);
        approvalText = 'Reservation Rejected';
        break;
      case 'Pending':
      default:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Pending';
        statusBgColor = const Color(0xFFF59E0B).withOpacity(0.1);
        approvalText = 'Awaiting Approval';
        break;
    }

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
      child: Column(
        children: [
          Padding(
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
                      
                      // Show approved by information if available
                      if (booking.approvedByName != null && booking.approvedByName!.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        const Icon(Icons.person, size: 12, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          'Approved by: ${booking.approvedByName}', // Use approvedByName instead of approvedBy
          style: const TextStyle(
            color: Colors.green,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  ),
                      
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
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
                    ],
                  ),
                )
              ],
            ),
          ),
          // Add approval status bar at bottom (like in request_status.dart)
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  approvalText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 12,
                  ),
                ),
                // Show approval time if available
                if (booking.approvedBy != null && booking.approvedBy!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Approved on ${_formatDate(booking.bookedAt)} at ${_formatTime(booking.bookedAt)}',
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
            "Your booking history will appear here",
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

  int _getMonthNumber(String monthName) {
    switch (monthName) {
      case 'Jan': return 1;
      case 'Feb': return 2;
      case 'Mar': return 3;
      case 'Apr': return 4;
      case 'May': return 5;
      case 'Jun': return 6;
      case 'Jul': return 7;
      case 'Aug': return 8;
      case 'Sep': return 9;
      case 'Oct': return 10;
      case 'Nov': return 11;
      case 'Dec': return 12;
      default: return 0;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // Helper method to convert time slot to comparable format
  int _convertTimeSlotToComparable(String timeSlot) {
    // Convert "08:00-10:00" to 800 for sorting
    try {
      final startTime = timeSlot.split('-')[0].replaceAll(':', '');
      return int.parse(startTime);
    } catch (e) {
      return 0;
    }
  }
}