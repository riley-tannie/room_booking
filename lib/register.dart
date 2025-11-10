import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'signin.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final String url = '192.168.0.111:3000';
  bool isWaiting = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void popDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void register() async {
    setState(() {
      isWaiting = true;
    });

    final fullName = _fullNameController.text.trim();
    final idNumber = _idNumberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (fullName.isEmpty) {
      popDialog('Error', 'Please enter your full name');
      setState(() => isWaiting = false);
      return;
    }

    if (idNumber.isEmpty) {
      popDialog('Error', 'Please enter your ID number');
      setState(() => isWaiting = false);
      return;
    }

    if (email.isEmpty) {
      popDialog('Error', 'Please enter your email');
      setState(() => isWaiting = false);
      return;
    }

    if (password.isEmpty) {
      popDialog('Error', 'Please enter a password');
      setState(() => isWaiting = false);
      return;
    }

    if (password != confirmPassword) {
      popDialog('Error', 'Passwords do not match');
      setState(() => isWaiting = false);
      return;
    }

    if (password.length < 6) {
      popDialog('Error', 'Password must be at least 6 characters long');
      setState(() => isWaiting = false);
      return;
    }

    try {
      final Uri uri = Uri.http(url, '/api/register');
      final Map userData = {
        'fullName': fullName,
        'idNumber': idNumber,
        'email': email,
        'password': password, // Password will be hashed on the server
      };

      final http.Response response = await http
          .post(
            uri,
            body: jsonEncode(userData),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        popDialog('Success', 'Registration successful! You can now sign in.', isSuccess: true);
      } else {
        final errorResponse = jsonDecode(response.body);
        popDialog('Error', errorResponse['error'] ?? 'Registration failed');
      }
    } on TimeoutException {
      popDialog('Error', 'Timeout error, try again!');
    } catch (e) {
      popDialog('Error', 'Registration failed. Please try again.');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFA),
      body: Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2C5473),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
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

          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(_fullNameController, 'Full Name', 'Enter your full name'),
                  const SizedBox(height: 16),
                  _buildTextField(_idNumberController, 'ID Number', 'Enter your ID number'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email', 'Enter your email'),
                  const SizedBox(height: 16),
                  _buildPasswordField(_passwordController, 'Password', 'Enter password', _isPasswordVisible, () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildPasswordField(_confirmPasswordController, 'Confirm Password', 'Confirm your password', _isConfirmPasswordVisible, () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  }),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isWaiting ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5473),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isWaiting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
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
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}