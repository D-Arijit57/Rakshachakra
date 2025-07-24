import 'package:flutter/material.dart';

class ScanPayScreen extends StatelessWidget {
  const ScanPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
      ),
      body: const Center(
        child: Text('Scan & Pay Screen'),
      ),
    );
  }
} 