import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_drawer.dart';
import '../mixins/behavior_monitor_mixin.dart';

class ScanPayScreen extends StatefulWidget {
  const ScanPayScreen({super.key});

  @override
  State<ScanPayScreen> createState() => _ScanPayScreenState();
}

class _ScanPayScreenState extends State<ScanPayScreen> with BehaviorMonitorMixin {
  final _formKey = GlobalKey<FormState>();
  final _upiIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isScanning = false;
  Map<String, dynamic> _qrData = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        title: const Text('Scan & Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () => _showTransactionHistory()),
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () => _showHelp()),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Scanner Section
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
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Scan QR Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // QR Scanner View
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isScanning ? _buildScannerView() : _buildScannerPlaceholder(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Scanner Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _startScanning,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF667EEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _uploadQRImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Upload QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF667EEA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            
            // Payment Form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // UPI ID Field
                      TextFormField(
                        controller: _upiIdController,
                        decoration: InputDecoration(
                          labelText: 'UPI ID / Phone Number',
                          labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.account_circle, color: Color(0xFF667EEA)),
                          suffixIcon: _upiIdController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _upiIdController.clear(),
                                )
                              : null,
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter UPI ID';
                          if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$').hasMatch(value!) &&
                              !RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter valid UPI ID or 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF667EEA)),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please enter amount';
                          final amount = double.tryParse(value!);
                          if (amount == null || amount <= 0) return 'Enter valid amount';
                          if (amount > 100000) return 'Amount cannot exceed ₹1,00,000';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Note Field
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
                          labelStyle: const TextStyle(color: Color(0xFF667EEA)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.note, color: Color(0xFF667EEA)),
                        ),
                        maxLines: 2,
                        maxLength: 100,
                      ),
                      const SizedBox(height: 20),
                      
                      // Quick Amount Buttons
                      const Text(
                        'Quick Amounts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [50, 100, 200, 500, 1000, 2000].map((amount) {
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
                                border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3)),
                              ),
                              child: Text(
                                '₹$amount',
                                style: const TextStyle(
                                  color: Color(0xFF667EEA),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Pay Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Pay Now',
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
            
            // UPI Apps Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular UPI Apps',
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
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                      children: [
                        _buildUPIApp('PhonePe', Icons.phone_android, Colors.purple),
                        _buildUPIApp('GPay', Icons.payment, Colors.blue),
                        _buildUPIApp('Paytm', Icons.account_balance_wallet, Colors.indigo),
                        _buildUPIApp('BHIM', Icons.flag, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScannerView() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'Scanning...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
        // Scanning overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildScannerPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text(
              'Tap "Scan QR" to start',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Point camera at QR code',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUPIApp(String name, IconData icon, Color color) {
    return InkWell(
      onTap: () => _openUPIApp(name),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    
    // Simulate scanning process
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
        _qrData = {
          'pa': 'merchant@paytm',
          'pn': 'Test Merchant',
          'am': '100',
          'cu': 'INR'
        };
      });
      
      _processScannedData();
    });
  }
  
  void _uploadQRImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR image upload functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _processScannedData() {
    if (_qrData.isNotEmpty) {
      setState(() {
        _upiIdController.text = _qrData['pa'] ?? '';
        _amountController.text = _qrData['am'] ?? '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR Code detected: ${_qrData['pn'] ?? 'Unknown Merchant'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pay To: ${_upiIdController.text}'),
                Text('Amount: ₹${_amountController.text}'),
                if (_noteController.text.isNotEmpty) Text('Note: ${_noteController.text}'),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to proceed with this payment?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completePayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }
  
  void _completePayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ₹${_amountController.text} sent successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Clear form
    _upiIdController.clear();
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _qrData = {};
    });
  }
  
  void _openUPIApp(String appName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $appName...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _showTransactionHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction History'),
        content: const Text('No recent transactions found.'),
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
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to use Scan & Pay:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Scan QR code or upload QR image'),
              Text('2. Enter or verify payment details'),
              Text('3. Add amount and optional note'),
              Text('4. Confirm and complete payment'),
              SizedBox(height: 16),
              Text('Supported formats:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• UPI ID (example@upi)'),
              Text('• Phone number (10 digits)'),
              Text('• QR codes from merchants'),
              SizedBox(height: 16),
              Text('Daily limit: ₹1,00,000'),
              Text('For support, contact customer care.'),
            ],
          ),
        ),
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

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const cornerSize = 20.0;
    
    // Top-left corner
    canvas.drawLine(
      Offset(centerX - 50, centerY - 50),
      Offset(centerX - 50 + cornerSize, centerY - 50),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 50, centerY - 50),
      Offset(centerX - 50, centerY - 50 + cornerSize),
      paint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(centerX + 50, centerY - 50),
      Offset(centerX + 50 - cornerSize, centerY - 50),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 50, centerY - 50),
      Offset(centerX + 50, centerY - 50 + cornerSize),
      paint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(centerX - 50, centerY + 50),
      Offset(centerX - 50 + cornerSize, centerY + 50),
      paint,
    );
    canvas.drawLine(
      Offset(centerX - 50, centerY + 50),
      Offset(centerX - 50, centerY + 50 - cornerSize),
      paint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(centerX + 50, centerY + 50),
      Offset(centerX + 50 - cornerSize, centerY + 50),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 50, centerY + 50),
      Offset(centerX + 50, centerY + 50 - cornerSize),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
