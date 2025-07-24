import 'package:flutter/material.dart';

class UPIRecentTransactions extends StatelessWidget {
  UPIRecentTransactions({super.key});

  final List<_UPITransaction> transactions = const [
    _UPITransaction(
      recipient: 'John Doe',
      upiId: 'john@upi',
      amount: 500,
      date: 'Jul 2, 2025',
      status: 'Success',
    ),
    _UPITransaction(
      recipient: 'Cafe Coffee Day',
      upiId: 'ccd@icici',
      amount: 250,
      date: 'Jul 1, 2025',
      status: 'Success',
    ),
    _UPITransaction(
      recipient: 'Netflix',
      upiId: 'netflix@hdfcbank',
      amount: 499,
      date: 'Jun 30, 2025',
      status: 'Failed',
    ),
    _UPITransaction(
      recipient: 'Amit Sharma',
      upiId: 'amit@okaxis',
      amount: 1200,
      date: 'Jun 29, 2025',
      status: 'Pending',
    ),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Success':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final tx = transactions[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: const Icon(Icons.account_circle, color: Colors.blue),
          ),
          title: Text('Paid ₹${tx.amount} to ${tx.recipient}'),
          subtitle: Text('${tx.upiId} • ${tx.date}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(tx.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tx.status,
              style: TextStyle(
                color: _statusColor(tx.status),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UPITransaction {
  final String recipient;
  final String upiId;
  final int amount;
  final String date;
  final String status;
  const _UPITransaction({
    required this.recipient,
    required this.upiId,
    required this.amount,
    required this.date,
    required this.status,
  });
} 