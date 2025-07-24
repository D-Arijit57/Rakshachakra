import 'package:flutter/material.dart';

class UPISettingsScreen extends StatelessWidget {
  const UPISettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Settings'),
      ),
      body: const Center(
        child: Text('UPI Settings Screen'),
      ),
    );
  }
} 