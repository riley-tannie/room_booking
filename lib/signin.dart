import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'student/homepage.dart';
import 'staff/home_staff.dart';
import 'lecturer/home_lecturer.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constant/app_constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final String url = '${AppConstants.apiBaseUrl}';
  bool isWaiting = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    final storage = await SharedPreferences.getInstance();
    final userString = storage.getString('user');
    
    if (userString != null) {
      final user = jsonDecode(userString);
      if (user['uid'] != null && mounted) {
        _redirectBasedOnUserType(user);
      }
    }
  }

  void _redirectBasedOnUserType(Map<String, dynamic> user) {
  // Use 'role' instead of 'userType' since that's what the backend returns
  final userRole = user['role'] ?? 'student';
  
  print('Redirecting user with role: $userRole');
  
  Widget targetScreen;
  switch (userRole) {
    case 'staff':
      targetScreen = HomeStaff(); 
      break;
    case 'lecturer':
      targetScreen = HomeLecturer(); 
      break;
    case 'student':
    default:
      targetScreen = HomeScreen();
      break;
  }
  
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => targetScreen),
    (route) => false,
  );
}

  void popDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void login() async {
    setState(() {
      isWaiting = true;
    });
    
    try {
      final Uri uri = Uri.http(url, '/api/login');
      final Map account = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      
      final http.Response response = await http
          .post(
            uri,
            body: jsonEncode(account),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        final storage = await SharedPreferences.getInstance();
        await storage.setString('user', jsonEncode(user));
        
        if (!mounted) return;
        
        // Redirect based on user type
        _redirectBasedOnUserType(user);
      } else {
        final errorResponse = jsonDecode(response.body);
        if (!mounted) return;
        popDialog(errorResponse['error'] ?? 'Login failed');
      }
    } on TimeoutException catch (e) {
      if (!mounted) return;
      popDialog('Timeout error, try again!');
    } catch (e) {
      if (!mounted) return;
      popDialog('Unknown error, try again!');
    } finally {
      if (!mounted) return;
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
            height: 200,
            width: double.infinity,
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to Room Reservation System',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 220),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isWaiting ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C5473),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isWaiting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}