import 'package:flutter/material.dart';

class UPITransactionHistoryScreen extends StatelessWidget {
  const UPITransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Transaction History'),
      ),
      body: const Center(
        child: Text('UPI Transaction History Screen'),
      ),
    );
  }
} 