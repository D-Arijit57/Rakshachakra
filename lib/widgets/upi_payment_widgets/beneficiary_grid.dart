import 'package:flutter/material.dart';

class BeneficiaryGrid extends StatelessWidget {
  BeneficiaryGrid({super.key});

  final List<_Beneficiary> beneficiaries = const [
    _Beneficiary(name: 'John Doe', bank: 'SBI', account: '****1234', status: 'Active'),
    _Beneficiary(name: 'Priya Singh', bank: 'HDFC', account: '****5678', status: 'Inactive'),
    _Beneficiary(name: 'Amit Kumar', bank: 'ICICI', account: '****4321', status: 'Active'),
    _Beneficiary(name: 'Mom', bank: 'Axis', account: '****8765', status: 'Active'),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.red;
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
          'Saved Beneficiaries',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: beneficiaries.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            final b = beneficiaries[i];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              color: Colors.grey[50],
              child: ListTile(
                leading: Icon(Icons.account_circle, color: _statusColor(b.status)),
                title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${b.bank}, ${b.account}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(b.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.status,
                    style: TextStyle(
                      color: _statusColor(b.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Beneficiary {
  final String name;
  final String bank;
  final String account;
  final String status;
  const _Beneficiary({required this.name, required this.bank, required this.account, required this.status});
} 