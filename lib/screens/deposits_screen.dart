import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';

class DepositsScreen extends StatefulWidget {
  const DepositsScreen({super.key});

  @override
  State<DepositsScreen> createState() => _DepositsScreenState();
}

class _DepositsScreenState extends State<DepositsScreen> {
  final List<Deposit> deposits = [
    Deposit(
      id: 'FD001',
      type: DepositType.fixed,
      principal: 50000,
      interestRate: 6.5,
      startDate: DateTime(2024, 1, 1),
      maturityDate: DateTime(2026, 1, 1),
      status: 'Active',
    ),
    Deposit(
      id: 'RD001',
      type: DepositType.recurring,
      principal: 10000,
      monthlyAmount: 5000,
      interestRate: 5.8,
      startDate: DateTime(2024, 3, 1),
      maturityDate: DateTime(2025, 3, 1),
      status: 'Active',
    ),
    Deposit(
      id: 'FD002',
      type: DepositType.fixed,
      principal: 75000,
      interestRate: 7.2,
      startDate: DateTime(2024, 6, 1),
      maturityDate: DateTime(2027, 6, 1),
      status: 'Active',
    ),
  ];

  double get totalAmount {
    return deposits.fold(0, (sum, deposit) => sum + deposit.currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Deposits'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Total Portfolio Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Portfolio Value',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPortfolioStat('Active Deposits', deposits.length.toString()),
                    _buildPortfolioStat('Avg. Interest', '${_calculateAverageInterest().toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
          
          // Deposits List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deposits.length,
              itemBuilder: (context, index) {
                final deposit = deposits[index];
                return _buildDepositCard(deposit);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDepositDialog(context),
        backgroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Deposit', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildPortfolioStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDepositCard(Deposit deposit) {
    final isFD = deposit.type == DepositType.fixed;
    final icon = isFD ? Icons.account_balance : Icons.repeat;
    final color = isFD ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deposit.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        Text(
                          isFD ? 'Fixed Deposit' : 'Recurring Deposit',
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deposit.status == 'Active' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deposit.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDepositInfo('Principal', '₹${deposit.principal.toStringAsFixed(0)}'),
                  ),
                  Expanded(
                    child: _buildDepositInfo('Interest Rate', '${deposit.interestRate}%'),
                  ),
                ],
              ),
              if (!isFD) ...[
                const SizedBox(height: 8),
                _buildDepositInfo('Monthly Amount', '₹${deposit.monthlyAmount.toStringAsFixed(0)}'),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDepositInfo('Start Date', _formatDate(deposit.startDate)),
                  ),
                  Expanded(
                    child: _buildDepositInfo('Maturity Date', _formatDate(deposit.maturityDate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Value:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${deposit.currentValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateAverageInterest() {
    if (deposits.isEmpty) return 0;
    final totalInterest = deposits.fold(0.0, (sum, deposit) => sum + deposit.interestRate);
    return totalInterest / deposits.length;
  }

  void _showAddDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Deposit'),
        content: const Text('This feature will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

enum DepositType { fixed, recurring }

class Deposit {
  final String id;
  final DepositType type;
  final double principal;
  final double interestRate;
  final DateTime startDate;
  final DateTime maturityDate;
  final String status;
  final double monthlyAmount;

  Deposit({
    required this.id,
    required this.type,
    required this.principal,
    required this.interestRate,
    required this.startDate,
    required this.maturityDate,
    required this.status,
    this.monthlyAmount = 0,
  });

  double get currentValue {
    final months = DateTime.now().difference(startDate).inDays / 30;
    if (type == DepositType.fixed) {
      return principal * (1 + (interestRate / 100) * (months / 12));
    } else {
      // Simplified RD calculation
      return principal + (monthlyAmount * months * (interestRate / 100) / 12);
    }
  }
} 