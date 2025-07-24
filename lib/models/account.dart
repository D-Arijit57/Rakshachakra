class Account {
  final String id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final double availableBalance;
  final String currency;
  final String ifscCode;
  final String branch;
  final List<String> accountHolders;
  final bool isActive;
  final DateTime lastTransactionDate;

  Account({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.availableBalance,
    required this.currency,
    required this.ifscCode,
    required this.branch,
    required this.accountHolders,
    required this.isActive,
    required this.lastTransactionDate,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      balance: json['balance'].toDouble(),
      availableBalance: json['availableBalance'].toDouble(),
      currency: json['currency'],
      ifscCode: json['ifscCode'],
      branch: json['branch'],
      accountHolders: List<String>.from(json['accountHolders']),
      isActive: json['isActive'],
      lastTransactionDate: DateTime.parse(json['lastTransactionDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'availableBalance': availableBalance,
      'currency': currency,
      'ifscCode': ifscCode,
      'branch': branch,
      'accountHolders': accountHolders,
      'isActive': isActive,
      'lastTransactionDate': lastTransactionDate.toIso8601String(),
    };
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '${'X' * (accountNumber.length - 4)}${accountNumber.substring(accountNumber.length - 4)}';
  }

  String get formattedBalance {
    return '₹${balance.toStringAsFixed(2)}';
  }

  String get formattedAvailableBalance {
    return '₹${availableBalance.toStringAsFixed(2)}';
  }
} 