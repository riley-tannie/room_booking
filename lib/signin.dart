import 'package:flutter/material.dart';
import 'package:room_booking/lecturer/home_lecturer.dart';
import './student/homepage.dart';
import './staff/home_staff.dart';
import 'app_theme.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

  void _goToHome(BuildContext context, String role) {
    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else if (role == 'staff') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeStaff()),
      );
    } else if (role == 'lecturer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeLecturer()),
      );
    } else {
      // Default fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the global theme's text styles
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // AppBar theme is inherited globally from AppTheme
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // Consistent, spacious padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'ROOM RESERVATION',
              style: textTheme.displaySmall?.copyWith(color: AppTheme.primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Room Reservation',
              style: textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ID Field
            Text('ID Number', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your ID number',
                // Uses border/fill theme from AppTheme.inputDecorationTheme
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            Text('Full Name', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 20),

            // Username Field
            Text('Username', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Text('Password', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '*********',
              ),
            ),
            const SizedBox(height: 20),

            // Role Selection (Small, Balanced Buttons)
            Text('Select Role', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'student'),
                    style: ElevatedButton.styleFrom(
                      // Reduced vertical padding for smaller button size
                      padding: const EdgeInsets.symmetric(vertical: 12), 
                      // Use a slightly smaller/lighter font style
                      textStyle: textTheme.bodyLarge, 
                    ),
                    child: const Text('Student'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'staff'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: textTheme.bodyLarge,
                    ),
                    child: const Text('Staff'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'lecturer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: textTheme.bodyLarge,
                    ),
                    child: const Text('Lecturer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Main Sign In Button (Full Width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToHome(context, 'student'),
                style: ElevatedButton.styleFrom(
                  // Override padding to be tall for the main action button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sign In',
                  // Ensure text is white against the primary background
                  style: textTheme.titleLarge?.copyWith(color: Colors.white), 
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ", style: textTheme.bodyMedium),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sign up feature coming soon!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up Here',
                    // Use primary color to make the link stand out
                    style: textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}