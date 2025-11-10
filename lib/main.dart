import 'package:flutter/material.dart';
// import 'signin.dart';
import 'lecturer/home_lecturer.dart'; 
import 'app_theme.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Reservation',
      theme: AppTheme.themeData,
      // home: LoginScreen(),
      home: HomeLecturer(), 
      debugShowCheckedModeBanner: false,
    );
  }
}