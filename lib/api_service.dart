import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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
      return response.statusCode == 200;
    } catch (e) {
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
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Registration failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
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
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load today\'s rooms');
      }
    } catch (e) {
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
        throw Exception('Failed to load time slots');
      }
    } catch (e) {
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
        throw Exception('Failed to load today\'s time slots');
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        body: jsonEncode({
          'studentId': studentId,
          'roomId': roomId,
          'timeSlot': timeSlot
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['error'] ?? 'Booking failed';
          throw Exception(errorMessage);
        } catch (parseError) {
          throw Exception('Booking failed: ${response.statusCode}');
        }
      }
    } catch (e) {
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
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
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
        throw Exception('Failed to load today\'s bookings');
      }
    } catch (e) {
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
        throw Exception('Failed to load all bookings');
      }
    } catch (e) {
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
        throw Exception('Failed to load today\'s pending requests');
      }
    } catch (e) {
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
        throw Exception('Failed to load lecturer history');
      }
    } catch (e) {
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
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
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
        throw Exception('Failed to load today\'s dashboard stats');
      }
    } catch (e) {
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
        throw Exception('Failed to load lecturer dashboard stats');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      final storage = await SharedPreferences.getInstance();
      await storage.remove('user');
    } catch (e) {
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
      return null;
    }
  }
  
  // Get current student ID
  static Future<String?> getCurrentStudentId() async {
    try {
      final user = await getCurrentUser();
      return user?['uid']?.toString();
    } catch (e) {
      return null;
    }
  }
  
  // Get current student name
  static Future<String?> getCurrentStudentName() async {
    try {
      final user = await getCurrentUser();
      return user?['fullName']?.toString();
    } catch (e) {
      return null;
    }
  }
  
  // Get student role
  static Future<String?> getCurrentUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?['role']?.toString();
    } catch (e) {
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
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Clear all stored data
  static Future<void> clearAllData() async {
    try {
      final storage = await SharedPreferences.getInstance();
      await storage.clear();
    } catch (e) {
      // Silent fail for clear data
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
      return null;
    }
  }

  // Get lecturer ID
  static Future<String?> getCurrentLecturerId() async {
    try {
      final user = await getCurrentUser();
      return user?['uid']?.toString();
    } catch (e) {
      return null;
    }
  }

  // --- STAFF MANAGEMENT METHODS ---

  // Create new room
  static Future<Map<String, dynamic>> createRoom({
    required String name,
    required String category,
    required String location,
    required String description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rooms'),
        body: jsonEncode({
          'name': name,
          'category': category,
          'location': location,
          'description': description,
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Room creation failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update room
  static Future<Map<String, dynamic>> updateRoom({
    required String roomId,
    required String name,
    required String location,
    required String description,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/rooms/$roomId'),
        body: jsonEncode({
          'name': name,
          'location': location,
          'description': description,
        }),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Room update failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Disable room
  static Future<Map<String, dynamic>> disableRoom(String roomId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/rooms/$roomId/disable'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Room disable failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Enable room
  static Future<Map<String, dynamic>> enableRoom(String roomId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/rooms/$roomId/enable'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Room enable failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Disable time slot
  static Future<Map<String, dynamic>> disableTimeSlot({
    required String roomId,
    required String timeSlot,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/rooms/$roomId/time-slots/$timeSlot/disable'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Time slot disable failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Enable time slot
  static Future<Map<String, dynamic>> enableTimeSlot({
    required String roomId,
    required String timeSlot,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/rooms/$roomId/time-slots/$timeSlot/enable'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Time slot enable failed';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get rooms with availability
  static Future<List<dynamic>> getRoomsWithAvailability() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rooms/availability'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}