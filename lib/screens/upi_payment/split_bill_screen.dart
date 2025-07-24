import 'package:flutter/material.dart';

class SplitBillScreen extends StatelessWidget {
  const SplitBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
      ),
      body: const Center(
        child: Text('Split Bill Screen'),
      ),
    );
  }
} 