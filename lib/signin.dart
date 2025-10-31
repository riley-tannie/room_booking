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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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

            Text('ID Number', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your ID number',
              ),
            ),
            const SizedBox(height: 20),

            Text('Full Name', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 20),

            Text('Username', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 20),

            Text('Password', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '*********',
              ),
            ),
            const SizedBox(height: 20),

            Text('Select Role', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHome(context, 'student'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToHome(context, 'student'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sign In',
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

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