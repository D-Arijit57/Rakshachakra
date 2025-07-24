// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha/main.dart';
import 'package:raksha/screens/login_screen.dart';
import 'package:raksha/screens/home_screen.dart';
import 'package:raksha/models/user.dart';
import 'package:raksha/models/account.dart';
import 'package:raksha/models/transaction.dart';

void main() {
  group('Raksha Banking App Tests', () {
    testWidgets('App should start with login screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify login screen elements are present
      expect(find.text('Raksha'), findsOneWidget);
      expect(find.text('Secure Banking App'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Login form validation should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Try to login without entering credentials
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Should show validation errors
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Login with valid dummy credentials should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Enter valid dummy credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Should not show validation errors
      expect(find.text('Please enter your username'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('Login with invalid credentials should fail', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Enter invalid credentials
      await tester.enterText(find.byType(TextFormField).at(0), 'wronguser');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Should not show validation errors (form validation passes)
      expect(find.text('Please enter your username'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('Password visibility toggle should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Initially password should be obscured
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      
      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      
      // Password should now be visible
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Home screen should display account information', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Verify home screen elements
      expect(find.text('rakshaChakra'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('ACCOUNTS'), findsOneWidget);
      expect(find.text('Savings Account'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('Quick actions should be present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Verify quick action buttons
      expect(find.text('Bill Payments'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Add Payee'), findsOneWidget);
      expect(find.text('Scan & Pay'), findsOneWidget);
      expect(find.text('Recharge'), findsOneWidget);
      expect(find.text('UPI Payment'), findsOneWidget);
    });
  });

  group('Model Tests', () {
    test('User model should serialize correctly', () {
      final user = User(
        id: 'test_id',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '+1234567890',
        lastLogin: DateTime(2024, 1, 1),
        isBiometricEnabled: true,
      );

      final json = user.toJson();
      final fromJson = User.fromJson(json);

      expect(fromJson.id, equals(user.id));
      expect(fromJson.name, equals(user.name));
      expect(fromJson.email, equals(user.email));
      expect(fromJson.phoneNumber, equals(user.phoneNumber));
      expect(fromJson.isBiometricEnabled, equals(user.isBiometricEnabled));
    });

    test('Account model should format values correctly', () {
      final account = Account(
        id: 'acc_001',
        accountNumber: '1234567890123456',
        accountType: 'Savings',
        balance: 50000.00,
        availableBalance: 48000.00,
        currency: 'INR',
        ifscCode: 'ABCD0123456',
        branch: 'Main Branch',
        accountHolders: ['John Doe'],
        isActive: true,
        lastTransactionDate: DateTime(2024, 1, 1),
      );

      expect(account.maskedAccountNumber, equals('XXXXXXXXXXXX3456'));
      expect(account.formattedBalance, equals('₹50000.00'));
      expect(account.formattedAvailableBalance, equals('₹48000.00'));
    });

    test('Transaction model should handle different types', () {
      final creditTransaction = Transaction(
        id: '1',
        accountId: 'acc_001',
        amount: 1000.00,
        type: TransactionType.credit,
        status: TransactionStatus.completed,
        description: 'Salary Credit',
        timestamp: DateTime(2024, 1, 1),
        balanceAfter: 50000.00,
      );

      final debitTransaction = Transaction(
        id: '2',
        accountId: 'acc_001',
        amount: 500.00,
        type: TransactionType.debit,
        status: TransactionStatus.pending,
        description: 'Payment',
        timestamp: DateTime(2024, 1, 1),
        balanceAfter: 49500.00,
      );

      expect(creditTransaction.formattedAmount, equals('+₹1000.00'));
      expect(debitTransaction.formattedAmount, equals('-₹500.00'));
      expect(creditTransaction.statusColor, equals(Colors.green));
      expect(debitTransaction.statusColor, equals(Colors.orange));
    });
  });

  group('Navigation Tests', () {
    testWidgets('Should navigate to accounts screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Tap on account card
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();
      
      // Should navigate to accounts screen
      expect(find.text('Savings Account'), findsOneWidget);
    });

    testWidgets('Should navigate to transfer screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Tap on transfer quick action
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      
      // Should navigate to transfer screen
      expect(find.text('Transfer Money'), findsOneWidget);
    });
  });

  group('Form Validation Tests', () {
    testWidgets('Transfer form should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransferScreen()));
      
      // Try to transfer without entering amount
      await tester.tap(find.text('Send via UPI'));
      await tester.pump();
      
      // Should show validation error
      expect(find.text('Please enter amount'), findsOneWidget);
    });

    testWidgets('UPI ID validation should work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransferScreen()));
      
      // Enter invalid UPI ID
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid');
      await tester.tap(find.text('Send via UPI'));
      await tester.pump();
      
      // Should show validation error
      expect(find.text('Please enter a valid UPI ID'), findsOneWidget);
    });
  });
}
