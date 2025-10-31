import 'package:flutter/material.dart';
import '../signin.dart';

class ProfileLecturer extends StatelessWidget {
  const ProfileLecturer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2C5473),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color(0xFF2C5473),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dr. Johnathan Smith',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lecturer | Faculty of Engineering',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFB9EACF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Approval Rank: High Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26A65B),
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
      child: Column(
        children: [
          _buildMenuItem('Personal Info', Icons.person_outline),
          _buildMenuItem('Security & Settings', Icons.settings),
          _buildMenuItem('Booking Support', Icons.support_agent),
          _buildMenuItem('Privacy & Policy', Icons.privacy_tip_outlined),
          _buildMenuItem('Sign out', Icons.logout, isSignOut: true, context: context),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {bool isSignOut = false, BuildContext? context}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSignOut ? const Color(0xFFEF6666) : const Color(0xFF2C5473),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSignOut ? const Color(0xFFEF6666) : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSignOut ? null : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (isSignOut && context != null) {
          _handleSignOut(context);
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              content: Text('Navigating to $title...'),
              backgroundColor: const Color(0xFF2C5473),
            ),
          );
        }
      },
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Sign Out'),
          content: const Text('You will be logged out and returned to the sign-in screen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}