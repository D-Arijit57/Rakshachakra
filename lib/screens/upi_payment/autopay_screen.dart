import 'package:flutter/material.dart';

class AutoPayScreen extends StatelessWidget {
  const AutoPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoPay'),
      ),
      body: const Center(
        child: Text('AutoPay Screen'),
      ),
    );
  }
} 