import 'package:flutter/material.dart';
import 'dart:async';
import '../services/behavior_monitor_service.dart';
import '../services/cloud_ml_service.dart';

/// Widget for displaying real-time risk assessments
class RealTimeRiskWidget extends StatefulWidget {
  final bool showCompact;
  final VoidCallback? onHighRisk;
  
  const RealTimeRiskWidget({
    super.key,
    this.showCompact = false,
    this.onHighRisk,
  });

  @override
  State<RealTimeRiskWidget> createState() => _RealTimeRiskWidgetState();
}

class _RealTimeRiskWidgetState extends State<RealTimeRiskWidget> {
  final BehaviorMonitorService _behaviorMonitor = BehaviorMonitorService();
  StreamSubscription<RiskAssessment>? _riskSubscription;
  
  RiskAssessment? _currentRisk;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _isMonitoring = true;
    _riskSubscription = _behaviorMonitor.riskStream.listen(
      (riskAssessment) {
        setState(() {
          _currentRisk = riskAssessment;
        });
        
        // Trigger callback for high risk
        if (riskAssessment.riskLevel == RiskLevel.high && widget.onHighRisk != null) {
          widget.onHighRisk!();
        }
      },
      onError: (error) {
        print('Error in risk stream: $error');
      },
    );
  }

  @override
  void dispose() {
    _riskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMonitoring || _currentRisk == null) {
      return widget.showCompact ? _buildCompactPlaceholder() : _buildFullPlaceholder();
    }

    return widget.showCompact ? _buildCompactView() : _buildFullView();
  }

  Widget _buildCompactPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield,
            color: Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Monitoring...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield,
            color: Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Real-Time Risk Monitoring',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waiting for behavioral data...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView() {
    final risk = _currentRisk!;
    final color = _getRiskColor(risk.riskLevel);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRiskIcon(risk.riskLevel),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            risk.riskLevel.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView() {
    final risk = _currentRisk!;
    final color = _getRiskColor(risk.riskLevel);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRiskIcon(risk.riskLevel),
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Level: ${risk.riskLevel.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Score: ${risk.riskPercentage}',
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              if (risk.isOffline)
                Icon(
                  Icons.cloud_off,
                  color: Colors.orange,
                  size: 20,
                )
              else
                Icon(
                  Icons.cloud_done,
                  color: Colors.green,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            risk.riskDescription,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updated: ${_formatTime(risk.timestamp)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              if (risk.cloudResponse != null)
                Text(
                  'Cloud ML',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.security;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Floating action button for real-time risk monitoring
class RealTimeRiskFAB extends StatelessWidget {
  final VoidCallback? onTap;
  
  const RealTimeRiskFAB({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      icon: const Icon(Icons.security),
      label: const RealTimeRiskWidget(showCompact: true),
      backgroundColor: Colors.white,
      elevation: 4,
    );
  }
}
