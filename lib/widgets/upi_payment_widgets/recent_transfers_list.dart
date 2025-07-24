import 'package:flutter/material.dart';

class RecentTransfersList extends StatelessWidget {
  RecentTransfersList({super.key});

  final List<_Transfer> transfers = const [
    _Transfer(recipient: 'John Doe', bank: 'SBI', amount: 5000, date: 'Jul 3, 2025', status: 'Success'),
    _Transfer(recipient: 'Priya Singh', bank: 'HDFC', amount: 12000, date: 'Jul 2, 2025', status: 'Pending'),
    _Transfer(recipient: 'Amit Kumar', bank: 'ICICI', amount: 2500, date: 'Jul 1, 2025', status: 'Failed'),
    _Transfer(recipient: 'Mom', bank: 'Axis', amount: 8000, date: 'Jun 30, 2025', status: 'Success'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transfers',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: transfers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tx = transfers[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.account_circle, color: Colors.blue),
                ),
                title: Text('₹${tx.amount} to ${tx.recipient}'),
                subtitle: Text('${tx.bank} • ${tx.date}'),
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
          ),
        ),
      ],
    );
  }
}

class _Transfer {
  final String recipient;
  final String bank;
  final int amount;
  final String date;
  final String status;
  const _Transfer({required this.recipient, required this.bank, required this.amount, required this.date, required this.status});
} 