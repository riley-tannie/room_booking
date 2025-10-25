import 'package:flutter/material.dart';
import 'package:room_booking/signin.dart';

class ProfileLecturer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lecturer Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
            ),
            SizedBox(height: 10),
            Text('Lecturer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Faculty of Science and Technology',
                style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Personal Info'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Support'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
