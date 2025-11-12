import 'package:flutter/material.dart';
import '../signin.dart'; 
import '../api_service.dart';

class ProfileLecturer extends StatefulWidget {
  const ProfileLecturer({super.key});

  @override
  State<ProfileLecturer> createState() => _ProfileLecturerState();
}

class _ProfileLecturerState extends State<ProfileLecturer> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final user = await ApiService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFFE8EDF1),
            child: Icon(
              Icons.person_pin,
              size: 50,
              color: const Color(0xFF2C5473),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentUser?['fullName'] ?? 'Dr. Johnathan Smith',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lecturer | ${currentUser?['role'] ?? 'Faculty of Engineering'}',
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
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isSignOut
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSignOut ? const Color(0xFFEF6666) : const Color(0xFF2C5473),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSignOut ? const Color(0xFFEF6666) : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: isSignOut
            ? null
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          if (isSignOut && context != null) {
            _handleSignOut(context);
          } else {
            ScaffoldMessenger.of(context!).showSnackBar(
              SnackBar(
                content: Text('Navigating to $title...'),
                backgroundColor: const Color(0xFF2C5473),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Confirm Sign Out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You will be logged out and returned to the sign-in screen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFFE8EDF1),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF2C5473),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await ApiService.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF6666),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}