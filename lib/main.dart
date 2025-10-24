import 'package:flutter/material.dart';
import 'package:room_booking/signin.dart';
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
      home: SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}