import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../mixins/behavior_monitor_mixin.dart';

class BillPaymentsScreen extends StatefulWidget {
  const BillPaymentsScreen({super.key});

  @override
  State<BillPaymentsScreen> createState() => _BillPaymentsScreenState();
}

class _BillPaymentsScreenState extends State<BillPaymentsScreen> with BehaviorMonitorMixin {
  final _formKey = GlobalKey<FormState>();
  String _selectedBillType = 'Electricity';
  String _selectedProvider = 'Select Provider';
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _mobileController = TextEditingController();
  
  final List<String> _billTypes = [
    'Electricity',
    'Water',
    'Gas',
    'Internet',
    'Mobile Postpaid',
    'DTH',
    'Insurance',
    'Loan EMI',
    'Credit Card',
    'Property Tax',
  ];
  
  final Map<String, List<String>> _providers = {
    'Electricity': ['BSES Delhi', 'MSEB Maharashtra', 'KSEB Kerala', 'TNEB Tamil Nadu', 'WBSEDCL West Bengal', 'PSPCL Punjab'],
    'Water': ['Delhi Jal Board', 'Mumbai Water', 'Bangalore Water', 'Chennai Water', 'Kolkata Water'],
    'Gas': ['Indraprastha Gas', 'Mahanagar Gas', 'Sabarmati Gas', 'Gujarat Gas', 'Adani Gas'],
    'Internet': ['Airtel Fiber', 'Jio Fiber', 'BSNL Broadband', 'Hathway', 'Tikona', 'ACT Fibernet'],
    'Mobile Postpaid': ['Airtel Postpaid', 'Jio Postpaid', 'Vi Postpaid', 'BSNL Postpaid'],
    'DTH': ['Tata Sky', 'Dish TV', 'Airtel Digital TV', 'Sun Direct', 'Videocon D2H'],
    'Insurance': ['LIC', 'HDFC Life', 'ICICI Prudential', 'SBI Life', 'Bajaj Allianz'],
    'Loan EMI': ['SBI Home Loan', 'HDFC Home Loan', 'ICICI Home Loan', 'Axis Bank Loan', 'Bajaj Finserv'],
    'Credit Card': ['SBI Card', 'HDFC Card', 'ICICI Card', 'Axis Card', 'Citibank Card'],
    'Property Tax': ['MCD Delhi', 'BMC Mumbai', 'BBMP Bangalore', 'Chennai Corporation', 'KMC Kolkata'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Bill Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => _showBillHistory()),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () => _showHelp()),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Main Bill Payment Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'Pay Bills',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Bill Type Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedBillType,
                            decoration: InputDecoration(
                              labelText: 'Bill Type',
                              labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.category, color: Color(0xFF667EEA)),
                            ),
                            items: _billTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBillType = value!;
                                _selectedProvider = 'Select Provider';
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Provider Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedProvider,
                            decoration: InputDecoration(
                              labelText: 'Service Provider',
                              labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.business, color: Color(0xFF667EEA)),
                            ),
                            items: ['Select Provider', ..._providers[_selectedBillType] ?? []].map((provider) {
                              return DropdownMenuItem<String>(
                                value: provider,
                                child: Text(provider),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProvider = value!;
                              });
                            },
                            validator: (value) => value == 'Select Provider' ? 'Please select a provider' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Account Number/Consumer ID
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _accountNumberController,
                            decoration: InputDecoration(
                              labelText: 'Account Number / Consumer ID',
                              labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.numbers, color: Color(0xFF667EEA)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF667EEA)),
                                onPressed: () => _scanAccountNumber(),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter account number' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Mobile Number (for verification)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _mobileController,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number (for verification)',
                              labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF667EEA)),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter mobile number';
                              if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Invalid mobile number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Amount Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: 'Amount (Leave empty to fetch bill)',
                              labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF667EEA)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _fetchBill,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF667EEA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Fetch Bill',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _payBill,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF667EEA),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Pay Bill',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Quick Bill Categories
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          _buildQuickCategory(Icons.electrical_services, 'Electricity', Colors.amber),
                          _buildQuickCategory(Icons.water_drop, 'Water', Colors.blue),
                          _buildQuickCategory(Icons.local_gas_station, 'Gas', Colors.orange),
                          _buildQuickCategory(Icons.wifi, 'Internet', Colors.green),
                          _buildQuickCategory(Icons.phone_android, 'Mobile', Colors.purple),
                          _buildQuickCategory(Icons.tv, 'DTH', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Recent Bills
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, color: Color(0xFF667EEA)),
                          SizedBox(width: 8),
                          Text(
                            'Recent Bills',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'No recent bill payments found.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickCategory(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBillType = label;
          _selectedProvider = 'Select Provider';
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _scanAccountNumber() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _fetchBill() {
    if (_formKey.currentState!.validate()) {
      // Simulate fetching bill
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bill Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bill Type: $_selectedBillType'),
              Text('Provider: $_selectedProvider'),
              Text('Account: ${_accountNumberController.text}'),
              const SizedBox(height: 12),
              const Text('Amount Due: ₹1,250.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Due Date: 25 Aug 2025', style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _amountController.text = '1250';
                });
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      );
    }
  }
  
  void _payBill() {
    if (_formKey.currentState!.validate()) {
      if (_amountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter amount or fetch bill first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bill Type: $_selectedBillType'),
              Text('Provider: $_selectedProvider'),
              Text('Account: ${_accountNumberController.text}'),
              Text('Amount: ₹${_amountController.text}'),
              const SizedBox(height: 12),
              const Text('Are you sure you want to proceed with this payment?'),
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
                _processPayment();
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
  
  void _processPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bill payment of ₹${_amountController.text} processed successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Clear form
    _accountNumberController.clear();
    _amountController.clear();
    _mobileController.clear();
    setState(() {
      _selectedBillType = 'Electricity';
      _selectedProvider = 'Select Provider';
    });
  }
  
  void _showBillHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bill Payment History'),
        content: const Text('No payment history found.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const Text('1. Select bill type and provider\n2. Enter account number\n3. Fetch bill or enter amount\n4. Confirm payment\n\nFor support, contact customer care.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
