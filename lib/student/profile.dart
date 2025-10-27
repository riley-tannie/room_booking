import 'package:flutter/material.dart';
import 'package:room_booking/signin.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFF2C5473).withOpacity(0.1),
              child: const Icon(
                Icons.person_pin,
                size: 50,
                color: Color(0xFF2C5473),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Riley Tan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Student | Faculty of Engineering',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF26A65B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '320 points',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A65B),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(context, 'Personal Info', Icons.person_outline),
          _buildMenuItem(context, 'Security & Settings', Icons.settings),
          _buildMenuItem(context, 'Booking Support', Icons.support_agent),
          _buildMenuItem(context, 'Privacy & Policy', Icons.privacy_tip_outlined),
          
          _buildMenuItem(context, 'Sign out', Icons.logout, isSignOut: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {bool isSignOut = false}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Icon(
            icon,
            color: isSignOut ? const Color(0xFFD64541) : const Color(0xFF2C5473),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isSignOut ? const Color(0xFFD64541) : const Color(0xFF1E2A3A),
              fontWeight: isSignOut ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          trailing: isSignOut
              ? null
              : const Icon(Icons.chevron_right, size: 20, color: Color(0xFF2C5473)),
          onTap: () {
            if (isSignOut) {
              _handleSignOut(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigating to $title...'),
                  backgroundColor: const Color(0xFF2C5473),
                ),
              );
            }
          },
        ),
        if (!isSignOut && title != 'Privacy & Policy')
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFE8EDF1),
          ),
      ],
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Sign Out',
            style: TextStyle(
              color: Color(0xFF1E2A3A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('You will be logged out and returned to the sign-in screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF2C5473)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD64541),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}