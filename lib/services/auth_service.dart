import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raksha/models/user.dart';
import 'dart:convert';
import 'real_time_cloud_risk_service.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  User? _currentUser;
  bool _isLoggedIn = false;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  /// Hashes the password using SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Initialize the auth service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('logged_in_username');
    
    if (savedUsername != null) {
      final userData = await getUserData(savedUsername);
      if (userData != null) {
        _currentUser = User(
          id: userData['id'] ?? '',
          username: userData['username'] ?? '',
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          lastLogin: userData['lastLogin'] != null 
              ? (userData['lastLogin'] as Timestamp).toDate() 
              : DateTime.now(),
          isBiometricEnabled: userData['isBiometricEnabled'] ?? false,
        );
        _isLoggedIn = true;
      }
    }
  }

  /// Login method that uses Firestore authentication
  Future<bool> login(String username, String password) async {
    final success = await loginWithFirestore(username, password);
    if (success) {
      await _setCurrentUser(username);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_username', username);
      
      // Re-test cloud connection now that user is authenticated
      try {
        await RealTimeCloudRiskService().retestConnection();
      } catch (e) {
        print('⚠️ Could not retest cloud connection after login: $e');
      }
    }
    return success;
  }

  /// Login with biometrics
  Future<bool> loginWithBiometrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('logged_in_username');
      
      if (savedUsername == null) {
        return false; // No saved user for biometric login
      }

      final userData = await getUserData(savedUsername);
      if (userData == null || userData['isBiometricEnabled'] != true) {
        return false;
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _setCurrentUser(savedUsername);
        
        // Re-test cloud connection now that user is authenticated
        try {
          await RealTimeCloudRiskService().retestConnection();
        } catch (e) {
          print('⚠️ Could not retest cloud connection after biometric login: $e');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Biometric login error: $e');
      return false;
    }
  }

  /// Logout method
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_username');
  }

  /// Private method to set current user
  Future<void> _setCurrentUser(String username) async {
    final userData = await getUserData(username);
    if (userData != null) {
      _currentUser = User(
        id: userData['id'] ?? '',
        username: userData['username'] ?? '',
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phoneNumber'] ?? '',
        lastLogin: userData['lastLogin'] != null 
            ? (userData['lastLogin'] as Timestamp).toDate() 
            : DateTime.now(),
        isBiometricEnabled: userData['isBiometricEnabled'] ?? false,
      );
      _isLoggedIn = true;
    }
  }

  /// Authenticates user by comparing password hash
  Future<bool> loginWithFirestore(String username, String password) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isEmpty) return false;

      final userDoc = query.docs.first;
      final userData = userDoc.data();

      final storedPasswordHash = userData['passwordHash'] as String?;
      if (storedPasswordHash == null) return false;

      final enteredPasswordHash = hashPassword(password);

      if (enteredPasswordHash == storedPasswordHash) {
        await userDoc.reference.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return true;
      }

      return false;
    } catch (e) {
      print('Firestore login error: $e');
      rethrow;
    }
  }

  /// Checks if a username already exists in Firestore
  Future<bool> usernameExists(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Firestore username check error: $e');
      rethrow;
    }
  }

  /// Gets user data by username (excluding password hash)
  Future<Map<String, dynamic>?> getUserData(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      if (query.docs.isNotEmpty) {
        final userData = query.docs.first.data();
        userData.remove('passwordHash');
        return userData;
      }
      return null;
    } catch (e) {
      print('Firestore get user data error: $e');
      rethrow;
    }
  }

  /// Registers a new user with additional fields
  Future<bool> registerUserWithDetails({
    required String username,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    bool isBiometricEnabled = false,
  }) async {
    try {
      final exists = await usernameExists(username);
      if (exists) throw Exception('Username already exists');

      final hashedPassword = hashPassword(password);
      final now = DateTime.now();

      // Generate a unique ID for the user
      final docRef = _firestore.collection('users').doc();
      
      await docRef.set({
        'id': docRef.id,
        'username': username,
        'passwordHash': hashedPassword,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'isBiometricEnabled': isBiometricEnabled,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': Timestamp.fromDate(now),
      });

      return true;
    } catch (e) {
      print('Firestore register error: $e');
      rethrow;
    }
  }

  /// Registers a new user with hashed password (simple version)
  Future<bool> registerUser(String username, String password) async {
    return await registerUserWithDetails(
      username: username,
      password: password,
      name: username, // Default name to username
      email: '', // Default empty email
      phoneNumber: '', // Default empty phone
      isBiometricEnabled: false,
    );
  }

  /// Enable/disable biometric authentication for current user
  Future<bool> toggleBiometricAuthentication(bool enabled) async {
    try {
      if (_currentUser == null) return false;
      
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: _currentUser!.username)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'isBiometricEnabled': enabled,
        });
        
        // Update local user object
        _currentUser = _currentUser!.copyWith(isBiometricEnabled: enabled);
        return true;
      }
      return false;
    } catch (e) {
      print('Toggle biometric error: $e');
      return false;
    }
  }
}