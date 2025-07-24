import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';
import '../mixins/behavior_monitor_mixin.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with BehaviorMonitorMixin {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Transfer Money'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/transactions');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildTransferTypeSelector(),
          Expanded(
            child: _buildTransferForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildTransferTypeCard(
              icon: Icons.phone_android,
              title: 'UPI',
              subtitle: 'Quick Transfer',
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTransferTypeCard(
              icon: Icons.account_balance,
              title: 'Bank',
              subtitle: 'NEFT/IMPS',
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTransferTypeCard(
              icon: Icons.contacts,
              title: 'Contact',
              subtitle: 'Saved Contacts',
              isSelected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF667EEA),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm() {
    switch (_selectedIndex) {
      case 0:
        return _buildUPIForm();
      case 1:
        return _buildBankForm();
      case 2:
        return _buildContactForm();
      default:
        return _buildUPIForm();
    }
  }

  Widget _buildUPIForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildUPIField(),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 24),
            _buildTransferButton('Send via UPI'),
            const SizedBox(height: 16),
            _buildQuickUPIOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildAccountField(),
            const SizedBox(height: 16),
            _buildIFSCField(),
            const SizedBox(height: 16),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 24),
            _buildTransferButton('Send via NEFT'),
            const SizedBox(height: 16),
            _buildTransferInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildContactSearch(),
          const SizedBox(height: 16),
          _buildRecentContacts(),
          const SizedBox(height: 16),
          _buildAddNewContact(),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Amount (₹)',
        prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildUPIField() {
    return TextFormField(
      controller: _upiController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter UPI ID';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid UPI ID';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'UPI ID',
        hintText: 'example@upi',
        prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildAccountField() {
    return TextFormField(
      controller: _accountController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter account number';
        }
        if (value.length < 10) {
          return 'Please enter a valid account number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Account Number',
        prefixIcon: const Icon(Icons.account_balance, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildIFSCField() {
    return TextFormField(
      controller: _ifscController,
      textCapitalization: TextCapitalization.characters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter IFSC code';
        }
        if (value.length != 11) {
          return 'IFSC code must be 11 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'IFSC Code',
        hintText: 'ABCD0123456',
        prefixIcon: const Icon(Icons.code, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter recipient name';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Recipient Name',
        prefixIcon: const Icon(Icons.person, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Note (Optional)',
        prefixIcon: const Icon(Icons.note, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildTransferButton(String text) {
    return ElevatedButton(
      onPressed: _handleTransfer,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667EEA),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickUPIOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick UPI Options',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickOption(
                icon: Icons.qr_code_scanner,
                title: 'Scan QR',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.contacts,
                title: 'Contacts',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.history,
                title: 'Recent',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF667EEA), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Transfer Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text('• NEFT transfers are processed during banking hours'),
          Text('• Processing time: 2-4 hours'),
          Text('• No charges for NEFT transfers'),
        ],
      ),
    );
  }

  Widget _buildContactSearch() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Search Contacts',
        prefixIcon: const Icon(Icons.search, color: Color(0xFF667EEA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildRecentContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Contacts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildContactItem('John Doe', 'john@upi', Icons.person),
        _buildContactItem('Jane Smith', 'jane@upi', Icons.person),
        _buildContactItem('Mike Johnson', 'mike@upi', Icons.person),
      ],
    );
  }

  Widget _buildContactItem(String name, String upiId, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF667EEA),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(name),
      subtitle: Text(upiId),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _nameController.text = name;
        _upiController.text = upiId;
        setState(() => _selectedIndex = 0);
      },
    );
  }

  Widget _buildAddNewContact() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.person_add),
      label: const Text('Add New Contact'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667EEA),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleTransfer() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${_amountController.text}'),
            Text('Recipient: ${_nameController.text}'),
            if (_selectedIndex == 0) Text('UPI ID: ${_upiController.text}'),
            if (_selectedIndex == 1) ...[
              Text('Account: ${_accountController.text}'),
              Text('IFSC: ${_ifscController.text}'),
            ],
            if (_noteController.text.isNotEmpty) Text('Note: ${_noteController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Successful'),
        content: const Text('Your money has been transferred successfully.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/transactions');
            },
            child: const Text('View Transactions'),
          ),
        ],
      ),
    );
  }
} 