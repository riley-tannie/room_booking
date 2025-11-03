import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String url = 'localhost:3000'; // Use same URL everywhere
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.http(url, '/api/login');
    final response = await http.post(
      uri,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      final storage = await SharedPreferences.getInstance();
      await storage.setString('user', jsonEncode(user));
      return user;
    } else {
      throw Exception('Login failed');
    }
  }
  
  // Register
  static Future<Map<String, dynamic>> register(String fullName, String idNumber, String email, String password) async {
    final uri = Uri.http(url, '/api/register');
    final response = await http.post(
      uri,
      body: jsonEncode({
        'fullName': fullName,
        'idNumber': idNumber,
        'email': email,
        'password': password
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed');
    }
  }
  
  // Get rooms
  static Future<List<dynamic>> getAvailableRooms() async {
    final uri = Uri.http(url, '/api/rooms');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rooms');
    }
  }
  
  // Get time slots
  static Future<List<dynamic>> getRoomTimeSlots(String roomId) async {
    final uri = Uri.http(url, '/api/rooms/$roomId/time-slots');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load time slots');
    }
  }
  
  // Create booking
  static Future<Map<String, dynamic>> createBooking(String studentId, String roomId, String timeSlot) async {
    final uri = Uri.http(url, '/api/bookings');
    final response = await http.post(
      uri,
      body: jsonEncode({
        'studentId': studentId,
        'roomId': roomId,
        'timeSlot': timeSlot
      }),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Booking failed');
    }
  }
  
  // Get user bookings
  static Future<List<dynamic>> getStudentBookings(String studentId) async {
    final uri = Uri.http(url, '/api/bookings/student/$studentId');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load bookings');
    }
  }
  
  // Logout
  static Future<void> logout() async {
    final storage = await SharedPreferences.getInstance();
    await storage.remove('user');
  }
  
  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final storage = await SharedPreferences.getInstance();
    final userString = storage.getString('user');
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }
  // Add to api_service.dart
static Future<String?> getCurrentStudentId() async {
  final user = await getCurrentUser();
  return user?['uid']?.toString();
}

static Future<String?> getCurrentStudentName() async {
  final user = await getCurrentUser();
  return user?['fullName']?.toString();
}

static Future<bool> hasStudentBookedToday(String studentId) async {
  try {
    final uri = Uri.http(url, '/api/bookings/student/$studentId/today');
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final bookings = jsonDecode(response.body);
      return bookings.isNotEmpty;
    }
    return false;
  } catch (e) {
    return false;
  }
}

static Future<List<dynamic>> getStudentRequests(String studentId) async {
  final uri = Uri.http(url, '/api/bookings/student/$studentId/today');
  final response = await http.get(uri);
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load requests');
  }
}
}