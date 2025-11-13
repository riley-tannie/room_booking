import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For iOS simulator, use localhost
  static const String baseUrl = 'http://localhost:3000';
  
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('Connection test status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
  
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final user = jsonDecode(response.body);
        final storage = await SharedPreferences.getInstance();
        await storage.setString('user', jsonEncode(user));
        return user;
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
  
  // Register
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String idNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        body: jsonEncode({
          'fullName': fullName,
          'idNumber': idNumber,
          'email': email,
          'password': password
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }
  
  // Get all rooms
  static Future<List<dynamic>> getAvailableRooms() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/rooms'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Return empty list instead of throwing error
      return [];
    }
  } catch (e) {
    return [];
  }
}

  // Get today's rooms for lecturer
  static Future<List<dynamic>> getTodayRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rooms/lecturer'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      print('Get today rooms response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load today\'s rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Get today rooms error: $e');
      rethrow;
    }
  }
  
  // Get time slots
  static Future<List<dynamic>> getRoomTimeSlots(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rooms/$roomId/time-slots'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load time slots: ${response.statusCode}');
      }
    } catch (e) {
      print('Get time slots error: $e');
      rethrow;
    }
  }

  // Get today's time slots for a room
  static Future<List<dynamic>> getTodayTimeSlots(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rooms/lecturer/$roomId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['time_slots'] ?? [];
      } else {
        throw Exception('Failed to load today\'s time slots: ${response.statusCode}');
      }
    } catch (e) {
      print('Get today time slots error: $e');
      rethrow;
    }
  }
  
  // Create booking
  static Future<Map<String, dynamic>> createBooking({
    required String studentId,
    required String roomId,
    required String timeSlot,
  }) async {
    try {
      print('=== BOOKING REQUEST ===');
      print('Student ID: $studentId');
      print('Room ID: $roomId');
      print('Time Slot: $timeSlot');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        body: jsonEncode({
          'studentId': studentId,
          'roomId': roomId,
          'timeSlot': timeSlot
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      print('Booking response status: ${response.statusCode}');
      print('Booking response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['error'] ?? 'Booking failed with status ${response.statusCode}';
          throw Exception(errorMessage);
        } catch (parseError) {
          throw Exception('Booking failed: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('=== BOOKING ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=== END BOOKING ERROR ===');
      rethrow;
    }
  }
  
  // Get user bookings
  static Future<List<dynamic>> getStudentBookings(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/student/$studentId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Get student bookings error: $e');
      rethrow;
    }
  }
  
  // Get today's bookings for a student
  static Future<List<dynamic>> getStudentTodayBookings(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/student/$studentId/today'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load today\'s bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Get today bookings error: $e');
      rethrow;
    }
  }
  
  // Check if student has booked today
  static Future<bool> hasStudentBookedToday(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/student/$studentId/has-booked-today'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['hasBooked'] ?? false;
      }
      return false;
    } catch (e) {
      print('Has booked today check error: $e');
      return false;
    }
  }
  
  // Get all bookings (for staff/lecturer)
  static Future<List<dynamic>> getAllBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load all bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Get all bookings error: $e');
      rethrow;
    }
  }

  // Get today's pending requests for lecturer
  static Future<List<dynamic>> getTodayPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/pending'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load today\'s pending requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Get today pending requests error: $e');
      rethrow;
    }
  }

  // Get approval history for lecturer
  static Future<List<dynamic>> getLecturerHistory(String lecturerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/history/$lecturerId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load lecturer history: ${response.statusCode}');
      }
    } catch (e) {
      print('Get lecturer history error: $e');
      rethrow;
    }
  }
  
  // Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
    required String approvedBy,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/bookings/$bookingId/status'),
        body: jsonEncode({
          'status': status,
          'approvedBy': approvedBy
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Status update failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Update booking status error: $e');
      rethrow;
    }
  }
  
  // Get dashboard stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Get dashboard stats error: $e');
      rethrow;
    }
  }

  // Get today's dashboard stats
  static Future<Map<String, dynamic>> getTodayDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/stats/today'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load today\'s dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Get today dashboard stats error: $e');
      rethrow;
    }
  }

  // Get lecturer dashboard stats
  static Future<Map<String, dynamic>> getLecturerDashboardStats(String lecturerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/dashboard/lecturer/$lecturerId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load lecturer dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Get lecturer dashboard stats error: $e');
      rethrow;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      final storage = await SharedPreferences.getInstance();
      await storage.remove('user');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }
  
  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final storage = await SharedPreferences.getInstance();
      final userString = storage.getString('user');
      if (userString != null) {
        return jsonDecode(userString);
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
  
  // Get current student ID
  static Future<String?> getCurrentStudentId() async {
    try {
      final user = await getCurrentUser();
      return user?['uid']?.toString();
    } catch (e) {
      print('Get current student ID error: $e');
      return null;
    }
  }
  
  // Get current student name
  static Future<String?> getCurrentStudentName() async {
    try {
      final user = await getCurrentUser();
      return user?['fullName']?.toString();
    } catch (e) {
      print('Get current student name error: $e');
      return null;
    }
  }
  
  // Get student role
  static Future<String?> getCurrentUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?['role']?.toString();
    } catch (e) {
      print('Get current user role error: $e');
      return null;
    }
  }

  // Get student requests
  static Future<List<dynamic>> getStudentRequests(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bookings/student/$studentId/today'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Get student requests error: $e');
      rethrow;
    }
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    try {
      final storage = await SharedPreferences.getInstance();
      await storage.clear();
    } catch (e) {
      print('Clear data error: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null && user['uid'] != null;
    } catch (e) {
      return false;
    }
  }

  // Get user type for routing
  static Future<String?> getUserType() async {
    try {
      final user = await getCurrentUser();
      return user?['userType']?.toString();
    } catch (e) {
      print('Get user type error: $e');
      return null;
    }
  }

  // Get lecturer ID
  static Future<String?> getCurrentLecturerId() async {
    try {
      final user = await getCurrentUser();
      return user?['uid']?.toString();
    } catch (e) {
      print('Get current lecturer ID error: $e');
      return null;
    }
  }
}