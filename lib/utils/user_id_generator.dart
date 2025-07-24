import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserIdGenerator {
  /// Generate a hashed user ID from username for cloud ML service
  /// Takes the first 12 characters of the SHA-256 hash for uniqueness
  static String generateUserId(String username) {
    if (username.isEmpty) {
      return 'anonymous';
    }
    
    // Create SHA-256 hash of the username
    final bytes = utf8.encode(username);
    final digest = sha256.convert(bytes);
    final hash = digest.toString();
    
    // Take first 12 characters for user ID
    return hash.substring(0, 12);
  }
  
  /// Validate that a user ID follows the expected format
  static bool isValidUserId(String userId) {
    // Should be 12 characters, hexadecimal
    if (userId.length != 12) return false;
    
    final hexPattern = RegExp(r'^[0-9a-f]+$');
    return hexPattern.hasMatch(userId);
  }
  
  /// Get example of how user ID is generated
  static Map<String, String> getExamples() {
    return {
      'deepam': generateUserId('deepam'),
      'pratham': generateUserId('pratham'),
      'atharva': generateUserId('atharva'),
      'ashit': generateUserId('ashit'),
      'arijit': generateUserId('arijit'),
    };
  }
}
