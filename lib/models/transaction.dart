import 'package:flutter/material.dart';

enum TransactionType { credit, debit }
enum TransactionStatus { pending, completed, failed, cancelled }

class Transaction {
  final String id;
  final String accountId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final String? referenceNumber;
  final DateTime timestamp;
  final double balanceAfter;
  final String? category;
  final String? merchantName;
  final String? upiId;

  Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    this.referenceNumber,
    required this.timestamp,
    required this.balanceAfter,
    this.category,
    this.merchantName,
    this.upiId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      description: json['description'],
      referenceNumber: json['referenceNumber'],
      timestamp: DateTime.parse(json['timestamp']),
      balanceAfter: json['balanceAfter'].toDouble(),
      category: json['category'],
      merchantName: json['merchantName'],
      upiId: json['upiId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'referenceNumber': referenceNumber,
      'timestamp': timestamp.toIso8601String(),
      'balanceAfter': balanceAfter,
      'category': category,
      'merchantName': merchantName,
      'upiId': upiId,
    };
  }

  String get formattedAmount {
    final prefix = type == TransactionType.credit ? '+' : '-';
    return '$prefix₹${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TransactionType.credit:
        return Icons.arrow_downward;
      case TransactionType.debit:
        return Icons.arrow_upward;
    }
  }
} 