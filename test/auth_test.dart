import 'package:flutter_test/flutter_test.dart';
import 'package:raksha/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AuthService Tests', () {
    test('Login with valid credentials should succeed', () async {
      final authService = AuthService();
      
      // Test with valid credentials
      final result = await authService.login('deepam', 'deepam123');
      expect(result, isTrue);
    });

    test('Login with invalid credentials should fail', () async {
      final authService = AuthService();
      
      // Test with invalid credentials
      final result = await authService.login('wronguser', 'wrongpass');
      expect(result, isFalse);
    });

    test('Login with empty credentials should fail', () async {
      final authService = AuthService();
      
      // Test with empty credentials
      final result1 = await authService.login('', 'password');
      expect(result1, isFalse);
      
      final result2 = await authService.login('username', '');
      expect(result2, isFalse);
    });

    test('All user credentials should work', () async {
      final authService = AuthService();
      
      final testCases = [
        ('deepam', 'deepam123'),
        ('pratham', 'pratham123'),
        ('atharva', 'atharva123'),
        ('ashit', 'ashit123'),
        ('arijit', 'arijit123'),
      ];
      
      for (final (username, password) in testCases) {
        final result = await authService.login(username, password);
        expect(result, isTrue, reason: 'Failed for username: $username, password: $password');
      }
    });
  });
} 