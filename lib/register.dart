import 'package:flutter/material.dart';
import 'signin.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          // ---------- Header ----------
          Container(
            height: 180,
            width: 1000,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    left: 8,
                    top: 4,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  // Title
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Join Room Reservation System',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Body ----------
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Full Name Field
                  _buildTextField(_fullNameController, 'Full Name', 'Enter your full name'),
                  const SizedBox(height: 16),
                  
                  // ID Number Field
                  _buildTextField(_idNumberController, 'ID Number', 'Enter your ID number'),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  _buildTextField(_emailController, 'Email', 'Enter your email'),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  _buildPasswordField(_passwordController, 'Password', 'Enter password', _isPasswordVisible, () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  _buildPasswordField(_confirmPasswordController, 'Confirm Password', 'Confirm your password', _isConfirmPasswordVisible, () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 30),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _register(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5473),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SignInScreen()),
                          );
                        },
                        child: const Text(
                          'Sign In Here',
                          style: TextStyle(
                            color: Color(0xFF2C5473),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email Domain Info
                  _buildEmailDomainInfo(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
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
          controller: controller,
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

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    String hint,
    bool isVisible,
    VoidCallback onToggle,
  ) {
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
          controller: controller,
          obscureText: !isVisible,
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
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDomainInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email Domain Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C5473),
            ),
          ),
          const SizedBox(height: 8),
          _buildDomainItem('Student', '@lamduan.mfu.ac.th'),
          _buildDomainItem('Lecturer', '@mfu.ac.th'),
          _buildDomainItem('Staff', '@mfu.th'),
          const SizedBox(height: 8),
          const Text(
            'Your role will be automatically detected based on your email domain.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainItem(String role, String domain) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$role: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            domain,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _register(BuildContext context) {
    final fullName = _fullNameController.text.trim();
    final idNumber = _idNumberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (fullName.isEmpty) {
      _showErrorDialog(context, 'Please enter your full name');
      return;
    }

    if (idNumber.isEmpty) {
      _showErrorDialog(context, 'Please enter your ID number');
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog(context, 'Please enter your email');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog(context, 'Please enter a password');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showErrorDialog(context, 'Please confirm your password');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog(context, 'Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog(context, 'Password must be at least 6 characters long');
      return;
    }

    // Validate email domain
    final String role = _detectRoleFromEmail(email);
    if (role == 'unknown') {
      _showErrorDialog(context, 
        'Invalid email domain. Please use one of the following:\n\n'
        '• @lamduan.mfu.ac.th for Student\n'
        '• @mfu.ac.th for Lecturer\n'
        '• @mfu.th for Staff'
      );
      return;
    }

    // Registration successful
    _showSuccessDialog(context, fullName, email, role);
  }

  String _detectRoleFromEmail(String email) {
    if (email.endsWith('@lamduan.mfu.ac.th')) {
      return 'student';
    } else if (email.endsWith('@mfu.ac.th')) {
      return 'lecturer';
    } else if (email.endsWith('@mfu.th')) {
      return 'staff';
    } else {
      return 'unknown';
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Registration Error',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF2C5473),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String fullName, String email, String role) {
    String roleDisplay = '';
    switch (role) {
      case 'student':
        roleDisplay = 'Student';
        break;
      case 'lecturer':
        roleDisplay = 'Lecturer';
        break;
      case 'staff':
        roleDisplay = 'Staff';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Registration Successful!',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, $fullName!'),
              const SizedBox(height: 8),
              Text('Email: $email'),
              Text('Role: $roleDisplay'),
              const SizedBox(height: 12),
              const Text(
                'Your account has been created successfully. You can now sign in.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
                );
              },
              child: const Text(
                'Sign In Now',
                style: TextStyle(
                  color: Color(0xFF2C5473),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}