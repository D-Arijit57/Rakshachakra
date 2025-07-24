import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';
import 'package:raksha/models/transaction.dart';
import 'package:raksha/services/user_data_service.dart';
import 'package:raksha/services/auth_service.dart';
import '../mixins/behavior_monitor_mixin.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with BehaviorMonitorMixin {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  List<Transaction> _filteredTransactions = [];
  List<Transaction> _allTransactions = [];
  bool _isLoading = false;
  final UserDataService _userDataService = UserDataService();
  final AuthService _authService = AuthService();
  String? _currentUsername;

  final List<String> _filterOptions = ['All', 'Credit', 'Debit', 'Pending', 'Failed'];

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    _currentUsername = user?.username;
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUsername != null) {
      // Load user-specific transactions
      final transactions = _userDataService.getUserTransactions(_currentUsername!);
      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTransactions() {
    final searchTerm = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        final matchesSearch = transaction.description.toLowerCase().contains(searchTerm) ||
            transaction.merchantName?.toLowerCase().contains(searchTerm) == true ||
            transaction.referenceNumber?.toLowerCase().contains(searchTerm) == true;
        
        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Credit' && transaction.type == TransactionType.credit) ||
            (_selectedFilter == 'Debit' && transaction.type == TransactionType.debit) ||
            (_selectedFilter == 'Pending' && transaction.status == TransactionStatus.pending) ||
            (_selectedFilter == 'Failed' && transaction.status == TransactionStatus.failed);
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadStatement,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _filterTransactions(),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF667EEA)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _filterTransactions();
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: const Color(0xFF667EEA),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.credit
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            transaction.typeIcon,
            color: transaction.type == TransactionType.credit
                ? Colors.green
                : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction.type == TransactionType.credit
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  transaction.formattedDate,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: transaction.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (transaction.merchantName != null) ...[
              const SizedBox(height: 2),
              Text(
                transaction.merchantName!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            if (transaction.referenceNumber != null) ...[
              const SizedBox(height: 2),
              Text(
                'Ref: ${transaction.referenceNumber}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showTransactionDetails(transaction),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
                _filterTransactions();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: transaction.type == TransactionType.credit
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    transaction.typeIcon,
                    color: transaction.type == TransactionType.credit
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.formattedDate,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: transaction.type == TransactionType.credit
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Status', transaction.status.toString().split('.').last.toUpperCase()),
            if (transaction.merchantName != null)
              _buildDetailRow('Merchant', transaction.merchantName!),
            if (transaction.referenceNumber != null)
              _buildDetailRow('Reference', transaction.referenceNumber!),
            if (transaction.upiId != null)
              _buildDetailRow('UPI ID', transaction.upiId!),
            if (transaction.category != null)
              _buildDetailRow('Category', transaction.category!),
            _buildDetailRow('Balance After', '₹${transaction.balanceAfter.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _downloadStatement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Statement'),
        content: const Text('Choose the format for your transaction statement:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('PDF statement downloaded successfully');
            },
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('CSV statement downloaded successfully');
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 