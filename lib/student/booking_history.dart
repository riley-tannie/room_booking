import 'package:flutter/material.dart';

class BookingHistory extends StatelessWidget {
  const BookingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jan  2025",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3C6E),
              ),
            ),
            const SizedBox(height: 12),

            _buildBookingCard(
              context,
              imageUrl:
                  'https://images.unsplash.com/photo-1593642532400-2682810df593',
              room: 'Multimedia Room 1',
              date: '12/1/2025',
              time: '08:00 am',
              bookedBy: 'Phuwin Tang',
              approvedBy: 'Riley Tan',
              location: '2nd Floor, D1, Library',
              description:
                  'Our multimedia room provides comfy beanbags and 18inches TV for relaxation and productivity of students.',
            ),
            const SizedBox(height: 20),

            const Text(
              "Nov  2024",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0E3C6E),
              ),
            ),
            const SizedBox(height: 12),

            _buildBookingCard(
              context,
              imageUrl:
                  'https://images.unsplash.com/photo-1593642532400-2682810df593',
              room: 'Lecture Hall 3',
              date: '25/11/2024',
              time: '10:30 am',
              bookedBy: 'Phuwin Tang',
              approvedBy: 'Dr. Adam Smith',
              location: 'Building A, 1st Floor',
              description:
                  'Large lecture hall with modern audio system and comfortable seating for up to 200 students.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context, {
    required String imageUrl,
    required String room,
    required String date,
    required String time,
    required String bookedBy,
    required String approvedBy,
    required String location,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0E3C6E),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            imageUrl: imageUrl,
                            room: room,
                            date: date,
                            time: time,
                            bookedBy: bookedBy,
                            approvedBy: approvedBy,
                            location: location,
                            description: description,
                          ),
                        ),
                      );
                    },
                    child: const Text('See detail'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BookingDetailPage extends StatelessWidget {
  final String imageUrl;
  final String room;
  final String date;
  final String time;
  final String bookedBy;
  final String approvedBy;
  final String location;
  final String description;

  const BookingDetailPage({
    super.key,
    required this.imageUrl,
    required this.room,
    required this.date,
    required this.time,
    required this.bookedBy,
    required this.approvedBy,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: Column(
        children: [
          const SizedBox(height: 50),

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
                  "Borrowed Detailed",
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 230,
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
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
                    const Text(
                      "Booking detail",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3C6E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow("Room Name", room),
                    _buildDetailRow("Booking time", time),
                    _buildDetailRow("Booking date", date),
                    _buildDetailRow("Booked by", bookedBy),
                    _buildDetailRow("Approved by", approvedBy),
                    const SizedBox(height: 24),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0E3C6E),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF1D2D50),
                        height: 1.5,
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
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0E3C6E),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
