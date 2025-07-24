import 'package:flutter/material.dart';

class UPILinkedAccounts extends StatelessWidget {
  UPILinkedAccounts({super.key});

  final List<_UPIAccount> accounts = const [
    _UPIAccount(
      bank: 'HDFC Bank',
      accountName: 'Savings Account',
      balance: 12500.75,
      upiId: 'user@hdfcbank',
    ),
    _UPIAccount(
      bank: 'ICICI Bank',
      accountName: 'Salary Account',
      balance: 8000.00,
      upiId: 'user@icici',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Accounts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...accounts.map((acc) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              color: Colors.grey[50],
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF667EEA)),
                title: Text('${acc.bank} (${acc.accountName})'),
                subtitle: Text('UPI ID: ${acc.upiId}'),
                trailing: Text(
                  '₹${acc.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _UPIAccount {
  final String bank;
  final String accountName;
  final double balance;
  final String upiId;
  const _UPIAccount({
    required this.bank,
    required this.accountName,
    required this.balance,
    required this.upiId,
  });
} 