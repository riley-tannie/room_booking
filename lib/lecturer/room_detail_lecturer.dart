import 'package:flutter/material.dart';
import '../app_theme.dart';

class RoomDetailLecturer extends StatelessWidget {
  final String roomName;

  const RoomDetailLecturer({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(roomName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location & General Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryLight, size: 28),
                    const SizedBox(width: 15),
                    Expanded(child: Text('2nd Floor, D1, Library (Multimedia 1)', style: Theme.of(context).textTheme.titleLarge)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text('Current Booking Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(context, Icons.calendar_month, 'Booking Date', '12/1/2025'),
                    _buildDetailRow(context, Icons.access_time, 'Booking Time', '08:00 am - 10:00 am'),
                    const Divider(height: 20, thickness: 1, color: AppTheme.dividerColor),
                    _buildDetailRow(context, Icons.person_outline, 'Booked by', 'Phuwin Tang'),
                    _buildDetailRow(context, Icons.verified_user, 'Approved by', 'Riley Tan', isStatus: true, statusColor: AppTheme.successColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text('Room Description', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Our multimedia room provides comfy beanbags and a large TV for relaxation and productivity. This room is equipped with high-speed internet and presentation tools. Students with ID and a lecturer\'s approval can book available time slots.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: AppTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to booking page...'))),
                icon: const Icon(Icons.schedule),
                label: const Text('View Full Schedule / Book Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isStatus = false, Color statusColor = AppTheme.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary))),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.right, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: isStatus ? FontWeight.bold : FontWeight.w600, color: isStatus ? statusColor : AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
