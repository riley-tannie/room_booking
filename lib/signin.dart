import 'package:flutter/material.dart';
import 'package:room_booking/lecturer/home_admin.dart';
import './student/homepage.dart';
import './staff/home_staff.dart';
import 'app_theme.dart'; 

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Text(
              'ROOM RESERVATION',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to Room Reservation',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            
            // ID Field
            Text('ID Number', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your ID number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Name Field
            Text('Full Name', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Username Field
            Text('Username', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Password Field
            Text('Password', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
            SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '*********',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            
            // Role Selection
            Text('Select Role', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            )),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'student'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text('Student', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'staff'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text('Staff', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text('Admin', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToHome(context, 'student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign up feature coming soon!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up Here',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _goToHome(BuildContext context, String role) {
    if (role == 'student') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else if (role == 'staff') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeStaff()));
    } else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
    }
    
  }
}