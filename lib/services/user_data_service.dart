import 'package:raksha/models/account.dart';
import 'package:raksha/models/transaction.dart';

class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // User-specific account data
  final Map<String, Map<String, dynamic>> _userAccounts = {
    'deepam': {
      'accountNumber': '1234567890123456',
      'balance': 45000.00,
      'availableBalance': 43000.00,
      'branch': 'Mumbai Main Branch',
      'ifsc': 'SBI0001234',
      'accountType': 'Savings Account',
      'currency': 'INR',
      'accountHolders': ['Deepam Goyal'],
      'isActive': true,
      'lastTransactionDate': DateTime.now().subtract(const Duration(hours: 2)),
    },
    'pratham': {
      'accountNumber': '2345678901234567',
      'balance': 32000.00,
      'availableBalance': 30000.00,
      'branch': 'Delhi Central Branch',
      'ifsc': 'HDFC0005678',
      'accountType': 'Current Account',
      'currency': 'INR',
      'accountHolders': ['Pratham Sharma'],
      'isActive': true,
      'lastTransactionDate': DateTime.now().subtract(const Duration(hours: 4)),
    },
    'atharva': {
      'accountNumber': '3456789012345678',
      'balance': 78000.00,
      'availableBalance': 75000.00,
      'branch': 'Bangalore Tech Branch',
      'ifsc': 'ICICI0009012',
      'accountType': 'Savings Account',
      'currency': 'INR',
      'accountHolders': ['Atharva Patel'],
      'isActive': true,
      'lastTransactionDate': DateTime.now().subtract(const Duration(hours: 1)),
    },
    'ashit': {
      'accountNumber': '4567890123456789',
      'balance': 156000.00,
      'availableBalance': 150000.00,
      'branch': 'Chennai South Branch',
      'ifsc': 'AXIS0003456',
      'accountType': 'Premium Savings',
      'currency': 'INR',
      'accountHolders': ['Ashit Kumar'],
      'isActive': true,
      'lastTransactionDate': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    'arijit': {
      'accountNumber': '5678901234567890',
      'balance': 92000.00,
      'availableBalance': 88000.00,
      'branch': 'Kolkata East Branch',
      'ifsc': 'PNB0007890',
      'accountType': 'Savings Account',
      'currency': 'INR',
      'accountHolders': ['Arijit Singh'],
      'isActive': true,
      'lastTransactionDate': DateTime.now().subtract(const Duration(hours: 6)),
    },
  };

  // User-specific transaction data
  final Map<String, List<Map<String, dynamic>>> _userTransactions = {
    'deepam': [
      {
        'id': '1',
        'amount': 2500.00,
        'type': TransactionType.credit,
        'status': TransactionStatus.completed,
        'description': 'Salary Credit',
        'referenceNumber': 'REF123456',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'balanceAfter': 45000.00,
        'category': 'Salary',
        'merchantName': 'Tech Corp',
      },
      {
        'id': '2',
        'amount': 500.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.completed,
        'description': 'UPI Payment to Restaurant',
        'referenceNumber': 'UPI789012',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'balanceAfter': 44500.00,
        'category': 'Food',
        'merchantName': 'Food Court',
      },
      {
        'id': '3',
        'amount': 1200.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.pending,
        'description': 'Online Shopping',
        'referenceNumber': 'SHOP345678',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'balanceAfter': 43300.00,
        'category': 'Shopping',
        'merchantName': 'Amazon',
      },
    ],
    'pratham': [
      {
        'id': '1',
        'amount': 1800.00,
        'type': TransactionType.credit,
        'status': TransactionStatus.completed,
        'description': 'Freelance Payment',
        'referenceNumber': 'REF234567',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'balanceAfter': 32000.00,
        'category': 'Income',
        'merchantName': 'Freelance Client',
      },
      {
        'id': '2',
        'amount': 800.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.completed,
        'description': 'Mobile Recharge',
        'referenceNumber': 'RECH456789',
        'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
        'balanceAfter': 31200.00,
        'category': 'Recharge',
        'merchantName': 'Airtel',
      },
    ],
    'atharva': [
      {
        'id': '1',
        'amount': 4500.00,
        'type': TransactionType.credit,
        'status': TransactionStatus.completed,
        'description': 'Investment Returns',
        'referenceNumber': 'REF345678',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'balanceAfter': 78000.00,
        'category': 'Investment',
        'merchantName': 'Mutual Fund',
      },
      {
        'id': '2',
        'amount': 2000.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.completed,
        'description': 'Gym Membership',
        'referenceNumber': 'GYM567890',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'balanceAfter': 76000.00,
        'category': 'Health',
        'merchantName': 'Fitness Club',
      },
    ],
    'ashit': [
      {
        'id': '1',
        'amount': 8500.00,
        'type': TransactionType.credit,
        'status': TransactionStatus.completed,
        'description': 'Business Payment',
        'referenceNumber': 'REF456789',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'balanceAfter': 156000.00,
        'category': 'Business',
        'merchantName': 'Client Corp',
      },
      {
        'id': '2',
        'amount': 5000.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.completed,
        'description': 'Car Insurance',
        'referenceNumber': 'INS678901',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'balanceAfter': 151000.00,
        'category': 'Insurance',
        'merchantName': 'Insurance Co',
      },
    ],
    'arijit': [
      {
        'id': '1',
        'amount': 3200.00,
        'type': TransactionType.credit,
        'status': TransactionStatus.completed,
        'description': 'Music Royalties',
        'referenceNumber': 'REF567890',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'balanceAfter': 92000.00,
        'category': 'Royalties',
        'merchantName': 'Music Platform',
      },
      {
        'id': '2',
        'amount': 1500.00,
        'type': TransactionType.debit,
        'status': TransactionStatus.completed,
        'description': 'Concert Tickets',
        'referenceNumber': 'TKT789012',
        'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
        'balanceAfter': 90500.00,
        'category': 'Entertainment',
        'merchantName': 'Ticket Master',
      },
    ],
  };

  Account getUserAccount(String username) {
    final accountData = _userAccounts[username];
    if (accountData == null) {
      throw Exception('User account not found for: $username');
    }

    return Account(
      id: 'acc_$username',
      accountNumber: accountData['accountNumber'],
      accountType: accountData['accountType'],
      balance: accountData['balance'],
      availableBalance: accountData['availableBalance'],
      currency: accountData['currency'],
      ifscCode: accountData['ifsc'],
      branch: accountData['branch'],
      accountHolders: List<String>.from(accountData['accountHolders']),
      isActive: accountData['isActive'],
      lastTransactionDate: accountData['lastTransactionDate'],
    );
  }

  List<Transaction> getUserTransactions(String username) {
    final transactionData = _userTransactions[username];
    if (transactionData == null) {
      return [];
    }

    return transactionData.map((data) => Transaction(
      id: data['id'],
      accountId: 'acc_$username',
      amount: data['amount'],
      type: data['type'],
      status: data['status'],
      description: data['description'],
      referenceNumber: data['referenceNumber'],
      timestamp: data['timestamp'],
      balanceAfter: data['balanceAfter'],
      category: data['category'],
      merchantName: data['merchantName'],
    )).toList();
  }

  double getUserBalance(String username) {
    final accountData = _userAccounts[username];
    return accountData?['balance'] ?? 0.0;
  }

  String getUserName(String username) {
    final accountData = _userAccounts[username];
    return accountData?['accountHolders']?.first ?? 'Unknown User';
  }

  String getUserBranch(String username) {
    final accountData = _userAccounts[username];
    return accountData?['branch'] ?? 'Unknown Branch';
  }

  String getUserIFSC(String username) {
    final accountData = _userAccounts[username];
    return accountData?['ifsc'] ?? 'Unknown IFSC';
  }
} 