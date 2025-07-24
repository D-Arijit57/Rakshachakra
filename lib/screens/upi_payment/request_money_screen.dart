import 'package:flutter/material.dart';

class RequestMoneyScreen extends StatelessWidget {
  const RequestMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Money'),
      ),
      body: const Center(
        child: Text('Request Money Screen'),
      ),
    );
  }
} 