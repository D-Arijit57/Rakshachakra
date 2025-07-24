import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple user session management for custom authentication
class UserSession {
  static String? _currentUsername;
  static Map<String, dynamic>? _currentUserData;

  /// Set the current user session
  static void setCurrentUser(String username, Map<String, dynamic> userData) {
    _currentUsername = username;
    _currentUserData = userData;
  }

  /// Get the current username
  static String? getCurrentUsername() {
    return _currentUsername;
  }

  /// Get the current user data
  static Map<String, dynamic>? getCurrentUserData() {
    return _currentUserData;
  }

  /// Clear the current user session (logout)
  static void clearSession() {
    _currentUsername = null;
    _currentUserData = null;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _currentUsername != null;
  }
} 