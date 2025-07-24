import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';

class SafeDepositLockersScreen extends StatefulWidget {
  const SafeDepositLockersScreen({super.key});

  @override
  State<SafeDepositLockersScreen> createState() => _SafeDepositLockersScreenState();
}

class _SafeDepositLockersScreenState extends State<SafeDepositLockersScreen> {
  final List<Locker> lockers = [
    Locker(
      id: '101',
      type: LockerType.medium,
      status: LockerStatus.active,
      annualRent: 2000,
      startDate: DateTime(2024, 1, 1),
      dueDate: DateTime(2025, 1, 1),
      lastAccessed: DateTime(2024, 11, 15),
    ),
    Locker(
      id: '205',
      type: LockerType.small,
      status: LockerStatus.active,
      annualRent: 1500,
      startDate: DateTime(2024, 3, 1),
      dueDate: DateTime(2025, 3, 1),
      lastAccessed: DateTime(2024, 11, 10),
    ),
    Locker(
      id: '312',
      type: LockerType.large,
      status: LockerStatus.expired,
      annualRent: 3000,
      startDate: DateTime(2023, 6, 1),
      dueDate: DateTime(2024, 6, 1),
      lastAccessed: DateTime(2024, 5, 20),
    ),
    Locker(
      id: '408',
      type: LockerType.medium,
      status: LockerStatus.pending,
      annualRent: 2000,
      startDate: DateTime(2024, 12, 1),
      dueDate: DateTime(2025, 12, 1),
      lastAccessed: null,
    ),
  ];

  int get activeLockers => lockers.where((locker) => locker.status == LockerStatus.active).length;
  double get totalAnnualRent => lockers.fold(0, (sum, locker) => sum + locker.annualRent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Safe Deposit Lockers'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Overview Section
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
                  'Locker Portfolio',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${lockers.length} Total Lockers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOverviewStat('Active', activeLockers.toString(), Icons.check_circle),
                    _buildOverviewStat('Annual Rent', '₹${totalAnnualRent.toStringAsFixed(0)}', Icons.account_balance_wallet),
                  ],
                ),
              ],
            ),
          ),
          
          // Lockers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lockers.length,
              itemBuilder: (context, index) {
                final locker = lockers[index];
                return _buildLockerCard(locker);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLockerDialog(context),
        backgroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Locker', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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

  Widget _buildLockerCard(Locker locker) {
    final statusColor = _getStatusColor(locker.status);
    final typeColor = _getTypeColor(locker.type);
    final isExpired = locker.status == LockerStatus.expired;
    final isPending = locker.status == LockerStatus.pending;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
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
                      color: typeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getLockerIcon(locker.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Locker ${locker.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        Text(
                          _getTypeString(locker.type),
                          style: TextStyle(
                            fontSize: 14,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusString(locker.status),
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
                    child: _buildLockerInfo('Annual Rent', '₹${locker.annualRent.toStringAsFixed(0)}'),
                  ),
                  Expanded(
                    child: _buildLockerInfo('Start Date', _formatDate(locker.startDate)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLockerInfo('Due Date', _formatDate(locker.dueDate)),
                  ),
                  Expanded(
                    child: _buildLockerInfo(
                      'Last Accessed',
                      locker.lastAccessed != null ? _formatDate(locker.lastAccessed!) : 'Never',
                    ),
                  ),
                ],
              ),
              if (isExpired || isPending) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpired ? Icons.warning : Icons.schedule,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isExpired 
                            ? 'Rent payment overdue. Please renew to continue access.'
                            : 'Locker activation pending. Contact branch for setup.',
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showLockerDetails(context, locker),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF667EEA),
                        side: const BorderSide(color: Color(0xFF667EEA)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: locker.status == LockerStatus.active ? () => _accessLocker(context, locker) : null,
                      icon: const Icon(Icons.lock_open, size: 16),
                      label: const Text('Access'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockerInfo(String label, String value) {
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

  Color _getStatusColor(LockerStatus status) {
    switch (status) {
      case LockerStatus.active:
        return Colors.green;
      case LockerStatus.expired:
        return Colors.red;
      case LockerStatus.pending:
        return Colors.orange;
    }
  }

  Color _getTypeColor(LockerType type) {
    switch (type) {
      case LockerType.small:
        return const Color(0xFF2196F3);
      case LockerType.medium:
        return const Color(0xFF4CAF50);
      case LockerType.large:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getLockerIcon(LockerType type) {
    switch (type) {
      case LockerType.small:
        return Icons.inbox;
      case LockerType.medium:
        return Icons.archive;
      case LockerType.large:
        return Icons.warehouse;
    }
  }

  String _getTypeString(LockerType type) {
    switch (type) {
      case LockerType.small:
        return 'Small Locker';
      case LockerType.medium:
        return 'Medium Locker';
      case LockerType.large:
        return 'Large Locker';
    }
  }

  String _getStatusString(LockerStatus status) {
    switch (status) {
      case LockerStatus.active:
        return 'Active';
      case LockerStatus.expired:
        return 'Expired';
      case LockerStatus.pending:
        return 'Pending';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddLockerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Locker'),
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

  void _showLockerDetails(BuildContext context, Locker locker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Locker ${locker.id} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_getTypeString(locker.type)}'),
            Text('Status: ${_getStatusString(locker.status)}'),
            Text('Annual Rent: ₹${locker.annualRent}'),
            Text('Start Date: ${_formatDate(locker.startDate)}'),
            Text('Due Date: ${_formatDate(locker.dueDate)}'),
            if (locker.lastAccessed != null)
              Text('Last Accessed: ${_formatDate(locker.lastAccessed!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _accessLocker(BuildContext context, Locker locker) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accessing Locker ${locker.id}...'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }
}

enum LockerType { small, medium, large }
enum LockerStatus { active, expired, pending }

class Locker {
  final String id;
  final LockerType type;
  final LockerStatus status;
  final double annualRent;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? lastAccessed;

  Locker({
    required this.id,
    required this.type,
    required this.status,
    required this.annualRent,
    required this.startDate,
    required this.dueDate,
    this.lastAccessed,
  });
} 