import 'package:flutter/material.dart';
import 'package:raksha/widgets/app_drawer.dart';
import '../mixins/behavior_monitor_mixin.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> with BehaviorMonitorMixin {
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedOperator = 'Select Operator';
  String _selectedCircle = 'Select Circle';
  
  final List<String> _operators = [
    'Select Operator',
    'Airtel',
    'Jio',
    'Vi (Vodafone Idea)',
    'BSNL',
    'Aircel',
    'Telenor',
    'Tata Docomo',
    'Reliance GSM',
  ];
  
  final List<String> _circles = [
    'Select Circle',
    'Delhi',
    'Mumbai',
    'Kolkata',
    'Chennai',
    'Andhra Pradesh',
    'Assam',
    'Bihar',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu & Kashmir',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'North East',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Tamil Nadu',
    'Uttar Pradesh (East)',
    'Uttar Pradesh (West)',
    'West Bengal',
  ];
  
  final List<int> _quickAmounts = [10, 20, 30, 50, 100, 200, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Mobile Recharge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Recharge Card
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
                          Icon(Icons.phone_android, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Mobile Recharge',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Mobile Number Field
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
                        child: TextField(
                          controller: _mobileController,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF667EEA)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.contacts, color: Color(0xFF667EEA)),
                              onPressed: () {
                                // Add contact picker functionality
                              },
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            // Auto-detect operator based on number
                            if (value.length >= 4) {
                              _detectOperator(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Operator Selection
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
                          value: _selectedOperator,
                          decoration: InputDecoration(
                            labelText: 'Operator',
                            labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.network_cell, color: Color(0xFF667EEA)),
                          ),
                          items: _operators.map((operator) {
                            return DropdownMenuItem(
                              value: operator,
                              child: Text(operator),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedOperator = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Circle Selection
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
                          value: _selectedCircle,
                          decoration: InputDecoration(
                            labelText: 'Circle',
                            labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF667EEA)),
                          ),
                          items: _circles.map((circle) {
                            return DropdownMenuItem(
                              value: circle,
                              child: Text(circle),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCircle = value!;
                            });
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
                        child: TextField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
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
                      
                      // Recharge Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _performRecharge,
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
                            'Recharge Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Quick Amount Selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickAmounts.map((amount) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _amountController.text = amount.toString();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667EEA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF667EEA)),
                            ),
                            child: Text(
                              '₹$amount',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Recent Recharges
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
                          'Recent Recharges',
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
                            'No recent recharges found.',
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
            const SizedBox(height: 20),
            
            // Special Offers
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Special Offers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Get 5% cashback on recharges above ₹200',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _detectOperator(String number) {
    // Simple operator detection based on number prefix
    if (number.startsWith('91') || number.startsWith('92') || number.startsWith('93') || number.startsWith('94') || number.startsWith('95') || number.startsWith('96') || number.startsWith('97') || number.startsWith('98') || number.startsWith('99')) {
      String prefix = number.substring(0, 4);
      if (['9999', '9998', '9997', '9996', '9995', '9994', '9993', '9992', '9991'].contains(prefix)) {
        setState(() {
          _selectedOperator = 'Airtel';
        });
      } else if (['9988', '9987', '9986', '9985', '9984', '9983', '9982', '9981'].contains(prefix)) {
        setState(() {
          _selectedOperator = 'Jio';
        });
      } else if (['9977', '9976', '9975', '9974', '9973', '9972', '9971'].contains(prefix)) {
        setState(() {
          _selectedOperator = 'Vi (Vodafone Idea)';
        });
      }
    }
  }
  
  void _performRecharge() {
    if (_mobileController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedOperator == 'Select Operator') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an operator'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recharge of ₹${_amountController.text} for ${_mobileController.text} initiated successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Clear fields
    _mobileController.clear();
    _amountController.clear();
    setState(() {
      _selectedOperator = 'Select Operator';
      _selectedCircle = 'Select Circle';
    });
  }
}