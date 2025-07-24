import 'package:flutter/material.dart';

class AddPayeeScreen extends StatefulWidget {
  const AddPayeeScreen({super.key});

  @override
  State<AddPayeeScreen> createState() => _AddPayeeScreenState();
}

class _AddPayeeScreenState extends State<AddPayeeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step1 = 0; // 0: Bank, 1: Credit Card, 2: Cardless Cash
  String? _bankAccountName;
  String? _accountName;
  String? _accountNumber;
  String? _reAccountNumber;
  String? _creditCardNumber;
  String? _reCreditCardNumber;
  String? _cardName;
  String? _beneficiaryNickname;
  String? _mobileNumber;
  int _payeeIdType = 0; // 0: Voter ID, 1: PAN
  String? _payeeIdValue;

  List<String> bankAccountNames = [
    'Savings Account',
    'Current Account',
    'Salary Account',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Add Payee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1 - Select Transfer Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ToggleButtons(
                        isSelected: [
                          _step1 == 0,
                          _step1 == 1,
                          _step1 == 2,
                        ],
                        onPressed: (index) {
                          setState(() {
                            _step1 = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF667EEA),
                        color: Colors.black87,
                        constraints: const BoxConstraints(minHeight: 48, minWidth: 100),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance, size: 18),
                                SizedBox(width: 4),
                                Text('Bank', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.credit_card, size: 18),
                                SizedBox(width: 4),
                                Text('Credit Card', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone_android, size: 18),
                                SizedBox(width: 4),
                                Text('Cardless', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_step1 == 0) ..._buildBankAccountFields(),
                  if (_step1 == 1) ..._buildCreditCardFields(),
                  if (_step1 == 2) ..._buildCardlessCashFields(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBankAccountFields() {
    return [
      const Text('Step 2 - Account Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Bank Account',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: _bankAccountName,
        items: bankAccountNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
        onChanged: (val) => setState(() => _bankAccountName = val),
        validator: (val) => val == null ? 'Please select a bank account' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Account Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => _accountName = val,
        validator: (val) => val == null || val.isEmpty ? 'Enter account name' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Account Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => _accountNumber = val,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Enter account number';
          if (val.length < 10 || val.length > 18) return 'Invalid account number';
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Re-enter Account Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => _reAccountNumber = val,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Re-enter account number';
          if (val != _accountNumber) return 'Account numbers do not match';
          return null;
        },
      ),
      const SizedBox(height: 8),
      const Text('Please ensure that the payee account number that you enter is correct', style: TextStyle(color: Colors.red)),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF0288D1),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payee added successfully!')));
                }
              },
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0288D1)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCreditCardFields() {
    return [
      const Text('Step 2 - Indian Credit Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Credit Card Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => _creditCardNumber = val,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Enter credit card number';
          if (val.length < 12 || val.length > 19) return 'Invalid credit card number';
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Re-enter Credit Card Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) => _reCreditCardNumber = val,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Re-enter credit card number';
          if (val != _creditCardNumber) return 'Credit card numbers do not match';
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Name on Card',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => _cardName = val,
        validator: (val) => val == null || val.isEmpty ? 'Enter name on card' : null,
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF0288D1),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payee added successfully!')));
                }
              },
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0288D1)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCardlessCashFields() {
    return [
      const Text('Step 2 - Cashless Cash Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Beneficiary Nickname',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => _beneficiaryNickname = val,
        validator: (val) => val == null || val.isEmpty ? 'Enter beneficiary nickname' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Mobile Number',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.phone,
        onChanged: (val) => _mobileNumber = val,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Enter mobile number';
          if (!RegExp(r'^\d{10}$').hasMatch(val)) return 'Invalid mobile number';
          return null;
        },
      ),
      const SizedBox(height: 16),
      const Text('Payee ID (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ToggleButtons(
          isSelected: [_payeeIdType == 0, _payeeIdType == 1],
          onPressed: (index) {
            setState(() {
              _payeeIdType = index;
              _payeeIdValue = null;
            });
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: Colors.white,
          fillColor: const Color(0xFF0288D1),
          color: Colors.black87,
          constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_vote, size: 18),
                SizedBox(width: 6),
                Text('Voter ID'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card, size: 18),
                SizedBox(width: 6),
                Text('PAN'),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        decoration: InputDecoration(
          labelText: _payeeIdType == 0 ? 'Voter ID (Optional)' : 'PAN (Optional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => _payeeIdValue = val,
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF0288D1),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payee added successfully!')));
                }
              },
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFF0288D1)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ];
  }
} 