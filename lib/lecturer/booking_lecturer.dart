import 'package:flutter/material.dart';
import '../app_theme.dart';

class BookingLecturer extends StatelessWidget {
  const BookingLecturer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approval Requests'),
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rule, size: 80, color: AppTheme.primaryLight.withOpacity(0.7)),
              const SizedBox(height: 20),
              Text(
                'Room Booking Approval Queue',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'This page will display student booking requests awaiting your approval.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fetching new requests...')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Requests List'),
              )
            ],
          ),
        ),
      ),
    );
  }
}