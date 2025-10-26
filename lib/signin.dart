import 'package:flutter/material.dart';
import 'package:room_booking/lecturer/home_admin.dart';
import './student/homepage.dart';
import './staff/home_staff.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- Header ----------
          Container(
            height: 200,
            width: 1000,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ROOM RESERVATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to Room Reservation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // ---------- Body ----------
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ID Field
                  _buildTextField('ID Number', 'Enter your ID number'),
                  const SizedBox(height: 16),
                  
                  // Name Field
                  _buildTextField('Full Name', 'Enter your full name'),
                  const SizedBox(height: 16),
                  
                  // Username Field
                  _buildTextField('Username', 'Enter your username'),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  _buildPasswordField('Password', '*********'),
                  const SizedBox(height: 20),
                  
                  // Role Selection
                  const Text(
                    'Select Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRoleButtons(context),
                  const SizedBox(height: 30),
                  
                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToHome(context, 'student'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5473),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sign up feature coming soon!'),
                              backgroundColor: const Color(0xFF2C5473),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up Here',
                          style: TextStyle(
                            color: Color(0xFF2C5473),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E2A3A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E2A3A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildRoleButton('Student', 0, context),
          _buildRoleButton('Staff', 1, context),
          _buildRoleButton('Admin', 2, context),
        ],
      ),
    );
  }

  Widget _buildRoleButton(String role, int index, BuildContext context) {
    // For demo purposes, we'll use a fixed selection. In real app, you'd manage state.
    bool isSelected = index == 0; // Default to Student selected
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _goToHome(context, role.toLowerCase()),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C5473) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            role,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context, String role) {
    if (role == 'student') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else if (role == 'staff') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeStaff()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
    }
  }
}