class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000'; //your backend server URL
  //static const Duration apiTimeout = Duration(seconds: 10);
  //static const Duration apiLongTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String storageUserKey = 'user';
  //static const String storageTokenKey = 'token';
  static const String storageLanguageKey = 'language';
  static const String storageThemeKey = 'theme';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleStaff = 'staff';
  static const String roleLecturer = 'lecturer';

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Room Types
  static const String roomTypeLecture = 'lecturehall';
  static const String roomTypeMultimedia = 'multimedia';
  static const String roomTypeStudy = 'study';

  // Time Slots
  static const List<String> availableTimeSlots = [
    '08:00-10:00',
    '10:00-12:00',
    '13:00-15:00',
    '15:00-17:00',
  ];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Colors (Hex)
  static const String colorPrimary = '#1976D2';
  static const String colorSecondary = '#FF9800';
  static const String colorSuccess = '#4CAF50';
  static const String colorError = '#F44336';
  static const String colorWarning = '#FF9800';
  static const String colorInfo = '#2196F3';

  // Status Colors
  static const String colorStatusPending = '#FF9800';
  static const String colorStatusApproved = '#4CAF50';
  static const String colorStatusRejected = '#F44336';

  // Room Type Colors
  /*static const String colorRoomLecture = '#2196F3';
  static const String colorRoomMultimedia = '#4CAF50';
  static const String colorRoomStudy = '#9C27B0';*/

  // Error Messages
  static const String errorNetworkConnection = 'Unable to connect to the network';
  static const String errorUnknown = 'unknown error';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorPasswordTooShort = 'Password must be at least $minPasswordLength characters'; 
  static const String errorEmptyField = 'Please fill in all required fields';
  static const String errorBookingLimitReached = 'You have reached your booking limit for today';

  // Success Messages (Thai)
  static const String successLogin    = 'Login successful';
  static const String successRegister = 'Registration successful';
  static const String successBooking  = 'Room booking successful';
  static const String successUpdate   = 'Profile update successful';
  static const String successApproved = 'Booking approved successfully';
  static const String successRejected = 'Booking rejected successfully';

  // Date Formats
  static const String dateFormatFull = 'dd/MM/yyyy HH:mm:ss';
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatTime = 'HH:mm';
  static const String dateFormatDateTime = 'dd/MM/yyyy HH:mm';

  // App Info
  static const String appName = 'Room Booking System';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'room booking application for students of Mae Fah Luange university';
  

  // Regex Patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phonePattern = RegExp(
    r'^[0-9]{10}$',
  );
  static final RegExp idNumberPattern = RegExp(
    r'^[0-9]{13}$',
  );

  // Prevent instantiation
  AppConstants._();
}

// Enum สำหรับ User Roles
enum UserRole {
  student,
  staff,
  lecturer;

  String get value {
    switch (this) {
      case UserRole.student:
        return AppConstants.roleStudent;
      case UserRole.staff:
        return AppConstants.roleStaff;
      case UserRole.lecturer:
        return AppConstants.roleLecturer;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.staff:
        return 'staff';
      case UserRole.lecturer:
        return 'lecturer';
    }
  }
}

// Enum สำหรับ Booking Status
enum BookingStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case BookingStatus.pending:
        return AppConstants.statusPending;
      case BookingStatus.approved:
        return AppConstants.statusApproved;
      case BookingStatus.rejected:
        return AppConstants.statusRejected;
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.approved:
        return 'approved';
      case BookingStatus.rejected:
        return 'rejected';
    }
  }

  String get color {
    switch (this) {
      case BookingStatus.pending:
        return AppConstants.colorStatusPending;
      case BookingStatus.approved:
        return AppConstants.colorStatusApproved;
      case BookingStatus.rejected:
        return AppConstants.colorStatusRejected;
    }
  }
}

// Enum สำหรับ Room Types
enum RoomType {
  lecture,
  multimedia,
  study;

  String get value {
    switch (this) {
      case RoomType.lecture:
        return AppConstants.roomTypeLecture;
      case RoomType.multimedia:
        return AppConstants.roomTypeMultimedia;
      case RoomType.study:
        return AppConstants.roomTypeStudy;
    }
  }

  String get displayName {
    switch (this) {
      case RoomType.lecture:
        return 'Lecturer Hall';
      case RoomType.multimedia:
        return 'Multimedia Room';
      case RoomType.study:
        return 'Study Room';
    }
  }

  /*String get color {
    switch (this) {
      case RoomType.lecture:
        return AppConstants.colorRoomLecture;
      case RoomType.multimedia:
        return AppConstants.colorRoomMultimedia;
      case RoomType.study:
        return AppConstants.colorRoomStudy;
    }
  }*/
}